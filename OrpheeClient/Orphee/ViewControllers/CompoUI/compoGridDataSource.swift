//
//  compoGridDataSource.swift
//  CompoUI
//
//  Created by John Bobington on 22/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

class compoGridDataSource: NSObject, UITableViewDataSource {

    @IBOutlet weak var VC: CompositionVC!
    @IBOutlet weak var dataMgr: DataMgr!

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataMgr.lines
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: HorizontalTableView = tableView.dequeueReusableCellWithIdentifier("Toto") as! HorizontalTableView
        cell.updateCellData(self.dataMgr, lineID: indexPath.row)
        cell.setViewController(self.VC)
        cell.setupGraphics()
        cell.scrollToTime(self.VC.commonTime, animated: false)
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
}

class compoGridDelegate: NSObject, UITableViewDelegate {
    
}