import Files

class SingleSpyfileUpdateRunner {
    enum SingleSpyfileUpdateRunnerError: Error {
        case updatingFailed([Error])
    }
    
    private let spyfileProvider: SpyfileProvider
    private let slackInteractor: SlackInteractor
    private let gitlabInteractor: GitlabInteractor
    private let slackUpdater: SlackUpdater

    convenience init(context: UpdateContext) {
        let gitlabRequestBuilder = GitLabURLRequestsBuilder(token: context.gitlabToken, apiURL: context.gitlabAPIURL)
        let gitlabService = GitlabService(requestBuilder: gitlabRequestBuilder)
        let slackRequestBuilder = SlackURLRequestsBuilder(token: context.slackToken)
        let slackService = SlackChannelService(requestBuilder: slackRequestBuilder)
        let attachmentBuilder = AttachmentBuilder(hoursToOverdue: context.hoursToOverdue)
        self.init(spyfileProvider: DefaultSpyfileProvider(),
                  slackInteractor: SlackInteractor(channelService: slackService),
                  gitlabInteractor: GitlabInteractor(gitlabService: gitlabService),
                  slackUpdater: SlackProjectUpdater(builder: UpdateOperationsBuilder(slackBotId: context.slackBotId, builder: attachmentBuilder),
                                                    runner: UpdateOperationsRunner(service: slackService)))
    }
    
    init(spyfileProvider: SpyfileProvider,
         slackInteractor: SlackInteractor,
         gitlabInteractor: GitlabInteractor,
         slackUpdater: SlackUpdater) {
        self.spyfileProvider = spyfileProvider
        self.slackInteractor = slackInteractor
        self.gitlabInteractor = gitlabInteractor
        self.slackUpdater = slackUpdater
    }
    
    func run(withFile filePath: Path, shouldCleanUp: Bool, botId: String) -> Result<Void, Error> {
        let spyfile: Spyfile
        
        do {
            log.info("Started updating spyfile at path: \(filePath)").intend()
            spyfile = try spyfileProvider.spyfile(atPath: filePath)
        } catch {
            log.error("Failure parsing spyfile [\(error)]")
            return .failure(error)
        }
        
        if(shouldCleanUp) {
            do {
                log.info("Started cleaning up messages of [\(botId)] from channel [\(spyfile.slack.channel)]")
                try slackInteractor.deleteBotMessages(inChannel: spyfile.slack.channel, withUserId: botId)
                log.success("Cleanup completed")
            } catch {
                log.error("Failure cleaning up messages [\(error)]")
                return .failure(error)
            }
        }
        
        do {
            try slackInteractor.updateSlack(channel: spyfile.slack.channel,
                                            with: gitlabInteractor.projects(for: spyfile.projects,
                                                                            filter: DefaultMergeRequestsFilter(ignoreWIPs: spyfile.settings.ignoreWIPs)),
                                            using: slackUpdater)
            log.success("Success updating spyfile at path: \(spyfile.file.path)").back()
            return .success(())
        } catch {
            log.error("Failure updating spyfile at path: \(spyfile.file.path)").back()
            return .failure(error)
        }

    }
}

