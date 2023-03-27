//
//  PostViewController.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/13.
//

import UIKit
import NYXImagesKit
import UITextView_Placeholder
import PKHUD
import Cosmos
import NCMB

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate,                         UITextViewDelegate {
    
    let placeholderImage = UIImage(named: "photo-placeholder")
    var resizedImage: UIImage! //サイズを変えた画像
    var rating: Double = 0.0
    
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var postTextView: UITextView!
    @IBOutlet var postButton: UIBarButtonItem!
    @IBOutlet var cosmosView: CosmosView!
    @IBOutlet var cosmosLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        postImageView.image = placeholderImage
        postButton.isEnabled = false
        postTextView.placeholder = "キャプションを書く"
        postTextView.delegate = self
        
        cosmosView.settings.fillMode = .half
        
        cosmosView.didTouchCosmos = { [self] rating in
            print(rating)
            var _ = String("\(rating)")
            cosmosLabel.text = String(round(cosmosView.rating*10)/10)
            let ud = UserDefaults.standard
            ud.set(rating, forKey: "Rating")
            ud.synchronize()
            
        }
        
       
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        //画像をリサイズ(0.4以下で良い)
        resizedImage = selectedImage.scale(byFactor: 0.3)
        postImageView.image = resizedImage
        
        //pickerを閉じる
        picker.dismiss(animated: true, completion: nil)
        
       confirmContent()
    }
    func textViewDidChange(_ textView: UITextView){
        confirmContent()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        //UITextFieldのファーストレスポンダをやめる（その結果、キーボードが非表示になる）
        textView.resignFirstResponder()
    }
    @IBAction func selectImage() {
        let alertController = UIAlertController(title: "画像選択", message: "シェアする画像を選択してください", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではカメラが使用できません")
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "フォトライブラリから選択", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではフォトライブラリが使用できません")
                
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sharePhoto(){
        HUD.show(.progress)
        
        UIGraphicsBeginImageContext(resizedImage.size)
        let rect = CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height)
        resizedImage.draw(in: rect)
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let data = resizedImage.pngData()
        let file = NCMBFile.file(with: data) as! NCMBFile
        file.saveInBackground ({ [self] (error) in
            if error != nil {
                HUD.hide()
                let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { action in
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                let postObject = NCMBObject(className: "Post")
                
                if self.postTextView.text.count == 0 {
                    print("入力されていません")
                    return
                }
                postObject?.setObject(self.postTextView.text!, forKey: "text")
                postObject?.setObject(NCMBUser.current(), forKey: "user")
                let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/nxRHcfc3A1AOsQjK/publicFiles/" + file.name
                postObject?.setObject(url, forKey: "imageUrl")
                postObject?.setObject(String(round(cosmosView.rating*10)/10), forKey: "rating")
                postObject?.setObject(round(cosmosView.rating*10)/10, forKey: "ratingScore")
                postObject?.saveInBackground({ error in
                    if error != nil {
                        HUD.hide()
                        HUD.show(.labeledError(title: error!.localizedDescription, subtitle: nil))
                    } else {
                        HUD.hide()
                        self.postImageView.image = nil
                        self.postImageView.image = UIImage(named: "photo-placeholder")
                        self.postTextView.text = nil
                        self.tabBarController?.selectedIndex = 0
                        
                    }
                })
            }
        }) { (progress) in
            print(progress)
        }
            
    }
    
    func confirmContent() {
        if postTextView.text.count > 0 && postImageView.image != placeholderImage {
            postButton.isEnabled = true
        } else {
            postButton.isEnabled = false
        }
        
    }
    @IBAction func cancel() {
        if postTextView.isFirstResponder == true {
            postTextView.resignFirstResponder()
        }
        let alert = UIAlertController(title: "投稿内容の破棄", message: "入力中の投稿内容を破棄しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.postTextView.text = nil
            self.postImageView.image = UIImage(named: "photo-placeholder")
            self.confirmContent()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

}

