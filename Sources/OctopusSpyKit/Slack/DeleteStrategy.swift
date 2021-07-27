import Foundation

protocol DeleteStrategy {
    func shouldDelete(_ message: Message) -> Bool
}

enum MessagesDeleteStrategy {
    case postedByBot(String)
    case all
}

extension MessagesDeleteStrategy: DeleteStrategy {
    func shouldDelete(_ message: Message) -> Bool {
        switch self {
        case .all:
            return true
        case .postedByBot(let botId):
            return message.botId == botId
        }
    }
}
