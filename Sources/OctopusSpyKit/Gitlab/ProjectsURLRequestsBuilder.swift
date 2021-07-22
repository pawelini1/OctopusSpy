import Foundation

class GitLabURLRequestsBuilder {
    enum Error: Swift.Error {
        case unableToURLEncode(String)
        case wrongURLFormat(String)
    }
    
    private let token: String
    private let apiURL: URL
    private let timeoutInterval: TimeInterval
    
    init(token: String, apiURL: URL, timeoutInterval: TimeInterval = 5.0) {
        self.token = token
        self.apiURL = apiURL
        self.timeoutInterval = timeoutInterval
    }
    
    func makeMergeRequestsRequest(for projectId: ProjectId) throws -> URLRequest {
        guard let projectIdEncoded = projectId.urlEncoded() else {
            throw Error.unableToURLEncode(projectId)
        }
        return try urlRequest(with: apiURL
                                .appendingPercentEncodedPath("projects/\(projectIdEncoded)/merge_requests")
                                .appendingQueryItems(["state": "opened"]))
    }
    
    func makeApproversRequest(for mergeRequestId: MergeRequestId, in projectId: ProjectId) throws -> URLRequest {
        guard let projectIdEncoded = projectId.urlEncoded() else {
            throw Error.unableToURLEncode(projectId)
        }
        return try urlRequest(with: apiURL
                                .appendingPercentEncodedPath("projects/\(projectIdEncoded)/merge_requests/\(mergeRequestId)/approvals"))
    }
}

private extension GitLabURLRequestsBuilder {
    func urlRequest(with url: URL) throws -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutInterval)
        request.setValue(token, forHTTPHeaderField: "PRIVATE-TOKEN")
        return request
    }
}
