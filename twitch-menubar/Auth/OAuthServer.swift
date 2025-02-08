import Foundation
import Network

class OAuthServer {
    let port: NWEndpoint.Port = 8080
    var listener: NWListener?

    func start() {
        do {
            listener = try NWListener(using: .tcp, on: port)
            listener?.newConnectionHandler = { connection in
                connection.start(queue: .main)
                self.handleConnection(connection)
            }
            listener?.start(queue: .main)
            print("OAuth server started on http://localhost:\(port)/callback")
        } catch {
            print("Failed to start OAuth server: \(error)")
        }
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 2048) { data, _, _, _ in
            if let data = data, let request = String(data: data, encoding: .utf8) {
                print("Received request:\n\(request)")

                guard let firstLine = request.components(separatedBy: .newlines).first,
                      firstLine.contains("GET /callback?") else {
                    connection.cancel()
                    return
                }

                if let token = self.extractAccessToken(from: firstLine) {
                    UserDefaults.standard.set(token, forKey: "twitch_access_token")
                    NotificationCenter.default.post(name: .didCompleteLogin, object: nil)
                }

                let htmlResponse = self.loadHTML()

                // Send HTTP response
                connection.send(content: htmlResponse.data(using: .utf8), completion: .contentProcessed({ _ in
                    connection.cancel()
                }))
            }
        }
    }

    private func extractAccessToken(from request: String) -> String? {
        guard let range = request.range(of: "access_token=([^&]+)", options: .regularExpression) else { return nil }
        return String(request[range])
    }

    private func loadHTML() -> String {
        if let url = Bundle.main.url(forResource: "login_success", withExtension: "html"),
           let html = try? String(contentsOf: url) {
            return "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n\(html)"
        } else {
            return "HTTP/1.1 500 Internal Server Error\r\nContent-Type: text/html\r\n\r\n<h1>Failed to load page.</h1>"
        }
    }
}
