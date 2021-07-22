import Foundation

struct ChannelHistory: Codable {
    let ok: Bool
    let messages: [Message]?
    let hasMore: Bool?
    let pinCount: Int?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case ok, messages, error
        case hasMore = "has_more"
        case pinCount = "pin_count"
    }
}

typealias MessageId = String

struct Message: Codable {
    let text: String?
    let username, botId, subtype: String?
    let type: String
    let id: MessageId
    let attachments: [Attachment]?
    let user: String?
    
    enum CodingKeys: String, CodingKey {
        case text, username
        case botId = "bot_id"
        case id = "ts"
        case type, subtype, attachments, user
    }
}

extension Message {
    var title: String {
        return attachments?.first?.title ?? "No title"
    }
}

struct Attachment: Codable {
    let fallback, color, authorName: String?
    let authorLink: String?
    let title: String?
    let titleLink: String?
    let footer: String?
    let text: String?
    let ts: AttachmentTimestamp?
    
    init(fallback: String? = nil, color: String? = nil, authorName: String? = nil, authorLink: String? = nil, title: String? = nil, titleLink: String? = nil, footer: String? = nil, ts: AttachmentTimestamp? = nil, text: String? = nil) {
        self.fallback = fallback
        self.color = color
        self.authorName = authorName
        self.authorLink = authorLink
        self.title = title
        self.titleLink = titleLink
        self.footer = footer
        self.text = text
        self.ts = ts
    }
    
    enum CodingKeys: String, CodingKey {
        case fallback, color, text
        case authorName = "author_name"
        case authorLink = "author_link"
        case title
        case titleLink = "title_link"
        case footer, ts
    }
}

struct AttachmentTimestamp: Codable {
    let stringValue: String
    let intValue: Int?
    
    init(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let intValue = try container.decode(Int.self)
            self.intValue = intValue
            self.stringValue = "\(intValue)"
        } catch {
            self.stringValue = try container.decode(String.self)
            self.intValue = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        guard let intValue = self.intValue else {
            try container.encode(stringValue)
            return
        }
        try container.encode(intValue)
    }
}

struct SlackConfirmation: Codable {
    let ok: Bool
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case ok, error
    }
}

