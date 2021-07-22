import Foundation

class JSONEncoderFactory {
    static let `default`: JSONEncoderFactory = JSONEncoderFactory()
    
    func attachmentJSONEncoder() -> JSONEncoder {
        return JSONEncoder()
    }
}
