//
//  FriendCustomCell.swift
//  Orphee
//
//  Created by Jeromin Lebon on 17/11/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class FriendCustomCell: UITableViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profilImg: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    var id: String!

    func putInGraphic(user: User){
        
        if let nameProfile = user.name{
            self.name.text = nameProfile
        }
        if let picture = user.picture{
            self.profilImg.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
        }else{
            self.profilImg.image = UIImage(named: "emptygrayprofile")
        }
        if let id = user.id{
            self.id = id
        }
        setLayout()
    }
    
    func setLayout(){
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    

}