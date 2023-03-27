//
//  SignUpViewController.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/14.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD
import NCMB



class SignUpViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBAction func tappedSignUpButton(_ sender: Any) {
        handleAuthToFirebase()
    }
    @IBAction func tappedAlreadyHaveAccountButton(_ sender: Any) {
        pushToLoginViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNotificationObserver()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    private func pushToLoginViewController(){
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let welcomeViewController = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        welcomeViewController.modalPresentationStyle = .fullScreen
        self.present(welcomeViewController, animated: true, completion: nil)
    }
    
    private func setupViews(){
        signUpButton.layer.cornerRadius = 10
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = UIColor.rgb(red: 200, green: 210, blue: 255)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        
        
    }
    
    private func setupNotificationObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //Firestoreにユーザー情報を保存
    private func handleAuthToFirebase(){
        HUD.show(.progress,onView: view)
        guard let email = emailTextField.text else{return}
        guard let password = passwordTextField.text else{return}
        print("AAA")
        let defaultImage = UIImage(named:"DefaultImage.jpeg")
        guard let uploadImage = defaultImage?.jpegData(compressionQuality: 0.01) else { return }
        print("BBB")
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: "gs://orignalsnswithfirebase.appspot.com").child("profile_image").child(fileName)
        print("CCC")
        storageRef.putData(uploadImage, metadata: nil) { (matadata, err) in
            if let err = err {
                print("Firestorageへの情報の保存に失敗しました。\(err)")
                HUD.hide()
                return
            }
            
            storageRef.downloadURL { (url, err) in
                if let err = err {
                    print("Firestorageからのダウンロードに失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                
                guard let profileImageUrl = url?.absoluteString else { return}
                print("URL:")
                print(profileImageUrl)
                print("*************")
                //self.createUserToFirestore(profileImageUrl: urlString)
                Auth.auth().createUser(withEmail: email ,password: password){(res,err) in
                    if let err = err {
                        print("Authentication error\(err)")
                        return
                    }
                    print("success")
                   // guard let uid = Auth.auth().currentUser?.uid else{return}
                    guard let uid = res?.user.uid else { return }
                    guard let name = self.usernameTextField.text else {return}
                    
                    let docData = ["email":email,"name": name,"createdAt":Timestamp(),"profileImageUrl": profileImageUrl] as [String: Any]
                    print(docData)
                    print("*****")
                    let userRef = Firestore.firestore().collection("users").document(uid)
                        userRef.setData(docData){(err) in
                        if let err = err {
                            print("Error \(err)")
                            return
                        }
                        print("success")
                            self.addUserInfoNCMB(email: email, password: password, username: name)
                        
                        self.fetchUserInfoFromFirestore(userRef: userRef)
                    }
                }
            }
            
        }
    }
    
    //NCMBへのユーザー情報の登録
    private func addUserInfoNCMB(email:String,password:String,username:String){
        let user = NCMBUser()
        user.userName = username
        user.mailAddress = email
        user.password = password
        user.signUpInBackground { (error) in
            if error != nil {
                //エラーがあった場合
                print(error)
            } else {
                //登録成功
                //ログイン状態の保持
                let ud = UserDefaults.standard
                ud.set(true, forKey: "isLogin")
                ud.synchronize()
                var Acl = NCMBACL()
                Acl.setPublicReadAccess(true)
                Acl.setPublicWriteAccess(true)
                user.acl = Acl
                user.saveInBackground { error in
                    if error != nil {
                        print(error)
                    }
                }
                
            }
        }
        
        
    }
    //Firestoreからユーザー情報を取得
    private func addUserInfoFirestore(email:String){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        guard let name = self.usernameTextField.text else {return}
        
        let docData = ["email":email,"name": name,"createdAt":Timestamp()] as [String: Any]
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.setData(docData){(err) in
            if let err = err {
                print("Error \(err)")
                HUD.hide{(_) in
                    HUD.flash(.error,delay: 1)
                }
                return
            }
            print("success")
            
            self.fetchUserInfoFromFirestore(userRef: userRef)
            
            
        }
    }
    
    private func fetchUserInfoFromFirestore(userRef:DocumentReference){
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
                    self.presntToWelcomeViewController(user: user)
                }
            }
        }
    }
    
    private func presntToWelcomeViewController(user: User){
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let welcomeViewController = storyboard.instantiateViewController(identifier: "WelcomeViewController") as! WelcomeViewController
        welcomeViewController.user = user
        welcomeViewController.modalPresentationStyle = .fullScreen
        self.present(welcomeViewController, animated: true, completion: nil)
    }
    

    
    
    @objc func showKeyboard(notification:Notification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        let signUpButtonMaxY = signUpButton.frame.maxY
        let distance = signUpButtonMaxY - keyboardMinY + 20
        
        let transform = CGAffineTransform(translationX: 0, y: -distance)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {self.view.transform = transform})
        
        print("Keyboard is showing")
    }
    @objc func hideKeyboard(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {self.view.transform = .identity})
        print("Keyboard is hiding")
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SignUpViewController: UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? true
        
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty{
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 200, green: 210, blue: 255)
        }else{
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 5, green: 50, blue: 255)
        }
        print(": ",textField.text)
    }
}

