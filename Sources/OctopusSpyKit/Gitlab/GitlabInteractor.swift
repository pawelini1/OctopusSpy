import Promises

class GitlabInteractor {
    private let gitlabService: GitlabService
    
    init(gitlabService: GitlabService) {
        self.gitlabService = gitlabService
    }
    
    func testProjectAccessibility(for project: ProjectConfiguration) throws {
        let _ = try gitlabService.project(for: project).resolveOrThrow()
    }
}
