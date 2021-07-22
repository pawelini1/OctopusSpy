import Foundation

func env(_ key: EnvVariable) -> String? {
    ProcessInfo.processInfo.environment[key]
}

typealias EnvVariable = String

extension EnvVariable {
    static var slackToken = "OCTOPUSSPY_SLACK_TOKEN"
    static var gitlabToken = "OCTOPUSSPY_GITLAB_TOKEN"
    static var gitlabAPIURL = "OCTOPUSSPY_GITLAB_API_URL"
}
