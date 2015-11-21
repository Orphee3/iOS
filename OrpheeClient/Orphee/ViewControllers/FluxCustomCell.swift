//
//  FluxCustomCell.swift
//  Orphee
//
//  Created by Jeromin Lebon on 12/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class FluxCustomCell: UITableViewCell {
    @IBOutlet var addFriendButton: UIButton!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var nameProfile: UILabel!
    @IBOutlet var nbCreations: UILabel!
    
    func putInGraphic(user: User){
        if let name = user.name{
            self.nameProfile.text = name
        }
        if let picture = user.picture{
            self.imgProfile.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
        }else{
            self.imgProfile.image = UIImage(named: "emptygrayprofile")
        }
//        if let nbCreations = user.nbCreations{
//            self.nbCreations.text = String(nbCreations)
//        }
        setLayout()
    }
    
    func setLayout(){
        self.layer.shadowOffset = CGSizeMake(-0.2, 0.2)
        self.layer.shadowRadius = 1
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath
        self.layer.shadowOpacity = 0.2
        self.layoutMargins = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = false;
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
}