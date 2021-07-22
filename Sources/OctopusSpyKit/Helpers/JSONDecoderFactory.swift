import Foundation

class JSONDecoderFactory {
    static let `default`: JSONDecoderFactory = JSONDecoderFactory()
    
    func projectsJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatterFactory.default.iso8601DateFormatter())
        return decoder
    }
    
    func slackJSONDecoder() -> JSONDecoder {
        return JSONDecoder()
    }
}
