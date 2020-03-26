import Foundation

public enum RouterError: Error {
    case middleNotFount
    case middleError
    case urlNotFound
    case paramsError
}

public typealias URLPattern = String

public protocol RouterProtocol {

    /// - SeeAlso: `func register<ContextType>(_ key: RouterKey<ContextType>,
    ///                                      middles: [RouterKeyable],
    ///                                      handler: @escaping RouterAsyncTypeHandler<ContextType>)`
    func register<ContextType>(
        _ key: RouterKey<ContextType>,
        handler: @escaping RouterAsyncTypeHandler<ContextType>
    )

    /// 注册 key 及对应的回调事件，支持中间件（中间件也需要注册）
    /// - Parameters:
    ///   - key: 注册Key
    ///   - middles: 中间件列表，从左至右直行，中途 failure 则整体 failure
    ///   - handler: 回调事件
    func register<ContextType>(
        _ key: RouterKey<ContextType>,
        middles: [RouterKeyable],
        handler: @escaping RouterAsyncTypeHandler<ContextType>
    )

    /// 通过 url or string 执行 open
    /// - Parameters:
    ///   - url: url or string
    ///   - context: 上下文参数对象
    ///   - resultHandler: 异步回调
    func open(url: URLConvertible, context: Any?, resultHandler: ResultHandler?)

    /// 通过 key 执行 open
    /// - Parameters:
    ///   - key: 已注册的 RouterKey
    ///   - context: 上下文参数对象, ConextType 与 key 类型关联
    ///   - resultHandler: 异步回调
    func open<ContextType>(_ key: RouterKey<ContextType>, context: ContextType?, resultHandler: ResultHandler?)
}

extension RouterProtocol {

    public func register<ContextType>(
        _ key: RouterKey<ContextType>,
        handler: @escaping RouterAsyncTypeHandler<ContextType>
    ) {
        register(key, middles: [], handler: handler)
    }

    public func open<ContextType>(_ key: RouterKey<ContextType>, context: ContextType? = nil, resultHandler: ResultHandler? = nil) {
        open(key, context: context, resultHandler: resultHandler)
    }

    public func open(url: URLConvertible, context: Any? = nil, resultHandler: ResultHandler? = nil) {
        open(url: url, context: context, resultHandler: resultHandler)
    }

}
