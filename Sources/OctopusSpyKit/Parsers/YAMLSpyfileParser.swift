import Files
import Yams

class YAMLSpyfileParser: SpyfileParser {
    enum YAMLSpyfileParserError: Swift.Error {
        case innerError(Error)
        case wrongFormat(String)
        
        var localizedDescription: String {
            switch self {
            case .innerError(let error):
                return error.localizedDescription
            case .wrongFormat(let entry):
                return "Wrong format for entry: \(entry)"
            }
        }
    }
    
    func spyfile(withFile file: File) throws -> Spyfile {
        do {
            let decoder = YAMLDecoder()
            let yamlSpyfile = try decoder.decode(SpyfileStructure.self, from: try file.readAsString())
            return Spyfile(projects: yamlSpyfile.projectConfigurations(),
                           slack: yamlSpyfile.slackConfiguration(),
                           settings: yamlSpyfile.settingsConfigurations(),
                           file: file)
        } catch {
            throw YAMLSpyfileParserError.innerError(error)
        }
    }
}
