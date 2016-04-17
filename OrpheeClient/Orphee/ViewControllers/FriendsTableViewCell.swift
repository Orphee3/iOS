//
//  FriendsTableViewCell.swift
//  Orphee
//
//  Created by Jeromin Lebon on 16/04/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class FriendsTableViewCell: UITableViewCell{
    
    @IBOutlet var nameUser: UILabel!
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var removeButton: UIButton!
    
    func fillCell(user: User){
        if let imgUser = user.picture{
            self.imgUser.kf_setImageWithURL(NSURL(string: imgUser)!, placeholderImage: UIImage(named: "emptyprofile"))
        }else{
            imgUser.image = UIImage(named: "emptyprofile")
        }
        nameUser.text = user.name
    }
}