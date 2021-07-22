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
        return try urlRequest(with: "https://slack.com/api/conversations.history?token=\(token)&channel=\(channel)&limit=\(limit)")
    }
    
    func makeDeleteRequest(inChannel channel: String, for messageId: MessageId) throws -> URLRequest {
        return try urlRequest(with: "https://slack.com/api/chat.delete?token=\(token)&channel=\(channel)&ts=\(messageId)")
    }
    
    func makePostRequest(inChannel channel: String, attachment: Attachment) throws -> URLRequest {
        return try urlRequest(with: "https://slack.com/api/chat.postMessage?token=\(token)&channel=\(channel)&attachments=\(try encodedAttachment(attachment))")
    }
    
    func makeUpdateRequest(inChannel channel: String, messageId: MessageId, attachment: Attachment) throws -> URLRequest {
        return try urlRequest(with: "https://slack.com/api/chat.update?token=\(token)&channel=\(channel)&ts=\(messageId)&attachments=\(try encodedAttachment(attachment))")
    }
}

private extension SlackURLRequestsBuilder {
    func urlRequest(with urlString: String) throws -> URLRequest {
        guard let url = URL(string: urlString) else {
            throw Error.wrongURLFormat(urlString)
        }
        return URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutInterval)
    }
    
    func encodedAttachment(_ attachment: Attachment) throws -> String {
        guard let data = try? attachmentEncoder.encode([attachment]), let json = String(data: data, encoding: .utf8), let encoded = json.urlEncoded() else {
            throw Error.couldNotEncodeAttachment(attachment)
        }
        return encoded
    }
}
