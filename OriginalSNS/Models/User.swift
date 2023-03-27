//
//  User.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/06.
//
import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct User {
    let name:String
    let createdAt: Timestamp
    let email : String
    let profileImageUrl: String
    var uid: String?
    
    init(dic:[String:Any]){
        self.name = dic["name"] as! String
        self.createdAt = dic["createdAt"] as! Timestamp
        self.email = dic["email"] as! String
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
    }
}
