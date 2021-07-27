import Foundation

protocol SlackUpdater {
    func updateSlack(channel channelId: ChannelId, with history: ChannelHistory, with projects: [Project]) throws
}

class SlackProjectUpdater: SlackUpdater {
    private let builder: UpdateOperationsBuilder
    private let runner: UpdateOperationsRunner
    
    init(builder: UpdateOperationsBuilder, runner: UpdateOperationsRunner) {
        self.builder = builder
        self.runner = runner
    }
    
    func updateSlack(channel channelId: ChannelId, with history: ChannelHistory, with projects: [Project]) throws {
        let updateDescriptors = try builder.updateDescriptiors(history: history, inChannel: channelId, projects: projects)
        try runner.run(updateDescriptors).resolveOrThrow()
    }
}
