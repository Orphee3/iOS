//
//  ArtistesCollectionViewCell.swift
//  Orphee
//
//  Created by Jeromin Lebon on 28/02/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class ArtistesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var nameProfile: UILabel!
    @IBOutlet var nbCreations: UILabel!
    
    
    
    func fillCell(user: User){
        if let picture = user.picture{
            imgProfile.kf_setImageWithURL(NSURL(string: picture)!, placeholderImage: UIImage(named: "emptyprofile"))
        }else{
            imgProfile.image = UIImage(named: "emptyprofile")
        }
        nameProfile.text = user.name
    }
}