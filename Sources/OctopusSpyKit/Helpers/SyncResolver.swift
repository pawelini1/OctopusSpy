import Foundation
import Promises

protocol SyncResolver {
    associatedtype ResolvedType
    
    @discardableResult
    func resolveOrThrow() throws -> ResolvedType
}

extension Promise: SyncResolver {
    @discardableResult
    func resolveOrThrow() throws -> Value {
        let resolver = ReturnValueResolver<Value>()
        observe {
            $0.onSuccess(execute: { (value) in
                resolver.return(value)
            })
            $0.onFailure(execute: { (error) in
                resolver.throw(error)
            })
        }
        return try resolver.resolveOrThrow()
    }
}

extension Result: SyncResolver {
    @discardableResult
    func resolveOrThrow() throws -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}

protocol Observable {
    associatedtype ElementType
    
    func observe(with callback: @escaping (Result<ElementType, Error>) -> Void)
}

extension Promise: Observable {
    func observe(with callback: @escaping (Result<Value, Error>) -> Void) {
        self.then { value in
            callback(.success(value))
        }.catch { error in
            callback(.failure(error))
        }
    }
}

extension Array: SyncResolver where Element: Observable {
    @discardableResult
    func resolveOrThrow() throws -> [Element.ElementType] {
        let resolver = ReturnValueArrayResolver<Element.ElementType>(size: count)
        enumerated().forEach {
            let index = $0.offset
            $0.element.observe {
                $0.onSuccess(execute: { (value) in
                    resolver.return(value, at: index)
                })
                $0.onFailure(execute: { (error) in
                    resolver.throw(error)
                })
            }
        }
        return try resolver.resolveOrThrow()
    }
}

class ReturnValueResolver<T>: SyncResolver {
    private let group = DispatchGroup()
    private var value: T!
    private var error: Error?
    
    init() {
        self.group.enter()
    }
    
    func `return`(_ value: T) {
        self.value = value
        group.leave()
    }
    
    func `throw`(_ error: Error) {
        self.error = error
        group.leave()
    }
    
    @discardableResult
    func resolveOrThrow() throws -> T {
        group.wait()
        try error.flatMap { throw $0 }
        return value
    }
}

class ReturnValueArrayResolver<T>: SyncResolver {
    private let group = DispatchGroup()
    private var values: [T?]
    private var error: Error?
    private var pendingElementsCount: Int = 0
    
    init(size: Int) {
        precondition(size >= 0, "Size should always be non-negative value.")
        self.pendingElementsCount = size
        self.values = [T?](repeating: nil, count: size)
        if size > 0 { group.enter() }
    }
    
    func `return`(_ value: T, at index: Int) {
        values[index] = value
        pendingElementsCount -= 1
        if pendingElementsCount == 0 { group.leave() }
    }
    
    func `throw`(_ error: Error) {
        guard self.error == nil else { return }
        self.error = error
        if pendingElementsCount > 0 { group.leave() }
    }
    
    @discardableResult
    func resolveOrThrow() throws -> [T] {
        group.wait()
        try error.flatMap { throw $0 }
        return values.compactMap({ $0 })
    }
}
