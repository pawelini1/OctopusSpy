import Foundation

public struct Context {
    public let slackToken: String
    public let gitlabToken: String
    public let gitlabAPIURL: URL

    public init(slackToken: String, gitlabToken: String, gitlabAPIURL: URL) {
        self.slackToken = slackToken
        self.gitlabToken = gitlabToken
        self.gitlabAPIURL = gitlabAPIURL
    }
}

public enum ContextError: Swift.Error {
    case missingValue(String)
}

public func commandContext(slackToken: String? = nil, gitlabToken: String? = nil, gitlabAPI: String? = nil) throws -> Context {
    guard let slackToken = slackToken ?? env(.slackToken) else {
        throw ContextError.missingValue("Slack access token missing. Use --slack-token option or provide it through the \(EnvVariable.slackToken) environment variable")
    }
    guard let gitlabToken = gitlabToken ?? env(.gitlabToken) else {
        throw ContextError.missingValue("Gitlab access token missing. Use --gitlab-token option or provide it through the \(EnvVariable.gitlabToken) environment variable")
    }
    guard let gitlabAPIURLString = gitlabAPI ?? env(.gitlabAPIURL), let gitlabAPIURL = URL(string: gitlabAPIURLString) else {
        throw ContextError.missingValue("Gitlab API URL missing or invalid. Use --gitlab-api option or provide it through the \(EnvVariable.gitlabAPIURL) environment variable")
    }
    return Context(slackToken: slackToken, gitlabToken: gitlabToken, gitlabAPIURL: gitlabAPIURL)
}
