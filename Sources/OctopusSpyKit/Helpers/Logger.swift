import Foundation
import Rainbow

public var log = Logger()

public class Logger {
    private var intendLength = 2
    private var currentOffset: Int = 0
    
    @discardableResult
    public func intend() -> Logger {
        currentOffset += intendLength
        return self
    }
    
    @discardableResult
    public func back() -> Logger {
        currentOffset -= intendLength
        return self
    }

    @discardableResult
    public func text(_ message: String, offset: Int = 0) -> Logger {
        print(message)
        return self
    }
    
    @discardableResult
    public func info(_ message: String, offset: Int = 0) -> Logger {
        print("> \(message)")
        return self
    }
    
    @discardableResult
    public func success(_ message: String, offset: Int = 0) -> Logger {
        print("✓ \(message)".green)
        return self
    }
    
    @discardableResult
    public func error(_ message: String, offset: Int = 0) -> Logger {
        print("𐄂 \(message)".red)
        return self
    }
    
    private func print(_ string: String) {
        Swift.print(String(repeating: " ", count: currentOffset) + string)
    }
}
