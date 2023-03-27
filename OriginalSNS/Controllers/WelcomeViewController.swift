//
//  WelcomeViewController.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/05.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import NCMB

class WelcomeViewController:UIViewController{
    
    var user : User?{
        didSet{
            print("user?.name",user?.name)
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBAction func tappedLogoutButton(_ sender: Any) {
        presntToMainViewController()
    }
    private func presntToMainViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(identifier: "RootTabBarController")
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
    }
    //ログアウト
    private func handleLogout(){
        do{
            try Auth.auth().signOut()
            presentToSignUpViewController()
        } catch(let err){
            print("ログアウトに失敗しました\(err)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutButton.layer.cornerRadius = 10
        if let user = user{
            nameLabel.text = user.name + "さんようこそ"
            emailLabel.text = user.email
            let dateString = dateFormatterForCreatedAt(date: user.createdAt.dateValue())
            dateLabel.text = "作成日：" + dateString
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        confirmLoggedInUser()
    }
    
    private func confirmLoggedInUser(){
        if Auth.auth().currentUser?.uid == nil || user == nil {
            presentToSignUpViewController()
        }
    }
    
    private func presentToSignUpViewController(){
        let storyBoard = UIStoryboard(name: "SignUp", bundle: nil)
        let viewController = storyBoard.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    private func dateFormatterForCreatedAt(date:Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
