//
//  Post.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/13.
//

import UIKit

class Post {
        var objectId: String
        var user: UserNCMB
        var imageUrl: String
        var text: String
        var rating: String
        var ratingScore: Double
        var createDate: Date
        var isLiked: Bool?
        var comments: [Comment]?
        var likeCount: Int = 0

    init(objectId: String, user: UserNCMB, imageUrl: String, text: String, rating: String, ratingScore: Double, createDate: Date) {
            self.objectId = objectId
            self.user = user
            self.imageUrl = imageUrl
            self.text = text
            self.createDate = createDate
            self.rating = rating
            self.ratingScore = ratingScore
        }
    
}
