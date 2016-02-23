//
//  HomeViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 23/02/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UITableViewController{
    var arrayCreations: [Creation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OrpheeApi().getPopularCreations(0, size: 50) { (creations) -> () in
            self.arrayCreations = creations
        }
    }
}