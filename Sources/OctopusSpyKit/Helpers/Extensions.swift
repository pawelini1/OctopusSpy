import Foundation

public typealias Path = String

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
    
    var error: Error? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }
    
    func onSuccess(execute: (Success) throws -> Void) rethrows {
        switch self {
        case .success(let wrapped):
            try execute(wrapped)
        case .failure:
            return
        }
    }
    
    func onFailure(execute: (Error) throws -> Void) rethrows {
        switch self {
        case .success:
            return
        case .failure(let error):
            try execute(error)
        }
    }
}

enum URLResponseError: Error {
    case invalidHTTPResponse(URLResponse?)
    case missingOrInvalidResponseData
    case invalidStatusCode(Int)
    case couldNotParseResponse(String?)
}

extension URLSession {
    func codableTask<T: Codable>(with urlRequest: URLRequest, decoder: JSONDecoder, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask {
        return self.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                log.error(self.debuggingMessage(for: urlRequest, error: error))
                completionHandler(nil, response, error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                log.error(self.debuggingMessage(for: urlRequest, error: URLResponseError.invalidHTTPResponse(response)))
                completionHandler(nil, response, URLResponseError.invalidHTTPResponse(response))
                return
            }
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                log.error(self.debuggingMessage(for: urlRequest, error: URLResponseError.missingOrInvalidResponseData))
                completionHandler(nil, response, URLResponseError.missingOrInvalidResponseData)
                return
            }
            do {
                guard 200...299 ~= httpResponse.statusCode else {
                    log.error(self.debuggingMessage(for: urlRequest, responseString: responseString, statusCode: httpResponse.statusCode))
                    completionHandler(nil, response, URLResponseError.invalidStatusCode(httpResponse.statusCode))
                    return
                }
                let object = try decoder.decode(T.self, from: data)
                completionHandler(object, response, nil)
            }
            catch {
                log.error(self.debuggingMessage(for: urlRequest, responseString: responseString, statusCode: httpResponse.statusCode))
                completionHandler(nil, response, URLResponseError.couldNotParseResponse(responseString))
            }
        }
    }
    
    private func debuggingMessage(for urlRequest: URLRequest, responseString: String, statusCode: Int) -> String {
        return "Request for \(simplifiedURL(for: urlRequest)) finished with status code \(statusCode) and response \(responseString)"
    }
    
    private func debuggingMessage(for urlRequest: URLRequest, error: Error) -> String {
        return "Request for \(simplifiedURL(for: urlRequest)) finished with error [\(error)]"
    }
    
    private func simplifiedURL(for urlRequest: URLRequest) -> String {
        guard let url = urlRequest.url, let scheme = url.scheme, let host = url.host else { return "UNDEFINED" }
        return "\(scheme)://\(host)\(url.path)"
    }
}

extension String {
    func lines() -> [String] {
        return components(separatedBy: .newlines)
    }
    func trimmedWhitespaces() -> String {
        return trimmingCharacters(in: .whitespaces)
    }
    func notEmpty() -> String? {
        return isEmpty ? nil : self
    }
    func words() -> [String] {
        return components(separatedBy: .whitespaces)
    }
    func urlEncoded() -> String? {
        return addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    }
}

extension URL {
    init(staticString: StaticString) {
        self.init(string: "\(staticString)")!
    }    
    
    enum Error: Swift.Error {
        case unableToGetURLComponents(URL)
        case unableToCreateURL(URLComponents)
    }
    
    func appendingPercentEncodedPath(_ path: String) throws -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            throw Error.unableToGetURLComponents(self)
        }
        components.percentEncodedPath += path
        guard let url = components.url else {
            throw Error.unableToCreateURL(components)
        }
        return url
    }
    
    func appendingQueryItems(_ queryItems: [String: String]) throws -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            throw Error.unableToGetURLComponents(self)
        }
        components.queryItems = components.queryItems ?? []
        queryItems.forEach { element in
            defer {
                components.queryItems?.append(URLQueryItem(name: element.key, value: element.value))
            }
            guard let index = components.queryItems?.firstIndex(where: { $0.name == element.key }) else {
                return
            }
            components.queryItems?.remove(at: index)
        }
        guard let url = components.url else {
            throw Error.unableToCreateURL(components)
        }
        return url
    }
}
