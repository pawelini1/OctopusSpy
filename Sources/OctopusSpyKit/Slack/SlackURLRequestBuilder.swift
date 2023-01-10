import Foundation

class SlackURLRequestsBuilder {
    enum Error: Swift.Error {
        case wrongURLFormat(String)
        case couldNotEncodeAttachment(Attachment)
    }
    
    private let token: String
    private let timeoutInterval: TimeInterval
    private let attachmentEncoder: JSONEncoder
    
    init(token: String, timeoutInterval: TimeInterval = 5.0, attachmentEncoder: JSONEncoder = JSONEncoderFactory.default.attachmentJSONEncoder()) {
        self.token = token
        self.timeoutInterval = timeoutInterval
        self.attachmentEncoder = attachmentEncoder
    }
    
    func makeHistoryRequest(inChannel channel: String, limit: Int) throws -> URLRequest {
        return try urlRequest(
            with: "https://slack.com/api/conversations.history?channel=\(channel)&limit=\(limit)",
            token: token
        )
    }
    
    func makeDeleteRequest(inChannel channel: String, for messageId: MessageId) throws -> URLRequest {
        return try urlRequest(
            with: "https://slack.com/api/chat.delete?channel=\(channel)&ts=\(messageId)",
            token: token
        )
    }
    
    func makePostRequest(inChannel channel: String, attachment: Attachment) throws -> URLRequest {
        return try urlRequest(
            with: "https://slack.com/api/chat.postMessage?channel=\(channel)&attachments=\(try encodedAttachment(attachment))",
            token: token
        )
    }
    
    func makeUpdateRequest(inChannel channel: String, messageId: MessageId, attachment: Attachment) throws -> URLRequest {
        return try urlRequest(
            with: "https://slack.com/api/chat.update?channel=\(channel)&ts=\(messageId)&attachments=\(try encodedAttachment(attachment))",
            token: token
        )
    }
}

private extension SlackURLRequestsBuilder {
    func urlRequest(with urlString: String, token: String) throws -> URLRequest {
        guard let url = URL(string: urlString) else {
            throw Error.wrongURLFormat(urlString)
        }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutInterval)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func encodedAttachment(_ attachment: Attachment) throws -> String {
        guard let data = try? attachmentEncoder.encode([attachment]), let json = String(data: data, encoding: .utf8), let encoded = json.urlEncoded() else {
            throw Error.couldNotEncodeAttachment(attachment)
        }
        return encoded
    }
}
