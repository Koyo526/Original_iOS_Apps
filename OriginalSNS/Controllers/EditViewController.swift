//
//  EditViewController.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/06.
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD
import NCMB

class EditViewController:UIViewController,UITextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var introductionTextView: UITextView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2.0
        userImageView.layer.masksToBounds = true
        
        userNameTextField.delegate = self
        userIdTextField.delegate = self
        introductionTextView.delegate = self
        
        let userId = NCMBUser.current().userName
        userIdTextField.text = userId
        
        if let user = NCMBUser.current() {
            userNameTextField.text = user.object(forKey: "displayName") as? String
            userIdTextField.text = user.userName
            introductionTextView.text = user.object(forKey: "introduction") as? String
            
            let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
            file.getDataInBackground { data, error in
                if error != nil {
                    print(error)
                } else {
                    let image = UIImage(data: data!)
                    self.userImageView.image = image
                }
            }
            
        } else {
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            //ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()        }
       
        
    }
    //入力が終わったらキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        var resizedImage = selectedImage.scale(byFactor: 0.2)
        
        userImageView.image = resizedImage
        
        picker.dismiss(animated: true, completion: nil)

        let data = resizedImage!.pngData()
        let file = NCMBFile.file(withName: NCMBUser.current().objectId, data: data) as! NCMBFile
        file.saveInBackground ({ error in
            if error != nil {
                print(error)
            } else {
                self.userImageView.image = selectedImage
            }
        })  { (progress) in
            print(progress)
        }

    }
    
    @IBAction func selectImage() {
        let actionController = UIAlertController(title: "画像の選択", message: "選択してください", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
            //カメラ起動
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではカメラが使用できません")
            }
        }
        let albumAction = UIAlertAction(title: "フォトライブラリ", style: .default) { (action) in
            //アルバム起動
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではフォトライブラリが使用できません")
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { action in
            actionController.dismiss(animated: true, completion: nil)
        }
        actionController.addAction(cameraAction)
        actionController.addAction(albumAction)
        actionController.addAction(cancelAction)
        self.present(actionController, animated: true, completion: nil)
    }

    @IBAction func closeEditController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveUserInfo() {
        let user = NCMBUser.current()
        user?.setObject(userNameTextField.text, forKey: "displayName")
        user?.setObject(userIdTextField.text, forKey: "userName")
        user?.setObject(introductionTextView.text, forKey: "introduction")
        user?.saveInBackground({ error in
            if error != nil {
                print(error)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    
}
