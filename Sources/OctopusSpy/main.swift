import Foundation
import ArgumentParser
import OctopusSpyKit

struct ContextOptions: ParsableArguments {
    @Option(name: .long, help: "A token to authenticate with Slack API")
    var slackToken: String?
    
    @Option(name: .long, help: "A token to authenticate with Gitlab API")
    var gitlabToken: String?
    
    @Option(name: .long, help: "A base URL for Gitlab API. Default: https://gitlab.com/api/v4/")
    var gitlabAPI: String?
}

struct OctopusSpyApp: ParsableCommand {
    enum Error: Swift.Error {
        case missingValue(String)
    }
    
    struct Lint: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Verifies the content of provided spyfile")
        
        @Argument(help: "A path to a spyfile")
        var path: Path

        @OptionGroup var options: ContextOptions
        
        mutating func run() {
            do {
                let linter = Linter()
                let context = try commandContext(slackToken: options.slackToken, gitlabToken: options.gitlabToken, gitlabAPI: options.gitlabAPI)
                try linter.lintFile(at: path, with: context)
                print("OctopusSpy finished linting successfully...".green)
            } catch {
                print("OctopusSpy finished linting with an error...".red)
                OctopusSpyApp.Lint.exit(withError: error)
            }
        }
    }
    
    struct LintDir: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Verifies the content of all spyfiles in provided directory")
        
        @Argument(help: "A path to a spyfile")
        var path: Path

        @OptionGroup var options: ContextOptions
        
        mutating func run() {
            do {
                let linter = Linter()
                let context = try commandContext(slackToken: options.slackToken, gitlabToken: options.gitlabToken, gitlabAPI: options.gitlabAPI)
                try linter.lintFolder(at: path, with: context)
                print("OctopusSpy finished linting successfully...".green)
            } catch {
                print("OctopusSpy finished linting with an error...".red)
                OctopusSpyApp.LintDir.exit(withError: error)
            }
        }
    }
    
    static var configuration = CommandConfiguration(
        commandName: "octopusspy",
        abstract: "A utility for managing merge requests in thwe projects.",
        version: "0.0.1",
        subcommands: [Lint.self, LintDir.self])
}
    
DispatchQueue.promises = DispatchQueue.global(qos: .background)

OctopusSpyApp.main()
