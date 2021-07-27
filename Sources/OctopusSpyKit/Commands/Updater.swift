import Foundation

public struct Updater {
    public init() {}
    
    public func updateFolder(at path: Path, with context: UpdateContext) throws {
        return try MultiSpyfileUpdateRunner(context: context).run(forDir: path).resolveOrThrow()
    }
    
    public func updateFile(at path: Path, with context: UpdateContext) throws {
        return try SingleSpyfileUpdateRunner(context: context).run(withFile: path, shouldCleanUp: context.cleanHistory, botId: context.slackBotId).resolveOrThrow()
    }
}
