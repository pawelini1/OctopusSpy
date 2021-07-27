import Files

class MultiSpyfileUpdateRunner {
    enum MultiSpyfileUpdateRunnerError: Error {
        case updatingFailed([Error])
        case couldNotLoadSpyfiles(Path)
    }

    private let context: UpdateContext
    
    init(context: UpdateContext) {
        self.context = context
    }
    
    func run(forDir dirPath: Path) -> Result<Void, Error> {
        log.info("Started updating multiple spyfiles at directory [\(dirPath)]").intend()
        guard let filePaths = try? Folder(path: dirPath).files.map({ $0.path }) else {
            log.back().error("Failure loading spyfiles from [\(dirPath)]")
            return .failure(MultiSpyfileUpdateRunnerError.couldNotLoadSpyfiles(dirPath))
        }
        let updater = SingleSpyfileUpdateRunner(context: context)
        let results: [Result<Void, Error>] = filePaths.map { path in
            return updater.run(withFile: path, shouldCleanUp: context.cleanHistory, botId: context.slackBotId)
        }
        let errors = results.compactMap { $0.error }
        if errors.count > 0 {
            log.back().error("Some updates failed for spyfiles at directory [\(dirPath)]")
            return .failure(MultiSpyfileUpdateRunnerError.updatingFailed(errors))
        } else {
            log.back().success("All updates successfull for spyfiles at directory [\(dirPath)]")
            return .success(())
        }
    }
}
