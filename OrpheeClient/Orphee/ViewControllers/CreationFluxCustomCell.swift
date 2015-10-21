//
//  CreationFluxCustomCell.swift
//  Orphee
//
//  Created by Jeromin Lebon on 05/09/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class CreationFluxCustomCell: UITableViewCell{
    
    @IBOutlet var imgProfileCreator: UIImageView!
    @IBOutlet var nameProfileCreator: UILabel!
    @IBOutlet var imgCreation: UIImageView!
    @IBOutlet var nameCreation: UILabel!
    @IBOutlet var nbLikesCreation: UILabel!
    @IBOutlet var playCreation: UIButton!
    @IBOutlet var nbCommentsCreation: UILabel!
    @IBOutlet var accessProfileButton: UIButton!
    
    func putInGraphic(creation: Creation, user: User){
        
        if let nameProfileCreator = user.name{
            self.nameProfileCreator.text = nameProfileCreator
        }
        if let nameCreation = creation.name{
            self.nameCreation.text = nameCreation.substringWithRange(
                Range<String.Index>(start: nameCreation.startIndex.advancedBy(0),
                    end: nameCreation.endIndex.advancedBy(-4)))
        }
        if let picture = user.picture{
            self.imgProfileCreator.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
        }else{
            self.imgProfileCreator.image = UIImage(named: "emptygrayprofile")
        }
        if let nbComments = creation.nbCommments{
            self.nbCommentsCreation.text = String(nbComments)
        }
        if let nbLikes = creation.nbLikes{
            self.nbLikesCreation.text = String(nbLikes)
        }
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