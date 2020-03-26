//
//  RouterKeyDefines.swift
//  Example
//
//  Created by ganzhen on 2020/3/26.
//  Copyright © 2020 ganzhen. All rights reserved.
//

import Foundation
import Router

struct UserDetailModel {
    var id: String
}

struct None {}

// show page
extension RouterKey where ContextType == UserDetailModel {
    static let showMinePage = RouterKey("show/my_detail")
    static let showUserDetailPage = RouterKey("show/user_detail")
}

extension RouterKey where ContextType == None {
    static let login = RouterKey("login")
    static let logout = RouterKey("logout")
}

// check
extension RouterKey where ContextType == None {
    static let checkHasLogin = RouterKey("check/has_login")
    static let checkAutoLogin = RouterKey("check/auto_login")
}
