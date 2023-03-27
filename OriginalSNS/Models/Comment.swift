//
//  Comment.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/13.
//

import UIKit

class Comment {
    var postId: String
    var user: UserNCMB
    var text: String
    var createDate: Date
    
    init (postId: String, user: UserNCMB, text: String, createDate: Date) {
        self.postId = postId
        self.user = user
        self.text = text
        self.createDate = createDate
    }
    
    
}
