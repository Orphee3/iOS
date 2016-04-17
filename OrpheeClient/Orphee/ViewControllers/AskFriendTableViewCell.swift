//
//  AskFriendTableViewCell.swift
//  Orphee
//
//  Created by Jeromin Lebon on 16/04/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class AskFriendTableViewCell: UITableViewCell {
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var nameUser: UILabel!
    @IBOutlet var acceptButton: UIButton!
    @IBOutlet var refuseButton: UIButton!
    
    func fillCell(user: UserNews){
        if let imgUser = user.userSource?.picture{
            self.imgUser.kf_setImageWithURL(NSURL(string: imgUser)!, placeholderImage: UIImage(named: "emptyprofile"))
        }else{
            imgUser.image = UIImage(named: "emptyprofile")
        }
        nameUser.text = user.userSource?.name
    }
}