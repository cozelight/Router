//
//  ViewController.swift
//  Example
//
//  Created by ganzhen on 2020/3/26.
//  Copyright © 2020 ganzhen. All rights reserved.
//

import UIKit
import Router

struct Demo  {
    var key: RouterKey<Any>
}

class ViewController: UIViewController {

    let tableView = UITableView()
    
    /*
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
     */
    
    var demos: [Any] = [
        RouterKey.showMinePage,
        RouterKey.showUserDetailPage,
        RouterKey.login,
        RouterKey.logout,
        RouterKey.checkHasLogin,
        RouterKey.checkAutoLogin
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Router Demo"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "router")
        view.addSubview(tableView)
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var frame = view.bounds
        frame.origin.y = 100
        tableView.frame = frame
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        demos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "router")
        if let demo = demos[indexPath.row] as? RouterKey<UserDetailModel> {        
            cell.textLabel?.text = demo.key
        }
        if let demo = demos[indexPath.row] as? RouterKey<None> {        
            cell.textLabel?.text = demo.key
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let resultHandler: ResultHandler = { result in
            switch result {
            case .success(let s):
                print("resultHandler success: \(s)")
            case .failure(let err):
                print("resultHandler failure: \(err)")
            }
        }
        if let demo = demos[indexPath.row] as? RouterKey<UserDetailModel> {   
            let user = UserDetailModel(id: "test_user")
            Router.shared.open(demo, context: user, resultHandler: resultHandler)
        }
        if let demo = demos[indexPath.row] as? RouterKey<None> {        
            Router.shared.open(demo, resultHandler: resultHandler)
        }
    }
}

