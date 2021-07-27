import Foundation

class AttachmentBuilder {
    enum AttachmentBuilderError: Swift.Error {
        case invalidData(String)
    }
    
    private let hoursToOverdue: Int
    
    init(hoursToOverdue: Int) {
        self.hoursToOverdue = hoursToOverdue
    }
    
    func build(with mergeRequest: MergeRequest, in project: Project, messageId: String?) throws -> Attachment {
        guard let approvers = mergeRequest.approvers else {
            throw AttachmentBuilderError.invalidData("Missing approvers data.")
        }
        return Attachment(fallback: mergeRequest.title,
                          color: mergeRequest.hexColorString(hoursToOverdue: hoursToOverdue),
                          authorName: "\(project.name) - \(mergeRequest.author.name)",
                          authorLink: mergeRequest.url,
                          title: mergeRequest.title,
                          titleLink: mergeRequest.url,
                          footer: project.id+"/\(mergeRequest.id)",
                          ts: AttachmentTimestamp(intValue: mergeRequest.created.timeIntervalSince1970.timestamp),
                          text: "Approvals [\(approvers.received)/\(approvers.required)]: \(approvers.names.count > 0 ? approvers.names.joined(separator: ", ") : "-")")
    }
}

extension MergeRequest {
    func hexColorString(hoursToOverdue: Int) -> String {
        guard approvers.state != .approved else {
            return approvers.hexColorString()
        }
        guard let hoursWaiting = Date().hours(sinceDate: created), hoursWaiting < hoursToOverdue else {
            return "#d9534e"
        }
        return approvers.hexColorString()
    }
}

extension Approvers {
    func hexColorString() -> String {
        switch state {
        case .approved:
            return "#5cb85c"
        case .inProgress:
            return "#f0ad4e"
        case .new:
            return "#5bc0de"
        }
    }
}
