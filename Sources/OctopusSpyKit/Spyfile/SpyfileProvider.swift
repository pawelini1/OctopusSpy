import Foundation
import Files

protocol SpyfileProvider {
    func spyfile(atPath filePath: String) throws -> Spyfile
    func spyfiles(inDirectory dirPath: String) throws -> [Spyfile]
}

class DefaultSpyfileProvider: SpyfileProvider {
    private let parser: SpyfileParser
    
    init(parser: SpyfileParser = YAMLSpyfileParser()) {
        self.parser = parser
    }
    
    func spyfile(atPath filePath: String) throws -> Spyfile {
        let file = try File(path: filePath)
        return try parser.spyfile(withFile: file)
    }
    
    func spyfiles(inDirectory dirPath: String) throws -> [Spyfile] {
        let dir = try Folder(path: dirPath)
        return try dir.files.map { file in
            return try parser.spyfile(withFile: file)
        }
    }
}
