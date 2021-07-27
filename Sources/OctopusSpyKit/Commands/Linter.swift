import Foundation

public struct Linter {
    public init() {}
    
    public func lintFolder(at path: Path, with context: LintContext) throws {
        return try MultiSpyfileLintRunner(context: context).run(forDir: path).resolveOrThrow()
    }
    
    public func lintFile(at path: Path, with context: LintContext) throws {
        return try SingleSpyfileLintRunner(context: context).run(forPath: path).resolveOrThrow()
    }
}


