//
//  RouterDemo.swift
//  Example
//
//  Created by ganzhen on 2020/3/26.
//  Copyright © 2020 ganzhen. All rights reserved.
//

import Foundation
import Router

class Account {
    static let current = Account()
    
    var isLogin = false
    
    func login() {
        isLogin = true
    }
    
    func logout() {
        isLogin = false
    }
}

public enum RouterDemo {
    
    public static func register() {
        
        //进行登录操作
        Router.shared.register(RouterKey.login) { url, _, resultHandler in
            Account.current.login()
            print("login success")
            resultHandler(.success("login success"))
        }
        
        //进行登出操作
        Router.shared.register(RouterKey.logout) { url, _, resultHandler in
            Account.current.logout()
            print("logout success")
            resultHandler(.success("logout success"))
        }
        
        //判断当前是否登录
        Router.shared.register(RouterKey.checkHasLogin) { url, _, resultHandler in
            let string = Account.current.isLogin ?"已登录" : "未登录"
            print(string)
            resultHandler(.success(string))
        }
        
        //先执行中间件checkHasLogin->checkAutoLogin
        //支持在RouterAsyncTypeHandler打开其他RouterKey
        Router.shared.register(RouterKey.checkAutoLogin, middles: [RouterKey.checkHasLogin]) { _, _, resultHandler in
            if Account.current.isLogin {
                print("账号已登录")
                resultHandler(.success("账号已登录"))
            } else {
                print("账号未登录， 开始登录")
                Router.shared.open(RouterKey.login) { result in
                    resultHandler(result)
                }
            }
        }
        
        //ContextType == UserDetailModel
        Router.shared.register(RouterKey.showUserDetailPage) { _, user, resultHandler in
            guard let user = user else {
                alert("show fail", "userDetailModel为空") {
                    resultHandler(.failure(.paramsError))
                }
                return
            }
            alert("show success", "id:\(user.id)") {
                resultHandler(.success("show success"))
            }
        }
        
        //middleHandler 嵌套,checkHasLogin->checkAutoLogin->showMinePage
        Router.shared.register(RouterKey.showMinePage, middles: [RouterKey.checkAutoLogin]) { _, _, resultHandler in
            alert("show/my_detail success", "my detail") {
                resultHandler(.success("show/my_detail"))
            }
        }
    }
    
    static func alert(_ tittle: String, _ message: String, _ completion: @escaping () -> Void) {
        let alert = UIAlertController(title: tittle, message: message, preferredStyle: .alert)

        alert.addAction(
            UIAlertAction(
                title: "OK", style: .default,
                handler: { _ in
                    completion()
                }))

        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
}
