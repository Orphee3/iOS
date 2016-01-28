//
//  HeaderProfileView.swift
//  Orphee
//
//  Created by Jeromin Lebon on 25/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class HeaderProfileView: UICollectionReusableView{
    @IBOutlet var nameProfile: UILabel!
    @IBOutlet var nbLikeProfile: UILabel!
    @IBOutlet var nbCreationProfile: UILabel!
    @IBOutlet var imgProfile: UIImageView!
    
    func putInGraphic(user: User){
        imgProfile.layer.cornerRadius = self.imgProfile.frame.width / 2
        if let nameProfile = user.name{
            self.nameProfile.text = nameProfile
        }
        if let picture = user.picture {
            imgProfile.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
        }
    }
}