//
//  compoGridOpsIntent.swift
//  CompoUI
//
//  Created by John Bobington on 22/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

class compoGridOpsIntent: NSObject {

    var hack = 0

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var VC: CompositionVC!

    @IBAction func addColumn(sender: UIButton) {
        print("add columns")
        self.VC.dataMgr.addCellsToAllLines(4)
        self.VC.tableView.reloadData()
    }

    @IBAction func cleanAll(sender: UIBarButtonItem) {
        print("clean all")
    }

    @IBAction func handlePan(gest: HorizontalPanGestureRecognizer) {
        let dragDirection = gest.lastDirection
        let vel = gest.velocityInView(gest.view)
        let xMult = fabs(vel.x + vel.y) / 200

        if gest.state == .Changed  && dragDirection != .Unknown {

            let moveRowCount = Int(ceil(xMult * 0.3)) * dragDirection.rawValue
            var cell: HorizontalTableView? = nil
            for idx in 0..<self.tableView.numberOfRowsInSection(0) {
                if let c = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: idx, inSection: 0)) as? HorizontalTableView {
                    cell = c
                    break
                }
            }
            if let cell = cell {
                let rowIdx = cell.cellIndexForTime(self.VC.commonTime) + moveRowCount
                let index = cell.normalizeIndex(rowIdx)
                self.VC.commonTime = cell.timeForItem(index.row, forLine: cell.lineID)
                self.scrollAllCellsToTime(self.VC.commonTime)
            }
        }
    }

    func scrollAllCellsToTime(time: Int) {
        for rowIdx in 0..<self.tableView.numberOfRowsInSection(0) {
            let idx = NSIndexPath(forItem: rowIdx, inSection: 0)
            if let horizontalCell = self.tableView.cellForRowAtIndexPath(idx) as? HorizontalTableView {
                horizontalCell.scrollToTime(time)
            }
        }
    }
}
