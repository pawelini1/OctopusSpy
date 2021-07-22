import Foundation

public struct Linter {
    public init() {}
    
    public func lintFolder(at path: Path, with context: Context) throws {
        return try MultiSpyfileLintRunner(dirPath: path, context: context).run().resolveOrThrow()
    }
    
    public func lintFile(at path: Path, with context: Context) throws {
        return try SingleSpyfileLintRunner(filePath: path, context: context).run().resolveOrThrow()
    }
}


