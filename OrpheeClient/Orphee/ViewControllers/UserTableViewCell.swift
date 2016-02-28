//
//  UserCollectionViewCell.swift
//  Orphee
//
//  Created by Jeromin Lebon on 28/02/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet var imgCreation: UIImageView!
    @IBOutlet var nameCreation: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    
    func fillCell(creation: Creation){
        let index1 = creation.name.endIndex.advancedBy(-4)
        let finalName = creation.name.substringToIndex(index1)
        nameCreation.text = finalName
    }
}