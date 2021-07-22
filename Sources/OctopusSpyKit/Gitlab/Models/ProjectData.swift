import Foundation

class Author: Codable {
    let name: String
    let username: String

    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}

typealias MergeRequestId = Int
typealias ApprovalId = Int

class User: Codable {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

class Approver: Codable {
    let user: User
    
    init(user: User) {
        self.user = user
    }
}

class Approvers: Codable {
    enum ApproversState: String {
        case new
        case inProgress
        case approved
    }
    
    let id: ApprovalId
    let required: Int
    let missing: Int
    let users: [Approver]
    var state: ApproversState {
        switch progress {
        case 0.0:
            return .new
        case 1.0:
            return .approved
        default:
            return .inProgress
        }
    }
    var received: Int { return required - missing }
    var names: [String] { return users.compactMap({ $0.user.name }) }
    private var progress: Double { return 1.0 - (Double(missing) / Double(required)) }
    
    init(id: ApprovalId, approversRequired: Int, approversMissing: Int, users: [Approver]) {
        self.id = id
        self.required = approversRequired
        self.missing = approversMissing
        self.users = users
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "iid"
        case required = "approvals_required"
        case missing = "approvals_left"
        case users = "approved_by"
    }
}

class MergeRequest: Codable {
    let id: MergeRequestId
    let title: String
    let created: Date
    let target: String
    let source: String
    let author: Author
    let url: String
    var approvers: Approvers! = nil
    
    init(id: MergeRequestId, title: String, created: Date, target: String, source: String, author: Author, url: String, approvers: Approvers) {
        self.id = id
        self.title = title
        self.created = created
        self.target = target
        self.source = source
        self.author = author
        self.url = url
        self.approvers = approvers
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "iid"
        case title
        case created = "created_at"
        case target = "target_branch"
        case source = "source_branch"
        case author
        case url = "web_url"
    }
}

class Project {
    let id: ProjectId
    let name: String
    let mergeRequests: [MergeRequest]
    
    init(id: ProjectId, name: String, mergeRequests: [MergeRequest]) {
        self.id = id
        self.name = name
        self.mergeRequests = mergeRequests
    }
}
