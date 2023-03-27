//
//  CommentViewController.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/13.
//

import UIKit
import PKHUD
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseFirestore
import NCMB

class CommentViewController: UIViewController,UITableViewDataSource, UITabBarDelegate {
    
    var postId: String!
    
    var comments = [Comment]()
    
    @IBOutlet var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTableView.dataSource = self
        commentTableView.tableFooterView = UIView()
        
        commentTableView.estimatedRowHeight = 80
        
        commentTableView.rowHeight = UITableView.automaticDimension
        
        loadComments()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let userImageView = cell?.viewWithTag(1) as! UIImageView
        let userNameLabel = cell?.viewWithTag(2) as! UILabel
        let commentLabel = cell?.viewWithTag(3) as! UILabel
        
        //ユーザー画像を丸くする
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2.0
        userImageView.layer.masksToBounds = true
        
        let user = comments[indexPath.row].user
        let userImagePath = "https://mbaas.api.nifcloud.com/2013-09-01/applications/nxRHcfc3A1AOsQjK/publicFiles/" + user.objectId
        userImageView.kf.setImage(with: URL(string: userImagePath))
        userNameLabel.text = user.displayName
        commentLabel.text = comments[indexPath.row].text
        
        return cell!
    }
    
    func loadComments() {
        comments = [Comment]()
        let query = NCMBQuery(className: "Comment")
        //CommentクラスのpostIdというforkeyに一致する投稿を引っ張る条件
        query?.whereKey("postId", equalTo: postId)
        query?.includeKey("user")
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                HUD.show(.labeledError(title: error!.localizedDescription, subtitle: nil))
            } else {
                for commentObject in result as! [NCMBObject] {
                    //コメントをしたユーザーの情報を取得
                    let user = commentObject.object(forKey: "user") as! NCMBUser
                    let userModel = UserNCMB(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName")as! String
                    
                    //コメントの文字を取得
                    let text = commentObject.object(forKey: "text")as! String
                    
                    //Commentクラスに格納
                    let comment = Comment(postId: self.postId, user: userModel, text: text, createDate: commentObject.createDate)
                    self.comments.append(comment)
                    
                    //テーブルをリロード
                    self.commentTableView.reloadData()
                }
            }
        })
    }
    @IBAction func addComment() {
        let alert = UIAlertController(title: "コメント", message: "コメントを入力してください", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            HUD.show(.progress)
            let object = NCMBObject(className: "Comment")
            object?.setObject(self.postId, forKey: "postId")
            object?.setObject(NCMBUser.current(), forKey: "user")
            object?.setObject(alert.textFields?.first?.text, forKey: "text")
            object?.saveInBackground({ (error) in
                if error != nil {
                    HUD.show(.labeledError(title: error!.localizedDescription, subtitle: nil))
                } else {
                    HUD.hide(animated: true)
                    self.loadComments()
                }
            })
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alert.addTextField { (textField) in
            textField.placeholder = "ここにコメントを入力"
        }
        self.present(alert, animated: true, completion: nil)
    }
    
}

