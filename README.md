# Router
支持中间件路由跳转

### 特性介绍

- 支持强类型传参，同时参数支持类型检查

- 支持中间件（预处理、预检查等），中间件可嵌套配置

### 使用说明

使用一般分三步

1. 定义 RouterKey，ContextType 为传参数据类型

```swift
// 1. 定义 RouterKey
extension RouterKey where ContextType == UserDetailModel {
  static let showUserDetailPage = RouterKey("show/user_detail")
  static let showMinePage = RouterKey("show/my_detail")
}
```

1. 注册 RouterKey

```swift
// 2. 注册 RouterKey
Router.register(RouterKey.showUserDetailPage) { url, user, resultHandler in
  if let userId = user?.id { // or let userId = url.query["id"]
    let vc = UserDetaiViewController()
    vc.user = user
    // push to vc
    resultHandler(.success(userId))
  } else {
    resultHandler(.failure(.paramsError))
  }
}
```

1. 调用

```swift
// 3. 调用 by RouterKey
let user: UserDetailModel = someUser
Router.open(RouterKey. showUserDetailPage, context: user)
// or 调用 by url
Router.open("show/user_detail?id=123")
```

### 进阶扩展

#### 背景

假设有两个 router key 定义：

- RouterKey.showMinePage 显示个人信息页面

- RouterKey.checkAndExecLogin 如果没有登录则显示登录界面，并返回登录结果

业务中常见需要 open(.showMinePage) 时，先检查登录状态，唤起登录界面后再执行显示个人页面的逻辑。这类预检查、预处理的逻辑都适合作为中间件处理。

如下简单声明 .showMineProfilePage 就可以实现具体业务逻辑与 AOP 逻辑解耦

```swift
Router.register(.showMinePage, 
        middle: [.checkAndExecLogin], 
        handle: { ... 显示个人页面逻辑 ... }
)
```

#### 设置思路

注册 key 与实际执行之间的关系：

| RouterKey | 对应执行 | 中间件配置   | 实际执行顺序 |
| --------- | -------- | ------------ | ------------ |
| keyA      | A        | []           | A            |
| keyB      | B        | []           | B            |
| keyC      | C        | [keyA, keyB] | A-B-C        |
| keyD      | D        | []           | D            |
| keyX      | X        | [keyD, keyC] | D-A-B-C-X    |

- 中间件执行过程中每一步返回 .sucess 则执行下一步，返回 .failure 则中断，立即结束。

- 目前为了让业务方理解方便，没有提供中间件传参、中断 fallback 处理等机制。（当前框架设计支持这些能力）