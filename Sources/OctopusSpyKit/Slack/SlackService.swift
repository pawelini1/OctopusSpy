import Foundation
import Promises

class SlackChannelService {
    enum SlackChannelServiceError: Error {
        case couldNotCreateURLRequest(Error)
        case connectionError(Error)
        case parsingError
        case requestReturnedError(String)
        case apiError(String?)
    }
    
    private let requestBuilder: SlackURLRequestsBuilder
    private let jsonDecoder: JSONDecoder
    private let urlSession: URLSession

    init(requestBuilder: SlackURLRequestsBuilder,
         jsonDecoder: JSONDecoder = JSONDecoderFactory.default.slackJSONDecoder(),
         urlSession: URLSession = .shared) {
        self.requestBuilder = requestBuilder
        self.jsonDecoder = jsonDecoder
        self.urlSession = urlSession
    }
    
    func history(fromChannel channel: String, limit: Int) -> Promise<ChannelHistory> {
        let promise = Promise<ChannelHistory>.pending()
        do {
            let urlRequest = try requestBuilder.makeHistoryRequest(inChannel: channel, limit: limit)
            let task = try urlSession.codableTask(with: urlRequest, decoder: jsonDecoder) { (slackResponse: ChannelHistory?, response, error) in
                if let error = error {
                    promise.reject(SlackChannelServiceError.connectionError(error))
                    return
                }
                guard let history = slackResponse else {
                    promise.reject(SlackChannelServiceError.parsingError)
                    return
                }
                guard history.ok else {
                    promise.reject(SlackChannelServiceError.requestReturnedError(history.error ?? "Unknown"))
                    return
                }
                promise.fulfill(history)
            }
            task.resume()
        } catch {
            promise.reject(error)
        }
        return promise
    }
    
    func delete(_ messageId: MessageId, fromChannel channel: String) -> Promise<SlackConfirmation> {
        let promise = Promise<SlackConfirmation>.pending()
        do {
            let urlRequest = try requestBuilder.makeDeleteRequest(inChannel: channel, for: messageId)
            let task = try urlSession.codableTask(with: urlRequest, decoder: jsonDecoder) { (slackResponse: SlackConfirmation?, response, error) in
                if let error = error {
                    promise.reject(SlackChannelServiceError.connectionError(error))
                    return
                }
                guard let response = slackResponse else {
                    promise.reject(SlackChannelServiceError.parsingError)
                    return
                }
                response.ok ? promise.fulfill(response) : promise.reject(SlackChannelServiceError.apiError(slackResponse?.error))
            }
            task.resume()
        } catch {
            promise.reject(error)
        }
        return promise
    }

    func post(_ attachment: Attachment, inChannel channel: String) -> Promise<SlackConfirmation> {
        let promise = Promise<SlackConfirmation>.pending()
        do {
            let urlRequest = try requestBuilder.makePostRequest(inChannel: channel, attachment: attachment)
            let task = try urlSession.codableTask(with: urlRequest, decoder: jsonDecoder) { (slackResponse: SlackConfirmation?, response, error) in
                if let error = error {
                    promise.reject(SlackChannelServiceError.connectionError(error))
                    return
                }
                guard let response = slackResponse else {
                    promise.reject(SlackChannelServiceError.parsingError)
                    return
                }
                response.ok ? promise.fulfill(response) : promise.reject(SlackChannelServiceError.apiError(slackResponse?.error))
            }
            task.resume()
        } catch {
            promise.reject(error)
        }
        return promise
    }

    func update(_ messageId: MessageId, attachment: Attachment, inChannel channel: String) -> Promise<SlackConfirmation> {
        let promise = Promise<SlackConfirmation>.pending()
        do {
            let urlRequest = try requestBuilder.makeUpdateRequest(inChannel: channel, messageId: messageId, attachment: attachment)
            let task = try urlSession.codableTask(with: urlRequest, decoder: jsonDecoder) { (slackResponse: SlackConfirmation?, response, error) in
                if let error = error {
                    promise.reject(SlackChannelServiceError.connectionError(error))
                    return
                }
                guard let response = slackResponse else {
                    promise.reject(SlackChannelServiceError.parsingError)
                    return
                }
                response.ok ? promise.fulfill(response) : promise.reject(SlackChannelServiceError.apiError(slackResponse?.error))
            }
            task.resume()
        } catch {
            promise.reject(error)
        }
        return promise
    }
}
