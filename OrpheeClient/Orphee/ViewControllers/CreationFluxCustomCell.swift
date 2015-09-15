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
    @IBOutlet var likesCreation: UILabel!
    @IBOutlet var playCreation: UIButton!
    
    var idCreator: String!
    var idCreation: String!
    
    @IBOutlet var accessProfileButton: UIButton!
    var urlCreation: String!
}