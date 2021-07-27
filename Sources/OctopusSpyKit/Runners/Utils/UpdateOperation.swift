import Foundation
import Promises

enum UpdateOperation {
    case add(ChannelId, Attachment)
    case update(ChannelId, MessageId, Attachment)
    case remove(ChannelId, MessageId)
}

extension UpdateOperation: CustomStringConvertible {
    var description: String {
        switch self {
        case .add(_, let attachment):
            return "add    [\(attachment.title ?? "No title")]"
        case .update(_, _, let attachment):
            return "update [\(attachment.title ?? "No title")]"
        case .remove(_, let mId):
            return "remove [\(mId)]"
        }
    }
}

class UpdateOperationsBuilder {
    private let slackBotId: String
    private let builder: AttachmentBuilder
    
    init(slackBotId: String, builder: AttachmentBuilder) {
        self.slackBotId = slackBotId
        self.builder = builder
    }
    
    func updateDescriptiors(history: ChannelHistory, inChannel channel: ChannelId, projects: [Project]) throws -> [UpdateOperation] {
        var descriptors = [UpdateOperation]()
        var messages = validMessages(history: history)
        try projects.forEach { project in
            try project.mergeRequests.forEach({ mergeRequest in
                let slackId = "\(project.id)/\(mergeRequest.id)"
                guard let index = messages.firstIndex(where: { $0.attachments?.first?.footer == slackId }) else {
                    descriptors.append(.add(channel, try builder.build(with: mergeRequest, in: project, messageId: nil)))
                    return
                }
                let message = messages[index]
                descriptors.append(.update(channel, message.id, try builder.build(with: mergeRequest, in: project, messageId: message.id)))
                messages.remove(at: index)
            })
        }
        messages.forEach { descriptors.append(.remove(channel, $0.id))}
        return descriptors
    }
    
    private func validMessages(history: ChannelHistory) -> [Message] {
        return history.messages?.filter { (message) -> Bool in
            return message.botId == slackBotId
        } ?? []
    }
}

class UpdateOperationsRunner {
    private var service: SlackChannelService
    
    init(service: SlackChannelService) {
        self.service = service
    }
    
    func run(_ operations: [UpdateOperation]) -> [Promise<SlackConfirmation>] {
        return operations.map { (operation) -> Promise<SlackConfirmation> in
            switch operation {
            case .add(let channelId, let attachment):
                return service.post(attachment, inChannel: channelId)
            case .update(let channelId, let messageId, let attachment):
                return service.update(messageId, attachment: attachment, inChannel: channelId)
            case .remove(let channelId, let messageId):
                return service.delete(messageId, fromChannel: channelId)
            }
        }
    }
}
