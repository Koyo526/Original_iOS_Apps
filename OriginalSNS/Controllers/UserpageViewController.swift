//
//  UserpageViewController.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/06.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import NCMB
import PKHUD

class UserpageViewController:UIViewController, UICollectionViewDelegateFlowLayout{
    var posts = [Post] ()
    
    
    private let sideMargin: CGFloat = 25
    private let itemPerWidth: CGFloat = 3
    private let itemSpacing: CGFloat = 10
    
    @IBOutlet var userPageCollectionView: UICollectionView!
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userDisplayNameLabel: UILabel!
    
    @IBOutlet var userIntroduntionTextView: UITextView!
    
    @IBOutlet var postCountLabel: UILabel!
    
    var user : User?{
        didSet{
            print("user?.name",user?.name)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //userPageCollectionView.delegate = self
        
        
        loadPosts()
    
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2.0
        userImageView.layer.masksToBounds = true
        
        let nib = UINib(nibName: "UserPageCollectionViewCell", bundle: Bundle.main)
        userPageCollectionView.register(nib, forCellWithReuseIdentifier: "UserPageCell")
        
        //レイアウト設定
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width/3)-10, height: (UIScreen.main.bounds.size.width/3)-10)
        layout.minimumLineSpacing = 5.0
               layout.minimumInteritemSpacing = 5.0
              // layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
               //userPageCollectionView.collectionViewLayout = layout
                   layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        
        userPageCollectionView.collectionViewLayout = layout
        
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = userPageCollectionView.dequeueReusableCell(withReuseIdentifier: "UserPageCell", for: indexPath) as!
         UserPageCollectionViewCell
        
       // cell.backgroundColor = UIColor.lightGray
        let imageUrl = posts[indexPath.row].imageUrl
        //投稿画像の表示
        cell.photoImageView.kf.setImage(with: URL(string: imageUrl))
        return cell
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let user = NCMBUser.current() {
            userDisplayNameLabel.text = user.object(forKey: "displayName") as? String
            userIntroduntionTextView.text = user.object(forKey: "introduction") as? String
            self.navigationItem.title = user.userName
            
            let file = NCMBFile.file(withName: NCMBUser.current().objectId, data: nil) as! NCMBFile
            file.getDataInBackground { data, error in
                if error != nil {
                    print(error)
                } else {
                    let image = UIImage(data: data!)
                    self.userImageView.image = image
                }
            }

        } else {
            //NCMBUser.current()がnilだったとき
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let viewController = storyboard.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
            //ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
        
        
    }
    
    @IBAction func showMenu(){
        let alertController =  UIAlertController(title: "メニュー", message: "メニューを選択してください", preferredStyle: .actionSheet)
      
        let signOutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
        NCMBUser.logOutInBackground { (error) in
                if error != nil {
                    print(error)
                } else {
                    //ログアウト成功
                    self.handleLogout()
                    //ログイン状態の保持
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    ud.synchronize()
                    
                }
        }
            }
        
        let deleteAction = UIAlertAction(title: "退会", style: .default) { (action) in
            let alert = UIAlertController(title: "会員登録の解除", message: "本当に退会しますか？退会した場合、再度このアカウントをご利用いただくことができません。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                //ユーザーのアクティブ状態をfalseに
                if let user = NCMBUser.current() {
                    user.setObject(false, forKey: "active")
                    user.saveInBackground { (error) in
                        if error != nil {
                            HUD.show(.labeledError(title: error!.localizedDescription, subtitle: nil))
                        } else {
                            //退会成功
                            let storyBoard = UIStoryboard(name: "SignUp", bundle: nil)
                            let viewController = storyBoard.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
                            let navController = UINavigationController(rootViewController: viewController)
                            navController.modalPresentationStyle = .fullScreen
                            self.present(navController, animated: true, completion: nil)
                       }
                    }
                } else {
                    //userがnilだった場合ログイン画面に移動
                    let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
                    let viewController = storyboard.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
                    let navController = UINavigationController(rootViewController: viewController)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true, completion: nil)
                    //ログイン状態の保持
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    ud.synchronize()
                }
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
            
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(signOutAction)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    private func handleLogout(){
        do{
            try Auth.auth().signOut()
            presentToSignUpViewController()
        } catch(let err){
            print("ログアウトに失敗しました\(err)")
        }
    }
    private func presentToSignUpViewController(){
        let storyBoard = UIStoryboard(name: "SignUp", bundle: nil)
        let viewController = storyBoard.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    func loadPosts() {
        let query = NCMBQuery(className: "Post")
              query?.includeKey("user")
              query?.whereKey("user", equalTo: NCMBUser.current())
              query?.findObjectsInBackground({ (result, error) in
                  if error != nil {
                   HUD.flash(.labeledSuccess(title: "Success", subtitle: nil))
                  } else {
                      self.posts = [Post]()
                      
                      for postObject in result as! [NCMBObject] {
                          // ユーザー情報をUserクラスにセット
                          let user = postObject.object(forKey: "user") as! NCMBUser
                          let userModel = UserNCMB(objectId: user.objectId, userName: user.userName)
                          userModel.displayName = user.object(forKey: "displayName") as? String
                          
                          // 投稿の情報を取得
                        let imageUrl = postObject.object(forKey: "imageUrl") as! String
                        let text = postObject.object(forKey: "text") as! String
                        let rating = postObject.object(forKey: "rating") as! String
                        let ratingScore = postObject.object(forKey: "ratingScore") as! Double                          // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                        let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text,rating: rating, ratingScore: ratingScore, createDate: postObject.createDate)
                          
                          // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                          let likeUser = postObject.object(forKey: "likeUser") as? [String]
                          if likeUser?.contains(NCMBUser.current().objectId) == true {
                              post.isLiked = true
                          } else {
                              post.isLiked = false
                          }
                          // 配列に加える
                          self.posts.append(post)
                      }
                      self.userPageCollectionView.reloadData()
                      
                      // post数を表示
                      self.postCountLabel.text = String(self.posts.count)
                  }
              })
        
    }
    
    
    
}
