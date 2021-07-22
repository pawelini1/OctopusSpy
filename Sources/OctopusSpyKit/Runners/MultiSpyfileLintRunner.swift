import Files

class MultiSpyfileLintRunner: ActionRunner {
    enum MultiSpyfileLintRunnerError: Error {
        case lintingFailed([Error])
        case couldNotLoadSpyfiles(Path)
    }
    private let dirPath: Path
    private let context: Context
    
    init(dirPath: Path, context: Context) {
        self.dirPath = dirPath
        self.context = context
    }
    
    func run() -> Result<Void, Error> {
        log.info("Started linting multiple spyfiles at directory [\(dirPath)]").intend()
        guard let filePaths = try? Folder(path: dirPath).files.map({ $0.path }) else {
            log.back().error("Failure loading spyfiles from [\(dirPath)]")
            return .failure(MultiSpyfileLintRunnerError.couldNotLoadSpyfiles(dirPath))
        }
        let results: [Result<Void, Error>] = filePaths.map { path in
            let runner = SingleSpyfileLintRunner(filePath: path, context: context)
            return runner.run()
        }
        let errors = results.compactMap { $0.error }
        if errors.count > 0 {
            log.back().error("Some tests failed for spyfiles at directory [\(dirPath)]")
            return .failure(MultiSpyfileLintRunnerError.lintingFailed(errors))
        } else {
            log.back().success("All tests successfull for spyfiles at directory [\(dirPath)]")
            return .success(())
        }
    }
}
