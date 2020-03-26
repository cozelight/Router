import Foundation

open class Router: RouterProtocol {

    public static let shared = Router()

    private var matcher = URLMatcher()
    private var handlerQueue = DispatchQueue(label: "com.Router.handlerQueue")

    private var asyncTypeHandlers = [URLPattern: Any]()

    init() {
        
    }

    public func register<ContextType>(
        _ key: RouterKey<ContextType>,
        middles: [RouterKeyable],
        handler: @escaping RouterAsyncTypeHandler<ContextType>
    ) {

        let model = RouterHandlerModel(middleKeys: middles, handler: handler)

        handlerQueue.async { [unowned self] in
            self.asyncTypeHandlers[key.key] = model
        }
    }

    public func open(url: URLConvertible, context: Any?, resultHandler: ResultHandler?) {
        guard let finalHandleModel = findHandlerModel(url: url) else {
            resultHandler?(.failure(.urlNotFound))
            return
        }

        commonOpen(finalHandleModel: finalHandleModel, url: url, context: context) { middleResult in
            switch middleResult {
            case .success:
                finalHandleModel.asyncHandler(
                    url, context,
                    { result in
                        resultHandler?(result)
                    })
            case .failure(let err):
                resultHandler?(.failure(err))
            }
        }
    }

    public func open<ContextType>(_ key: RouterKey<ContextType>, context: ContextType?, resultHandler: ResultHandler?) {
        guard let finalHandleModel = findHandlerModel(key: key) else {
            resultHandler?(.failure(.urlNotFound))
            return
        }
        let fakeUrl = key.key
        commonOpen(finalHandleModel: finalHandleModel, url: fakeUrl, context: context) { middleResult in
            switch middleResult {
            case .success:
                finalHandleModel.typeHandler(
                    fakeUrl, context,
                    { result in
                        resultHandler?(result)
                    })
            case .failure(let err):
                resultHandler?(.failure(err))
            }
        }
    }

}

//MARK: - Private
extension Router {
    
    private func findHandlerModel<ContextType>(key: RouterKey<ContextType>) -> RouterHandlerModel<ContextType>? {
        return findHandlerModel(url: key.key) as? RouterHandlerModel<ContextType>
    }
    
    private func findHandlerModel(url: URLConvertible) -> RouterHandlerModelable? {
        guard let match = matcher.match(url, from: Array(asyncTypeHandlers.keys)),
            let model = asyncTypeHandlers[match.pattern] as? RouterHandlerModelable
        else {
            return nil
        }

        return model
    }

    private func commonOpen(
        finalHandleModel: RouterHandlerModelable,
        url: URLConvertible,
        context: Any?,
        middleFinalHandler: @escaping ResultHandler
    ) {
        let middleHandlers = finalHandleModel.middleKeys.flatMap {
            middleHandlerModel(currentModelKey: $0)
        }

        recursion(middleHandlers: middleHandlers, url: url, context: context, middleFinalHandler: middleFinalHandler)
    }
    
    private func middleHandlerModel(currentModelKey: RouterKeyable) -> [RouterHandlerModelable] {
        guard let currentModel = findHandlerModel(url: currentModelKey.key) else {
            return []
        }

        var rs = [RouterHandlerModelable]()
        let subMiddle = currentModel.middleKeys.flatMap {
            middleHandlerModel(currentModelKey: $0)
        }
        rs.append(contentsOf: subMiddle)
        rs.append(currentModel)
        return rs
    }

    private func recursion(
        middleHandlers: [RouterHandlerModelable],
        url: URLConvertible,
        context: Any?,
        middleFinalHandler: @escaping ResultHandler
    ) {

        guard let middleHandler = middleHandlers.first else {
            middleFinalHandler(.success(""))
            return
        }

        middleHandler.asyncHandler(
            url, context,
            { [weak self] result in
                switch result {
                case .success:
                    let middleHandlers = Array(middleHandlers.dropFirst())
                    self?.recursion(middleHandlers: middleHandlers, url: url, context: context, middleFinalHandler: middleFinalHandler)
                case .failure(let err):
                    middleFinalHandler(.failure(err))
                }
            })

    }
}
