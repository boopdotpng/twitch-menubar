import Foundation
import Network

class OAuthServer {
    let port: NWEndpoint.Port = 8080
    var listener: NWListener?
    var onTokenReceived: ((String) -> Void)?
    
    func start() {
        do {
            listener = try NWListener(using: .tcp, on: port)
            listener?.newConnectionHandler = { connection in
                connection.start(queue: .main)
                self.handleConnection(connection)
            }
            listener?.start(queue: .main)
            print("oauth server started on http://localhost:\(port)/callback")
        } catch {
            print("failed to start oauth server: \(error)")
        }
    }
    
    func stop() {
        listener?.cancel()
        listener = nil
        print("oauth server stopped.")
    }
    
    private func handleConnection(_ connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { data, _, _, _ in
            guard let data = data,
                  let request = String(data: data, encoding: .utf8) else {
                connection.cancel()
                return
            }
            print("received request:\n\(request)")
            
            guard let firstLine = request.components(separatedBy: "\r\n").first,
                  firstLine.hasPrefix("GET /callback") else {
                connection.cancel()
                return
            }
            
            if let token = self.extractAccessToken(from: firstLine) {
                UserDefaults.standard.set(token, forKey: "twitch_access_token")
                NotificationCenter.default.post(name: .didCompleteLogin, object: nil)
                self.onTokenReceived?(token)
            }
            
            let htmlData: Data
            if let fileUrl = Bundle.main.url(forResource: "login_success", withExtension: "html"),
               let dataFromFile = try? Data(contentsOf: fileUrl) {
                htmlData = dataFromFile
            } else {
                htmlData = """
                <html><body><h1>login successful! you can close this tab.</h1></body></html>
                """.data(using: .utf8)!
            }
            
            let header = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: \(htmlData.count)\r\n\r\n"
            guard let headerData = header.data(using: .utf8) else {
                connection.cancel()
                return
            }
            let fullResponse = headerData + htmlData
            
            connection.send(content: fullResponse, completion: .contentProcessed({ _ in
                print("response sent. scheduling server shutdown...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    self.stop()
                }
                connection.cancel()
            }))
        }
    }
    
    private func extractAccessToken(from requestLine: String) -> String? {
        let parts = requestLine.components(separatedBy: " ")
        guard parts.count > 1 else { return nil }
        let pathAndQuery = parts[1]
        guard let urlComponents = URLComponents(string: "http://dummy\(pathAndQuery)"),
              let queryItems = urlComponents.queryItems else { return nil }
        return queryItems.first(where: { $0.name == "access_token" })?.value
    }
}

extension Data {
    static func + (lhs: Data, rhs: Data) -> Data {
        var data = lhs
        data.append(rhs)
        return data
    }
}
