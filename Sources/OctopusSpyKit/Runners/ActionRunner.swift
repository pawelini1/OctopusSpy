import Foundation

protocol ActionRunner {
    func run() -> Result<Void, Error>
}
