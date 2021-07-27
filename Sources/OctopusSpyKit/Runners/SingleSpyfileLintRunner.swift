import Files

class SingleSpyfileLintRunner {
    enum SingleSpyfileLintRunnerError: Error {
        case lintingFailed([Error])
    }
    
    private let spyfileProvider: SpyfileProvider
    private let slackInteractor: SlackInteractor
    private let gitlabInteractor: GitlabInteractor

    convenience init(context: LintContext) {
        let gitlabRequestBuilder = GitLabURLRequestsBuilder(token: context.gitlabToken, apiURL: context.gitlabAPIURL)
        let gitlabService = GitlabService(requestBuilder: gitlabRequestBuilder)
        let slackRequestBuilder = SlackURLRequestsBuilder(token: context.slackToken)
        let slackService = SlackChannelService(requestBuilder: slackRequestBuilder)
        
        self.init(spyfileProvider: DefaultSpyfileProvider(),
                  slackInteractor: SlackInteractor(channelService: slackService),
                  gitlabInteractor: GitlabInteractor(gitlabService: gitlabService))
    }
    
    init(spyfileProvider: SpyfileProvider,
         slackInteractor: SlackInteractor,
         gitlabInteractor: GitlabInteractor) {
        self.spyfileProvider = spyfileProvider
        self.slackInteractor = slackInteractor
        self.gitlabInteractor = gitlabInteractor
    }
    
    func run(forPath filePath: Path) -> Result<Void, Error> {
        let spyfile: Spyfile
        
        // Test spyfile parsing
        do {
            log.info("Started linting spyfile at path: \(filePath)").intend()
            spyfile = try spyfileProvider.spyfile(atPath: filePath)
            log.success("Spyfile structure valid")
        } catch {
            log.error("Failure parsing spyfile [\(error)]")
            // Return immediately, because there's no point in testing the rest without proper spyfile.
            return .failure(error)
        }
        
        var errors = [Error]()

        // Test Slack connectivity
        do {
            try slackInteractor.testSlackAccessibility(forChannel: spyfile.slack.channel)
            log.success("Slack channel [\(spyfile.slack.channel)] configured properly")
        } catch {
            log.error("Failure accessing Slack channel [\(spyfile.slack.channel)] [\(error)]")
            errors.append(error)
        }

        // Test each project connectivity
        spyfile.projects.forEach { project in
            do {
                try gitlabInteractor.testProjectAccessibility(for: project)
                log.success("Project [\(project.id)] configured properly")
            } catch {
                log.error("Failure accessing project [\(project.id)] [\(error)]")
                errors.append(error)
            }
        }

        if errors.count > 0 {
            log.error("Some tests failed for spyfile at path: \(filePath)").back()
            return .failure(SingleSpyfileLintRunnerError.lintingFailed(errors))
        }
        log.success("All tests successfull for spyfile at path: \(filePath)").back()
        return .success(())
    }
}

