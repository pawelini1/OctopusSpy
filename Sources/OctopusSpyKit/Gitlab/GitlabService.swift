import Foundation
import Promises

class GitlabService {
    enum GitlabServiceError: Error {
        case couldNotCreateURLRequest(Error)
        case connectionError(Error)
        case parsingError
    }
    
    private let requestBuilder: GitLabURLRequestsBuilder
    private let jsonDecoder: JSONDecoder
    private let urlSession: URLSession
    
    init(requestBuilder: GitLabURLRequestsBuilder,
         jsonDecoder: JSONDecoder = JSONDecoderFactory.default.projectsJSONDecoder(),
         urlSession: URLSession = .shared) {
        self.requestBuilder = requestBuilder
        self.jsonDecoder = jsonDecoder
        self.urlSession = urlSession
    }
    
    func projects(for configuration: [ProjectConfiguration], filter: MergeRequestsFilter) -> [Promise<Project>] {
        return configuration.map { project(for: $0, filter: filter) }
    }

    func project(for configuration: ProjectConfiguration, filter: MergeRequestsFilter) -> Promise<Project> {
        let promise = Promise<Project>.pending()
        do {
            var mergeRequests = try self.mergeRequests(for: configuration.id).resolveOrThrow()
            if let authors = configuration.authors {
                mergeRequests = mergeRequests.filter({ authors.contains($0.author.username) })
            }
            let approvers = try mergeRequests.map({ self.approvers(for: $0.id, in: configuration.id) }).resolveOrThrow()
            zip(mergeRequests, approvers).forEach { $0.0.approvers = $0.1 }
            let notIgnoredMergeRequests = mergeRequests.filter(filter.shouldInclude)
            promise.fulfill(Project(id: configuration.id, name: configuration.name, mergeRequests: notIgnoredMergeRequests))
        } catch {
            promise.reject(error)
        }
        return promise
    }
    
    private func mergeRequests(for projectId: ProjectId) throws -> Promise<[MergeRequest]> {
        let promise = Promise<[MergeRequest]>.pending()
        do {
            let urlRequest = try requestBuilder.makeMergeRequestsRequest(for: projectId)
            let task = try urlSession.codableTask(with: urlRequest, decoder: jsonDecoder) { (mergeRequests: [MergeRequest]?, response, error) in
                if let error = error {
                    promise.reject(error)
                    return
                }
                guard let mergeRequests = mergeRequests else {
                    promise.reject(GitlabServiceError.parsingError)
                    return
                }
                promise.fulfill(mergeRequests)
            }
            task.resume()
        } catch {
            promise.reject(error)
        }
        return promise
    }
    
    private func approvers(for mergeRequestId: MergeRequestId, in projectId: ProjectId) -> Promise<Approvers> {
        let promise = Promise<Approvers>.pending()
        do {
            let urlRequest = try requestBuilder.makeApproversRequest(for: mergeRequestId, in: projectId)
            let task = try urlSession.codableTask(with: urlRequest, decoder: jsonDecoder) { (approvers: Approvers?, response, error) in
                if let error = error {
                    promise.reject(error)
                    return
                }
                guard let approvers = approvers else {
                    promise.reject(GitlabServiceError.parsingError)
                    return
                }
                promise.fulfill(approvers)
            }
            task.resume()
        } catch {
            promise.reject(error)
        }
        return promise
    }
}
