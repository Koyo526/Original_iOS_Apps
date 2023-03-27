//
//  ViewController.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/04.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD
import NCMB
import Kingfisher
import SwiftDate



class ViewController: UIViewController,UITableViewDataSource ,UITableViewDelegate, TimelineTableViewCellDelegate {
    
    var posts = [Post]()
   
    var selectedPost: Post?
    
    var selectedUser: NCMBUser?
    
    var followings = [NCMBUser]()
    
    var users = [NCMBUser]()
    
    var blockUserArray = [NCMBUser]()
    
    
    
    @IBOutlet var timelineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTimeline()
        loadFollowingUsers()
        loadBlockedUsers()
        
        timelineTableView.dataSource = self
        timelineTableView.delegate = self
        
        timelineTableView.tableFooterView = UIView()
        //ここに読み込む
        
        timelineTableView.rowHeight = 706
        
        setRefreshControl()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
      //  loadFollowingUsers()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            let commentViewController = segue.destination as! CommentViewController
        
            print(selectedPost?.objectId)
            commentViewController.postId = selectedPost?.objectId as! String
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(posts.count)
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("posts = ", posts)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimelineTableViewCell
        
        cell.delegate = self
        cell.tag = indexPath.row
        let user = posts[indexPath.row].user
        print(user)
        //ユーザー名の表示
        if user.displayName != "" {
            cell.userNameLabel.text = user.displayName
        } else {
            cell.userNameLabel.text = "表示名なし"
        }
        
