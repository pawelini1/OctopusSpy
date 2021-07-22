import Foundation
import Files

typealias ProjectId = String

struct ProjectConfiguration {
    let id: ProjectId
    let name: String
    let authors: [String]?
    
    init(id: ProjectId, name: String? = nil, authors: [String]? = nil) {
        self.id = id
        self.name = name ?? id
        self.authors = authors
    }
}

struct SlackBotConfiguration {
    let id: String
    let token: String
    
    init(id: String, token: String) {
        self.id = id
        self.token = token
    }
}

struct SlackChannelConfiguration {
    let channel: String

    init(channel: String) {
        self.channel = channel
    }
}

struct AppSettings {
    let ignoreWIPs: Bool
    
    init(ignoreWIPs: Bool) {
        self.ignoreWIPs = ignoreWIPs
    }
}

struct Spyfile {
    let projects: [ProjectConfiguration]
    let slack: SlackChannelConfiguration
    let settings: AppSettings
    let file: File
    
    init(projects: [ProjectConfiguration], slack: SlackChannelConfiguration, settings: AppSettings, file: File) {
        self.projects = projects
        self.slack = slack
        self.settings = settings
        self.file = file
    }
}
