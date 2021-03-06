import Foundation

protocol MergeRequestsFilter {
    func shouldInclude(_ mergeRequest: MergeRequest) -> Bool
}

class DefaultMergeRequestsFilter: MergeRequestsFilter {
    private let ignoreWIPs: Bool
    
    init(ignoreWIPs: Bool) {
        self.ignoreWIPs = ignoreWIPs
    }
    
    func shouldInclude(_ mergeRequest: MergeRequest) -> Bool {
        guard mergeRequest.title.lowercased().contains("#spy-include") == false else { return true }
        guard mergeRequest.title.lowercased().contains("#spy-ignore") == false else { return false }
        guard ignoreWIPs == false || ["wip:", "draft:"].filter({ mergeRequest.title.lowercased().starts(with: $0) }).isEmpty else { return false }
        return true
    }
}

class AcceptAllMergeRequestsFilter: MergeRequestsFilter {
    func shouldInclude(_ mergeRequest: MergeRequest) -> Bool { return true }
}
