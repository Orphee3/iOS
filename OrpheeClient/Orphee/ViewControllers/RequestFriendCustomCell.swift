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
    @IBOutlet var buttonGoToProfil: UIButton!
    @IBOutlet var buttonAccept: UIButton!
    @IBOutlet var buttonDecline: UIButton!
    var id: String!
}