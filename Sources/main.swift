import Foundation
import Network
import FoundationModels

// MARK: - Request/Response Models
struct CompletionRequest: Codable {
    let prompt: String
    let systemPrompt: String?
    let maxTokens: Int?
    let temperature: Double?
}

struct CompletionResponse: Codable {
    let response: String
    let error: String?
}

// MARK: - Apple AI Service
@available(macOS 26.0, *)
class AppleAIService {
    private var session: LanguageModelSession
    
    init() async throws {
        guard case .available = SystemLanguageModel.default.availability else {
            throw NSError(
                domain: "AppleAIService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Foundation Models not available"]
            )
        }
        
        self.session = LanguageModelSession()
    }
    
    func generateCompletion(
        prompt: String,
        systemPrompt: String? = nil,
        maxTokens: Int? = nil,
        temperature: Double? = nil
    ) async throws -> String {
        let fullPrompt: String
        if let systemPrompt = systemPrompt {
            fullPrompt = """
            System: \(systemPrompt)
            
            User: \(prompt)
            """
        } else {
            fullPrompt = prompt
        }
        
        var options = GenerationOptions()
        
        if let temp = temperature {
            options.temperature = temp
        }
        
        if let maxTokens = maxTokens {
            options.maximumResponseTokens = maxTokens
        }
        
        let response = try await session.respond(to: fullPrompt, options: options)
        return response.content
    }
    
    func reset() async throws {
        self.session = LanguageModelSession()
    }
}

// MARK: - HTTP Server
@available(macOS 26.0, *)
class AppleAIHTTPServer {
    private let port: UInt16
    private let listener: NWListener
    private let aiService: AppleAIService
    
    init(port: UInt16 = 8080) async throws {
        self.port = port
        self.aiService = try await AppleAIService()
        
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true
        self.listener = try NWListener(using: parameters, on: NWEndpoint.Port(rawValue: port)!)
    }
    
    func start() {
        listener.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("✅ Apple AI Server running on http://localhost:\(self.port)")
                print("📝 POST to http://localhost:\(self.port)/completion")
                print("🔄 POST to http://localhost:\(self.port)/reset\n")
            case .failed(let error):
                print("❌ Server failed: \(error)")
            default:
                break
            }
        }
        
        listener.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }
        
        listener.start(queue: .main)
    }
    
    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .global())
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, _, _ in
            guard let self = self, let data = data else {
                connection.cancel()
                return
            }
            
            Task {
                let response = await self.processRequest(data)
                
                // Send response and wait for completion
                await withCheckedContinuation { continuation in
                    connection.send(content: response, completion: .contentProcessed { _ in
                        continuation.resume()
                    })
                }
                
                // Now cancel after sending
                connection.cancel()
            }
        }
    }
    
    private func processRequest(_ data: Data) async -> Data {
        guard let request = String(data: data, encoding: .utf8) else {
            return self.errorResponse("Invalid request data")
        }
        
        let lines = request.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else {
            return self.errorResponse("Invalid HTTP request")
        }
        
        let parts = requestLine.components(separatedBy: " ")
        guard parts.count >= 2 else {
            return self.errorResponse("Invalid HTTP request line")
        }
        
        let method = parts[0]
        let path = parts[1]
        
        if method == "OPTIONS" {
            return self.corsResponse()
        }
        
        if method == "POST" && path == "/reset" {
            do {
                try await aiService.reset()
                let response = CompletionResponse(response: "Session reset", error: nil)
                let responseData = try JSONEncoder().encode(response)
                return self.httpResponse(body: responseData)
            } catch {
                return self.errorResponse("Reset failed: \(error.localizedDescription)")
            }
        }
        
        guard method == "POST", path == "/completion" else {
            return self.errorResponse("Use POST /completion or /reset", statusCode: 404)
        }
        
        guard let bodyStart = request.range(of: "\r\n\r\n") else {
            return self.errorResponse("No request body")
        }
        
        let bodyString = String(request[bodyStart.upperBound...])
        guard let bodyData = bodyString.data(using: .utf8),
              let completionRequest = try? JSONDecoder().decode(CompletionRequest.self, from: bodyData) else {
            return self.errorResponse("Invalid JSON")
        }
        
        print("📥 \(completionRequest.prompt.prefix(50))...")
        
        do {
            let result = try await aiService.generateCompletion(
                prompt: completionRequest.prompt,
                systemPrompt: completionRequest.systemPrompt,
                maxTokens: completionRequest.maxTokens,
                temperature: completionRequest.temperature
            )
            
            print("📤 \(result.prefix(50))...\n")
            
            let response = CompletionResponse(response: result, error: nil)
            let responseData = try JSONEncoder().encode(response)
            return self.httpResponse(body: responseData)
        } catch {
            print("❌ \(error.localizedDescription)\n")
            return self.errorResponse("AI error: \(error.localizedDescription)")
        }
    }
    
    private func httpResponse(body: Data, statusCode: Int = 200) -> Data {
        let statusText = statusCode == 200 ? "OK" : "Error"
        let response = """
            HTTP/1.1 \(statusCode) \(statusText)\r
            Content-Type: application/json\r
            Access-Control-Allow-Origin: *\r
            Access-Control-Allow-Methods: POST, OPTIONS\r
            Access-Control-Allow-Headers: Content-Type\r
            Content-Length: \(body.count)\r
            \r
            
            """
        var responseData = response.data(using: .utf8)!
        responseData.append(body)
        return responseData
    }
    
    private func corsResponse() -> Data {
        """
        HTTP/1.1 204 No Content\r
        Access-Control-Allow-Origin: *\r
        Access-Control-Allow-Methods: POST, OPTIONS\r
        Access-Control-Allow-Headers: Content-Type\r
        \r
        
        """.data(using: .utf8)!
    }
    
    private func errorResponse(_ message: String, statusCode: Int = 400) -> Data {
        let response = CompletionResponse(response: "", error: message)
        let bodyData = (try? JSONEncoder().encode(response)) ?? Data()
        return httpResponse(body: bodyData, statusCode: statusCode)
    }
}

// MARK: - Main
@main
@available(macOS 26.0, *)
struct AppleAIServerApp {
    static func main() {
        // Start async task
        Task {
            print("🚀 Starting Apple AI Server...\n")
            
            do {
                let server = try await AppleAIHTTPServer(port: 8080)
                server.start()
            } catch {
                print("❌ Failed: \(error)")
                print("\nTroubleshooting:")
                print("1. Verify macOS 26+: sw_vers")
                print("2. Enable Apple Intelligence in Settings")
                exit(1)
            }
        }
        
        // Keep the program running
        RunLoop.main.run()
    }
}