        let userObjectId = user.objectId
        let userImageUrl = "https://mbaas.api.nifcloud.com/2013-09-01/applications/nxRHcfc3A1AOsQjK/publicFiles/" + userObjectId
        //ユーザー画像の設定
        cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named:"DefaultImage.jpeg"),options: nil,progressBlock: nil)
        //投稿文面の表示
        cell.postTextView.text = posts[indexPath.row].text
        let imageUrl = posts[indexPath.row].imageUrl
        //投稿画像の表示
        cell.photoImageView.kf.setImage(with: URL(string: imageUrl))
        cell.cosmosView.rating = posts[indexPath.row].ratingScore
        cell.cosmosLabel.text = posts[indexPath.row].rating

        //いいね(Like)によってハートの表示を変える
        if posts[indexPath.row].isLiked == false {
        cell.likeButton.setImage(UIImage(named: "icons8-いいね-@2x.png"),for: .normal)
        } else {
        cell.likeButton.setImage(UIImage(named: "icons8-red-heart-@2x.png"),for: .normal)
        }
        
        //いいね(Like)の数
        cell.likeCountLabel.text = "\(posts[indexPath.row].likeCount)件"
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd HH:mm"
        let date = posts[indexPath.row].createDate as! Date
        cell.timestampLabel.text = df.string(from: date)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //選択状態の解除
        tableView.deselectRow(at: indexPath, animated: true)
    }


    
    
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
        guard let currentUser = NCMBUser.current() else {
            //ログアウト成功
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            //ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(true,forKey: "isLogin")
            ud.synchronize()
            return
        }
        //let likeUsers = posts[tableViewCell.tag].object(forKey: "likeUser")as? [String]
        
        if posts[tableViewCell.tag].isLiked == false || posts[tableViewCell.tag].isLiked == nil {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(NCMBUser.current().objectId, forKey: "likeUser")
                post?.saveEventually({ (error) in
                    if error != nil {
                        HUD.show(.labeledError(title: error!.localizedDescription, subtitle: nil))
                    } else {
                        self.loadTimeline()
                    }
                })
            })
        } else {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    HUD.show(.labeledError(title: error!.localizedDescription, subtitle: nil))
                } else {
                    post?.removeObjects(in: [NCMBUser.current().objectId], forKey: "likeUser")
                    post?.saveEventually({ (error) in
                        if error != nil {
                            HUD.show(.labeledError(title: error!.localizedDescription, subtitle: nil))
                        } else {
                            self.loadTimeline()
                        }
                    })
                }
            })
        }
    }
    
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        //選ばれた投稿を一時的に格納
        selectedPost = posts[tableViewCell.tag]
        //遷移させる（このとき、prepareForSegue関数で値を渡す）
        self.performSegue(withIdentifier: "toComments", sender: nil)
    }
    
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        let selectedPostUser = posts[tableViewCell.tag].user
        if selectedPostUser.objectId == NCMBUser.current()?.objectId {
            //ログインユーザーの投稿を削除する一連の流れ
            let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
                //読み込みを表すUI
                HUD.show(.progress)
                let query = NCMBQuery(className: "Post")
                query?.getObjectInBackground(withId: self.posts[tableViewCell.tag].objectId, block: { (post, error) in
                    if error != nil {
                        HUD.show(.labeledError(title: error!.localizedDescription, subtitle: nil))
                    } else {
                        //取得した投稿オブジェクトを削除
                        post?.deleteInBackground({ (error) in
                            if error != nil {
                                HUD.show(.labeledError(title: error!.localizedDescription, subtitle: nil))
                            } else {
                                //再読み込み
                                self.loadTimeline()
                                //読み込み(HUD)を直ちに消去する
                                HUD.hide(animated: true)
                                
                            }
                        })
                    }
                })
            }
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
        } else {
            //ログインユーザーじゃない（他人）の投稿を管理者へ報告するときの一連の流れ
            let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
                let object = NCMBObject(className: "Report")
                object?.setObject(self.posts[tableViewCell.tag], forKey: "reportedPost")
                object?.setObject(NCMBUser.current(), forKey: "user")
                object?.setObject("投稿", forKey: "type")
                HUD.show(.labeledSuccess(title: "この投稿を報告しました。ご協力ありがとうございました。", subtitle: nil))
                
            }
            let blockAction = UIAlertAction(title: "ブロックする", style: .destructive) { (action) in
                let selectedUser = self.posts[tableViewCell.tag].user
               // self.block(selectedUser: selectedUser)
                
                HUD.show(.labeledSuccess(title: "この投稿のユーザーをブロックしました。", subtitle: nil))
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(blockAction)
            alertController.addAction(reportAction)
            alertController.addAction(cancelAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func block(selectedUser: NCMBUser) {
        let object = NCMBObject(className: "Block")
        if let currentUser = NCMBUser.current() {
            object?.setObject(currentUser, forKey: "user")
            object?.setObject(selectedUser, forKey: "blockedUser")
            object?.saveInBackground({ (error) in
                if error != nil {
                    HUD.show(.labeledError(title: error!.localizedDescription, subtitle: nil))
                } else {
                    self.loadFollowingUsers()
                    HUD.hide(animated: true)
                }
            })
        } else {
            //currentUserが空だったらログイン画面へ
            let storyboard = UIStoryboard(name: "SignUp", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            //ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
    }
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        timelineTableView.addSubview(refreshControl)
    }
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        self.loadFollowingUsers()
        //更新が早すぎるので２秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
        
    }
    
    func loadTimeline() {
        //オートログアウト
        guard  let currentUser = NCMBUser.current() else {
            //ログアウト成功
       //     let storyboard = UIStoryboard(name: "SignUp", bundle: Bundle.main)
        //    let rootViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
      //      UIApplication.shared.keyWindow?.rootViewController = rootViewController
            //ログイン状態の保持
      //      let ud = UserDefaults.standard
     //       ud.set(true, forKey: "isLogin")
      //      ud.synchronize()
            
            return
        }
        let query = NCMBQuery(className: "Post")
        //降順
        query?.order(byDescending: "createDate")
        //投稿したユーザーの情報も同時に取得
        query?.includeKey("user")
        //フォロー中の人＋自分の投稿だけを持ってくる
        //query?.whereKey("user", containedIn: followings)
        //フォロー中の人＋ブロックしているユーザーを除外する
        print(blockUserArray.count)
        if blockUserArray.count != 0{
            query?.whereKey("user", notContainedIn: self.blockUserArray)
        }
        posts = [Post]()
        
        query?.findObjectsInBackground({ [self] (result, error) in
            print(result)
            if error != nil {
                HUD.show(.labeledError(title: error!.localizedDescription, subtitle: nil))
            } else {
                for postObject in result as! [NCMBObject] {
                    
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    print(user)
                    print("11111",postObject)
                    if user.object(forKey: "active") as? Bool != false {
                        let userModel = UserNCMB(objectId: user.objectId, userName: user.userName)
                        let imageUrl = postObject.object(forKey: "imageUrl") as! String
                        let text = postObject.object(forKey: "text") as! String
                        let rating = postObject.object(forKey: "rating") as! String
                        let ratingScore = postObject.object(forKey: "ratingScore") as! Double
                        
                        let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text,rating: rating, ratingScore: ratingScore, createDate: postObject.createDate)
                        
                        let likeUsers = postObject.object(forKey: "likeUser") as? [String]
                        if likeUsers?.contains(NCMBUser.current().objectId) == true {
                            post.isLiked = true
                        } else {
                            post.isLiked = false
                        }
                        
                        if let likes = likeUsers {
                            post.likeCount = likes.count
                        }
                        self.posts.append(post)
                        
                        
                    }
                    print("posts = ", posts)
                   
                }
                DispatchQueue.main.async {
                    self.timelineTableView.reloadData()
                }
                
            }
        })
    }
        func loadFollowingUsers() {
            //フォロー中の人だけ持ってくる
            let query = NCMBQuery(className: "Follow")
            query?.includeKey("user")
            query?.includeKey("following")
            query?.whereKey("user", equalTo: NCMBUser.current())
            
            query?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    HUD.show(.labeledError(title: error!.localizedDescription, subtitle: nil))
                } else {
                    //ブロックのuserを読み込む関数を呼び込む
                    self.loadBlockedUsers()
                    self.followings = [NCMBUser]()
                    
                    for following in result as! [NCMBObject] {
                        self.followings.append(following.object(forKey: "following") as! NCMBUser)
                    }
                   // self.followings.append(NCMBUser.current())
                    self.loadTimeline()
                }
            })
        }
        func loadBlockedUsers() {
            let query = NCMBQuery(className: "Block")
            //inckudeKeyでBlockの小クラスである会員情報を持ってきている
            query?.includeKey("user")
            query?.includeKey("blockedUser")
            query?.whereKey("user", equalTo: NCMBUser.current())
            
            query?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    //エラーの処理
                    HUD.show(.labeledError(title: error!.localizedDescription, subtitle: nil))
                } else {
                    //ブロックされたユーザーのIDが含まれる + removeAll()は初期化して、データの重複を防いでいる
                    self.blockUserArray.removeAll()
                    for blockobject in result as! [NCMBObject] {
                        //この部分で①の配列にブロックユーザーが格納
                        self.blockUserArray.append(blockobject.object(forKey: "blockedUser") as! NCMBUser)
                        
                    }
                    print("blockUserArray = ", self.blockUserArray)
                    
                }
                self.loadTimeline()
            })
        }
        
    }
