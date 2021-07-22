import Promises

class SlackInteractor {
    private let channelService: SlackChannelService
    
    init(channelService: SlackChannelService) {
        self.channelService = channelService
    }
    
    func testSlackAccessibility(forChannel channel: String) throws {
        let _ = try channelHistory(ofChannel: channel, limit: 1).resolveOrThrow()
    }
}

private extension SlackInteractor {
    func channelHistory(ofChannel channel: String, limit: Int) -> Promise<ChannelHistory> {
        return channelService.history(fromChannel: channel, limit: limit)
    }
}
