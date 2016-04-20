//
//  ConversationCell.swift
//  Orphee
//
//  Created by Jeromin Lebon on 18/04/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate
import Kingfisher

class ConversationCell: UITableViewCell {
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var nameUser: UILabel!
    @IBOutlet var messageUser: UILabel!
    @IBOutlet var dateMessage: UILabel!
    
    func fillCell(message: Message){
        if let picture = message.creator.picture{
            imgUser.kf_setImageWithURL(NSURL(string: picture)!, placeholderImage: UIImage(named: "emptyprofile"))
        }else{
            imgUser.image = UIImage(named: "emptygrayprofile")
        }
        nameUser.text = message.creator.name
        messageUser.text = message.message
        let date = message.dateCreation.toDate(DateFormat.ISO8601Format(.Full))
        dateMessage.text = date?.toString(DateFormat.Custom("dd/MM/YYYY 'à' HH:mm"))
    }
}