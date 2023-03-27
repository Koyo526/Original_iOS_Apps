//
//  SearchViewController.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/14.
//

import UIKit
import NCMB
import PKHUD

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, SearchTableViewCellDelegate {
    
    var selectedUser: NCMBUser?
    var posts = [Post]()
    var users = [NCMBUser]()
    var followingUseIds = [String]()
    var followings = [NCMBUser]()
    var searchBar: UISearchBar!
    
    
    @IBOutlet var searchTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearchBar()
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        loadFollowingUsers()
        
        let nib = UINib(nibName: "SearchTableViewCell", bundle: Bundle.main)
        searchTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        searchTableView.tableFooterView = UIView()
        
        searchTableView.rowHeight = 44
        
        guard let currentUser = NCMBUser.current() else {
       //ログアウト成功
        let storyboard = UIStoryboard(name: "Login", bundle: Bundle.main)
        let rootViewController = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        UIApplication.shared.keyWindow?.rootViewController = rootViewController
                                      
        //ログイン状態の保持
        let ud = UserDefaults.standard
        ud.set(false, forKey: "isLogin")
        ud.synchronize()
                   
        return
       }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setSearchBar()
        loadUsers(searchText: nil)
    }
    
    func setSearchBar() {
        //NavigationaBarにSearchBarをセット
        //NavigationBarの大きさを変数に入れている
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            //frameの後にnavigationBarの大きさを入れることでsearchBarの大きさを決めている
            let searchBar:UISearchBar = UISearchBar(frame: navigationBarFrame)
            //UISearchBarDelegateを書いたことによる関数の通知をこのcontrollerで受け取るため
            searchBar.delegate = self
            searchBar.placeholder = "ユーザーを検索"
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            //navigationItem.titleViewのところに表示
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
            
        }
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadUsers(searchText: nil)
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadUsers(searchText: searchBar.text)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SearchTableViewCell
        
        let userImageUrl = "https://mbaas.api.nifcloud.com/2013-09-01/applications/nxRHcfc3A1AOsQjK/publicFiles/" + users[indexPath.row].objectId
        cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder-300x300.jpg"), options: nil, progressBlock: nil, completionHandler: nil)
        cell.userImageView.layer.cornerRadius = cell.userImageView.frame.size.width / 2.0
        
        cell.userNameLabel.text = users[indexPath.row].object(forKey: "userName") as? String
        
       //followボタンを機能させる
        cell.tag = indexPath.row
        //自分で作ったSearchTableViewViewCellDelegate
        cell.delegate = self
        
        if followingUseIds.contains(users[indexPath.row].objectId) == true {
            //UIbuttonを無効化
            cell.followingButton.isEnabled = false
            cell.followingButton.setTitle("フォローしました", for: .normal)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      //self.performSegue(withIdentifier: "toUser", sender: nil)
      // 選択状態の解除
        tableView.deselectRow(at: indexPath, animated: true)
          }
    
    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton) {
        var userName = users[tableViewCell.tag].object(forKey: "userName") as? String
        let message = userName! + "をフォローしますか？"
        let alert = UIAlertController(title: "フォロー", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.follow(selectedUser: self.users[tableViewCell.tag])
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    func follow(selectedUser: NCMBUser) {
        let object = NCMBObject(className: "Follow")
        if let currentUser = NCMBUser.current() {
            object?.setObject(currentUser, forKey: "user")
            object?.setObject(selectedUser, forKey: "following")
            object?.saveInBackground({ (error) in
                if error != nil {
                    HUD.flash(.labeledError(title: "Error", subtitle: nil))
                } else {
                    self.loadUsers(searchText: nil)
                    //self.searchTableView.reloadData()
                }
            })
        } else {
            //nilの場合
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
            //UIWindowにアクセス
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            //ログインしない保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
    }
    func loadUsers(searchText: String?) {
        let query = NCMBUser.query()
        //自分を除外
        query?.whereKey("objectId", notEqualTo: NCMBUser.current()?.objectId)
        //退会済みのアカウントを除外
        query?.whereKey("active", notEqualTo: false)
        //検索あり
        if let text = searchText {
            print(text)
            query?.whereKey("userName", equalTo: text)
        }
        query?.limit = 50
        query?.order(byDescending: "createDate")
        
            query?.findObjectsInBackground({ (result, error)  in
                if error != nil {
                    HUD.flash(.labeledError(title: "Error", subtitle: nil))
                } else {
                    self.users = result as! [NCMBUser]
                    
                    self.loadFollowingUsers()
                }
            })
        }
    func loadFollowingUsers() {
        let query = NCMBQuery(className: "Follow")
        query?.includeKey("user")
        query?.includeKey("following")
        query?.whereKey("user", equalTo: NCMBUser.current())
        
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                HUD.flash(.labeledError(title: "Error", subtitle: nil))
            } else {
                self.followingUseIds = [String]()
                for following in result as! [NCMBObject] {
                    let user = following.object(forKey: "following") as! NCMBUser
                    
                    self.followingUseIds.append(user.objectId)
                    
                }
                self.searchTableView.reloadData()
            }
        })
    }
}
    
    


