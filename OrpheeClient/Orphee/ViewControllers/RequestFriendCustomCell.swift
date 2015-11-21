//
//  RequestFriendCustomCell.swift
//  Orphee
//
//  Created by Jeromin Lebon on 31/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class RequestFriendCustomCell: UITableViewCell{
    
    @IBOutlet var profilImg: UIImageView!
    @IBOutlet var profilName: UILabel!
    @IBOutlet var profilNbFriend: UILabel!
    @IBOutlet var profilNbPublication: UILabel!
    @IBOutlet var buttonAccept: UIButton!
    @IBOutlet var buttonDecline: UIButton!
    var id: String!
    
    func putInGraphic(user: FriendShipRequest){
        
        if let nameProfileCreator = user.name{
            self.profilName.text = nameProfileCreator
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