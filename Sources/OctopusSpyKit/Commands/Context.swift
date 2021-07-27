import Foundation

public protocol AccessContext {
    var slackToken: String { get }
    var gitlabToken: String { get }
    var gitlabAPIURL: URL { get }
}

public protocol SlackContext {
    var cleanHistory: Bool { get }
    var slackBotId: String { get }
}

public protocol MergeRequestsContext {
    var hoursToOverdue: Int { get }
}

public typealias LintContext = AccessContext
public typealias UpdateContext = AccessContext & SlackContext & MergeRequestsContext

struct ParsedAccessContext: AccessContext {
    let slackToken: String
    let gitlabToken: String
    let gitlabAPIURL: URL
}

struct ParsedSlackContext: SlackContext {
    let cleanHistory: Bool
    let slackBotId: String
}

struct ParsedMergeRequestsContext: MergeRequestsContext  {
    let hoursToOverdue: Int
}

struct ParsedUpdateContext: UpdateContext {
    let accessContext: AccessContext
    let slackContext: SlackContext
    let mergeRequestsContext: MergeRequestsContext
    
    var gitlabToken: String { accessContext.gitlabToken }
    var gitlabAPIURL: URL { accessContext.gitlabAPIURL }
    var slackBotId: String { slackContext.slackBotId }
    var slackToken: String { accessContext.slackToken }
    var cleanHistory: Bool { slackContext.cleanHistory }
    var hoursToOverdue: Int { mergeRequestsContext.hoursToOverdue }

    init(accessContext: AccessContext, slackContext: SlackContext, mergeRequestsContext: MergeRequestsContext) {
        self.accessContext = accessContext
        self.slackContext = slackContext
        self.mergeRequestsContext = mergeRequestsContext
    }
}

struct Defaults {
    static let hoursToOverdue: Int = 3 * 24
}

public enum ContextError: Swift.Error {
    case missingValue(String)
    case couldNotDetermineValue
}

public func lintContext(slackToken: String? = nil, gitlabToken: String? = nil, gitlabAPI: String? = nil) throws -> LintContext {
    return try accessContext(slackToken: slackToken, gitlabToken: gitlabToken, gitlabAPI: gitlabAPI)
}

public func updateContext(slackToken: String? = nil, gitlabToken: String? = nil, gitlabAPI: String? = nil, cleanHistory: Bool = false, slackBotId: String? = nil, hoursToOverdue: Int? = nil) throws -> UpdateContext {
    return ParsedUpdateContext(accessContext: try accessContext(slackToken: slackToken,
                                                                gitlabToken: gitlabToken,
                                                                gitlabAPI: gitlabAPI),
                               slackContext: try slackContext(cleanHistory: cleanHistory,
                                                              slackBotId: slackBotId),
                               mergeRequestsContext: try mergeRequestsContext(hoursToOverdue: hoursToOverdue))
}

func accessContext(slackToken: String? = nil, gitlabToken: String? = nil, gitlabAPI: String? = nil) throws -> AccessContext {
    guard let slackToken = slackToken ?? env(.slackToken) else {
        throw ContextError.missingValue("Slack access token missing. Use --slack-token option or provide it through the \(EnvVariable.slackToken) environment variable")
    }
    guard let gitlabToken = gitlabToken ?? env(.gitlabToken) else {
        throw ContextError.missingValue("Gitlab access token missing. Use --gitlab-token option or provide it through the \(EnvVariable.gitlabToken) environment variable")
    }
    guard let gitlabAPIURLString = gitlabAPI ?? env(.gitlabAPIURL), let gitlabAPIURL = URL(string: gitlabAPIURLString) else {
        throw ContextError.missingValue("Gitlab API URL missing or invalid. Use --gitlab-api option or provide it through the \(EnvVariable.gitlabAPIURL) environment variable")
    }
    return ParsedAccessContext(slackToken: slackToken, gitlabToken: gitlabToken, gitlabAPIURL: gitlabAPIURL)
}

func slackContext(cleanHistory: Bool = false, slackBotId: String? = nil) throws -> SlackContext {
    guard let slackBotId = slackBotId ?? env(.slackBotId) else {
        throw ContextError.missingValue("Slack Bot identifer missing. Use --slack-bot-id option or provide it through the \(EnvVariable.slackBotId) environment variable")
    }
    return ParsedSlackContext(cleanHistory: cleanHistory, slackBotId: slackBotId)
}

func mergeRequestsContext(hoursToOverdue: Int? = nil) throws -> MergeRequestsContext {
    return ParsedMergeRequestsContext(hoursToOverdue: try firstValueSatisfying(for: [
        { hoursToOverdue },
        {
            guard let hoursToOverdueValue = env(.hoursToOverdue) else { return nil }
            guard let hoursToOverdue = Int(hoursToOverdueValue) else {
                throw ContextError.missingValue("Hours to overdue parameter is invalid. Use --hour-to-overdue option or provide it through the \(EnvVariable.hoursToOverdue) environment variable")
            }
            return hoursToOverdue
        },
        { Defaults.hoursToOverdue }
    ]))
}

func firstValueSatisfying<T>(for resolvers: [() throws -> T?]) throws -> T {
    for resolver in resolvers {
        guard let value = try resolver() else { continue }
        return value
    }
    throw ContextError.couldNotDetermineValue
}
