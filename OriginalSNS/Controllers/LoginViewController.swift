//
//  LoginViewController.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/05.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD
import NCMB

class LoginViewController:UIViewController{
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    @IBAction func tappedDontHaveAccountButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let welcomeViewController = storyboard.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        welcomeViewController.modalPresentationStyle = .fullScreen
        self.present(welcomeViewController, animated: true, completion: nil)
    }
    @IBAction func tappedLoginButton(_ sender: Any) {
        HUD.show(.progress, onView: self.view)
        print("tapped Login Button")
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("ログイン情報の取得に失敗しました\(err)")
                HUD.hide{(_) in
                    HUD.flash(.error,delay: 1)
                }
                return
            }
            
            print("success")
            guard let uid = Auth.auth().currentUser?.uid else{return}
            let userRef = Firestore.firestore().collection("users").document(uid)
            userRef.getDocument { (snapshot,err) in
                if let err = err {
                    print("ユーザー情報の取得に失敗しました\(err)")
                    HUD.hide{(_) in
                        HUD.flash(.error,delay: 1)
                    }
                    return
                }
                guard let data = snapshot?.data() else{return}
                let user = User.init(dic: data)
                print("success\(user.name)")
                HUD.hide{(_) in
                    HUD.flash(.success,onView: self.view,delay: 1){ (_)in
                        print("AAA")
                        self.loginUserInfoNCMB(name: user.name, password: password)
                        print("******")
                        self.presntToMainViewController()
                    }
                }
            }
        }
    }
    private func loginUserInfoNCMB(name:String,password:String){
        NCMBUser.logInWithUsername(inBackground: name, password: password){ (user,error) in
            print("Start")
            if error != nil {
                print(error)
                print("ログインできません")
                return
            } else {
                //ログイン成功
                //ログイン状態の保持
                let ud = UserDefaults.standard
                ud.set(true, forKey: "isLogin")
                ud.synchronize()
                }
            }
            
        }
    private func presntToMainViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(identifier: "RootTabBarController")
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 10
        loginButton.isEnabled = false
        loginButton.backgroundColor = UIColor.rgb(red: 200, green: 210, blue: 255)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
}
extension LoginViewController:UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        
        if emailIsEmpty || passwordIsEmpty{
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 200, green: 210, blue: 255)
        }else{
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(red: 5, green: 50, blue: 255)
        }
        print(": ",textField.text)
    }
}

