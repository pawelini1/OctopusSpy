import Promises

class GitlabInteractor {
    private let gitlabService: GitlabService
    
    init(gitlabService: GitlabService) {
        self.gitlabService = gitlabService
    }
    
    func testProjectAccessibility(for project: ProjectConfiguration) throws {
        let _ = try gitlabService.project(for: project, filter: AcceptAllMergeRequestsFilter()).resolveOrThrow()
    }
    
    func projects(for projects: [ProjectConfiguration], filter: MergeRequestsFilter) throws -> [Project] {
        return try gitlabService.projects(for: projects, filter: filter).resolveOrThrow()
    }
}
