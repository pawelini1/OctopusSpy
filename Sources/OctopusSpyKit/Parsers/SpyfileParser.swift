import Foundation
import Files

protocol SpyfileParser {
    func spyfile(withFile file: File) throws -> Spyfile
}

struct SpyfileStructure: Codable {
    struct Slack: Codable {
        struct Bot: Codable {
            let id: String
            let token: String
        }
        let channelId: ChannelId
        let bot: Bot?
    }
    
    struct Repository: Codable {
        let name: String
        let authors: [String]?
    }
    
    struct Settings: Codable {
        let ignoreWIPs: Bool?
    }
    
    let slack: Slack
    let settings: Settings?
    let repositories: [String: Repository]
}

extension SpyfileStructure {
    func slackConfiguration() -> SlackChannelConfiguration {
        return SlackChannelConfiguration(channel: slack.channelId)
    }
    
    func projectConfigurations() -> [ProjectConfiguration] {
        return repositories.keys.map({
            let repository = repositories[$0]
            return ProjectConfiguration(id: $0, name: repository?.name, authors: repository?.authors)
        })
    }
    
    func settingsConfigurations() -> AppSettings {
        let ignoreWIPs = settings?.ignoreWIPs ?? false
        return AppSettings(ignoreWIPs: ignoreWIPs)
    }
}
