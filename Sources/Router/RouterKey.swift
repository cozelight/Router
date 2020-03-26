import Foundation

public protocol RouterKeyable {
    var key: String { get }
}

public struct RouterKey<ContextType>: RouterKeyable {
    public var key: String

    public init(_ key: String) {
        self.key = key
    }

}

public typealias RouterAsyncTypeHandler<ContextType> = (_ url: URLConvertible, _ context: ContextType?, @escaping ResultHandler) -> Void

public typealias RouterAsyncHandler = (_ url: URLConvertible, _ context: Any?, @escaping ResultHandler) -> Void

public typealias ResultHandler = (_ result: Result<String, RouterError>) -> Void

protocol RouterHandlerModelable {
    var asyncHandler: RouterAsyncHandler { get }
    var middleKeys: [RouterKeyable] { get }
}

struct RouterHandlerModel<ContextType>: RouterHandlerModelable {
    var asyncHandler: RouterAsyncHandler
    var typeHandler: RouterAsyncTypeHandler<ContextType>

    var middleKeys: [RouterKeyable] = []

    init(middleKeys: [RouterKeyable], handler: @escaping RouterAsyncTypeHandler<ContextType>) {
        self.asyncHandler = { url, any, resultHandler in
            handler(url, nil, resultHandler)
        }
        self.typeHandler = handler
        self.middleKeys = middleKeys
    }

}
