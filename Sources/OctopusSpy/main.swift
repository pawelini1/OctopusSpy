import Foundation
import ArgumentParser
import OctopusSpyKit

struct AccessOptions: ParsableArguments {
    @Option(name: .long, help: "A token to authenticate with Slack API")
    var slackToken: String?
    
    @Option(name: .long, help: "A token to authenticate with Gitlab API")
    var gitlabToken: String?
    
    @Option(name: .long, help: "A base URL for Gitlab API. Default: https://gitlab.com/api/v4/")
    var gitlabAPI: String?
}

struct UpdateOptions: ParsableArguments {
    @Flag(name: .shortAndLong, help: "Cleans up the channel history before the update")
    var cleanup = false
    
    @Option(name: .long, help: "A identifier of the Slack bot used to send messages")
    var slackBotId: String?
    
    @Option(name: .long, help: "A number of hours to consider merge request as overdue")
    var hoursToOverdue: Int?
}

struct OctopusSpyApp: ParsableCommand {
    enum Error: Swift.Error {
        case missingValue(String)
    }
    
    struct Lint: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Verifies the content of provided spyfile")
        
        @Argument(help: "A path to a spyfile")
        var path: Path

        @OptionGroup var accessOptions: AccessOptions
        
        mutating func run() {
            do {
                let linter = Linter()
                try linter.lintFile(at: path,
                                    with: try lintContext(slackToken: accessOptions.slackToken,
                                                          gitlabToken: accessOptions.gitlabToken,
                                                          gitlabAPI: accessOptions.gitlabAPI))
                print("OctopusSpy finished linting successfully...".green)
            } catch {
                print("OctopusSpy finished linting with an error...".red)
                Self.exit(withError: error)
            }
        }
    }
    
    struct LintAllIn: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Verifies the content of all spyfiles in provided directory")
        
        @Argument(help: "A path to a directory with spyfiles")
        var path: Path

        @OptionGroup var accessOptions: AccessOptions

        mutating func run() {
            do {
                let linter = Linter()
                try linter.lintFolder(at: path,
                                      with: try lintContext(slackToken: accessOptions.slackToken,
                                                            gitlabToken: accessOptions.gitlabToken,
                                                            gitlabAPI: accessOptions.gitlabAPI))
                print("OctopusSpy finished linting successfully...".green)
            } catch {
                print("OctopusSpy finished linting with an error...".red)
                Self.exit(withError: error)
            }
        }
    }
    
    struct Update: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Updates the status of merge requests according to provided spyfile")
        
        @Argument(help: "A path to a spyfile")
        var path: Path

        @OptionGroup var accessOptions: AccessOptions
        @OptionGroup var updateOptions: UpdateOptions

        mutating func run() {
            do {
                let updater = Updater()
                try updater.updateFile(at: path,
                                       with: try updateContext(slackToken: accessOptions.slackToken,
                                                               gitlabToken: accessOptions.gitlabToken,
                                                               gitlabAPI: accessOptions.gitlabAPI,
                                                               cleanHistory: updateOptions.cleanup,
                                                               slackBotId: updateOptions.slackBotId))
                print("OctopusSpy finished updating successfully...".green)
            } catch {
                print("OctopusSpy finished updating with an error...".red)
                Self.exit(withError: error)
            }
        }
    }
    
    struct UpdateAllIn: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Updates the status of merge requests according to all spyfiles in provided directory")

        @Argument(help: "A path to a directory with spyfiles")
        var path: Path

        @OptionGroup var accessOptions: AccessOptions
        @OptionGroup var updateOptions: UpdateOptions

        mutating func run() {
            do {
                let updater = Updater()
                try updater.updateFolder(at: path,
                                         with: try updateContext(slackToken: accessOptions.slackToken,
                                                                 gitlabToken: accessOptions.gitlabToken,
                                                                 gitlabAPI: accessOptions.gitlabAPI,
                                                                 cleanHistory: updateOptions.cleanup,
                                                                 slackBotId: updateOptions.slackBotId))
                print("OctopusSpy finished updating successfully...".green)
            } catch {
                print("OctopusSpy finished updating with an error...".red)
                Self.exit(withError: error)
            }
        }
    }
    
    static var configuration = CommandConfiguration(
        commandName: "octopusspy",
        abstract: "A utility for managing merge requests in the projects.",
        version: "0.0.1",
        subcommands: [
            Lint.self, LintAllIn.self,
            Update.self, UpdateAllIn.self
        ]
    )
}
    
DispatchQueue.promises = DispatchQueue.global(qos: .background)

OctopusSpyApp.main()
