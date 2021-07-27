import Promises

class SlackInteractor {
    struct Constants {
        static let defaultMessageCount = 100
    }
    
    private let channelService: SlackChannelService
    
    init(channelService: SlackChannelService) {
        self.channelService = channelService
    }
    
    func updateSlack(channel channelId: ChannelId, with projects: [Project], using slackUpdater: SlackUpdater) throws {
        try slackUpdater.updateSlack(channel: channelId,
                                     with: try channelHistory(ofChannel: channelId, limit: Constants.defaultMessageCount).resolveOrThrow(),
                                     with: projects)
    }
    
    func deleteBotMessages(inChannel channelId: ChannelId, withUserId botId: String) throws {
        try cleanup(channel: channelId,
                    withHistory: try channelHistory(ofChannel: channelId, limit: Constants.defaultMessageCount).resolveOrThrow(),
                    strategy: MessagesDeleteStrategy.postedByBot(botId)).resolveOrThrow()
    }
    
    func testSlackAccessibility(forChannel channelId: ChannelId) throws {
        let _ = try channelHistory(ofChannel: channelId, limit: 1).resolveOrThrow()
    }
}

private extension SlackInteractor {
    func channelHistory(ofChannel channelId: ChannelId, limit: Int) -> Promise<ChannelHistory> {
        return channelService.history(fromChannel: channelId, limit: limit)
    }
    
    func cleanup(channel channelId: ChannelId, withHistory history: ChannelHistory, strategy: DeleteStrategy) -> [Promise<SlackConfirmation>] {
        guard let messages = history.messages, messages.count > 0 else {
            return []
        }
        return messages.filter({ strategy.shouldDelete($0) }).compactMap({ self.channelService.delete($0.id, fromChannel: channelId) })
    }
}
