//
//  RoomCell.swift
//  Orphee
//
//  Created by Jeromin Lebon on 19/11/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class RoomCell: UITableViewCell{
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var nameProfile: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var date: UILabel!
    
    func layoutCell(room: Room){
        self.imageProfile.sd_setImageWithURL(NSURL(string: room.peoplesPicture[0]), placeholderImage: UIImage(named: "emptygrayprofile"))
        nameProfile.text = room.peoples[0]
        lastMessage.text = room.lastMessage
        date.text = room.lastMessageDate
    }
}