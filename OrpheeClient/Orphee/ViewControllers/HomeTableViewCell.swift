//
//  HomeTableViewCell.swift
//  Orphee
//
//  Created by Jeromin Lebon on 23/02/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import SwiftDate

class HomeTableViewCell: UITableViewCell {
    @IBOutlet var creatorImg: UIImageView!
    @IBOutlet var creatorName: UILabel!
    @IBOutlet var creationImg: UIImageView!
    @IBOutlet var creationName: UILabel!
    @IBOutlet var dateCreation: UILabel!
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var createButton: UIButton!
    
    func fillCell(creation: Creation){
        if let picture = creation.creator[0].picture{
            creatorImg.kf_setImageWithURL(NSURL(string: picture)!, placeholderImage: UIImage(named: "emptyprofile"))
        }else{
            creatorImg.image = UIImage(named: "emptyprofile")
        }
        creatorName.text = creation.creator[0].name
        let index1 = creation.name.endIndex.advancedBy(-4)
        let finalName = creation.name.substringToIndex(index1)
        creationName.text = finalName
        let date = creation.dateCreation.toDate(DateFormat.ISO8601)
        dateCreation.text = date?.toString(DateFormat.Custom("dd/MM/YYYY 'à' HH:mm"))
    }
}