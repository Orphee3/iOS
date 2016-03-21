//
//  CommentTableViewCell.swift
//  Orphee
//
//  Created by Jeromin Lebon on 05/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate

class CommentTableViewCell: UITableViewCell{
    @IBOutlet weak var imgCommentator: UIImageView!
    @IBOutlet weak var nameCommentator: UILabel!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var dateComment: UILabel!

    
    func fillCell(comment: Comment){
        prepareImg()
        if let picture = comment.creator.picture{
            imgCommentator.kf_setImageWithURL(NSURL(string: picture)!, placeholderImage: UIImage(named: "emptyprofile"))
        }else{
            imgCommentator.image = UIImage(named: "emptyprofile")
        }
        nameCommentator.text = comment.creator.name
        commentText.text = comment.message
        let date = comment.dateCreation.toDate(DateFormat.ISO8601)
        dateComment.text = date?.toString(DateFormat.Custom("dd/MM/YYYY 'à' HH:mm"))
    }
    
    func prepareImg(){
        imgCommentator.layer.cornerRadius = imgCommentator.frame.width / 2
    }
}