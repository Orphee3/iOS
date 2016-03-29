//
//  horizontalTVDataSource.swift
//  CompoUI
//
//  Created by John Bobington on 23/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

class defaultCell: UICollectionViewCell {
    @IBOutlet weak var content: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.autoresizingMask = .None
    }
}

class defaultHeader: UICollectionReusableView {
    @IBOutlet weak var noteLbl: UILabel!
    @IBOutlet weak var octaveLbl: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        self.layer.borderWidth = 2
        //        self.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.autoresizingMask = .None
    }
}

class horizontalCVDataSource: NSObject, UICollectionViewDataSource {

    weak var VC: CompositionVC!
    weak var dataMgr: DataMgr!
    var lineID: Int!
    var notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    override init() { }

    init(dataMgr: DataMgr, lineID: Int) {
        self.dataMgr = dataMgr
        self.lineID = lineID
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.dataMgr = self.VC.tracks[self.VC.currentTrack]
        let res = dataMgr.cellCountForLine(self.lineID)
        return res >= 0 ? res : 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        self.dataMgr = self.VC.tracks[self.VC.currentTrack]

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("toto", forIndexPath: indexPath) as! defaultCell
        //        cell.layer.borderColor = UIColor.blackColor().CGColor
        //        cell.layer.borderWidth = 2
        //        cell.layer.shadowRadius = 2
        //        cell.layer.shadowColor = UIColor.blackColor().CGColor
        //        cell.layer.opacity = 1
        //        cell.layer.shadowOffset = CGSize(width: 1, height: 2)
//        cell.content.backgroundColor = UIColor(r: 255, g: 255, b: 255, alpha: 0.05)
        cell.content.backgroundColor = UIColor.whiteColor()
        if let data = dataMgr.dataCell(atRow: indexPath.row, forLine: self.lineID) where data.active {
            cell.content.backgroundColor = UIColor.redColor()
            print(cell.frame.size)
        }
        return cell
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        self.dataMgr = self.VC.tracks[self.VC.currentTrack]

        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "head", forIndexPath: indexPath) as! defaultHeader
        cell.noteLbl.text = notes[lineID % 12]
        cell.octaveLbl.text = " \(lineID / 12 - 1)"
        //        cell.backgroundColor = UIColor.lightGrayColor()
        return cell
    }
}

class horizontalCVFDelegate: NSObject, UICollectionViewDelegateFlowLayout {

    weak var VC: CompositionVC!
    weak var dataMgr: DataMgr!
    var lineID: Int!

    override init() { }

    init(dataMgr: DataMgr, lineID: Int) {
        self.dataMgr = dataMgr
        self.lineID = lineID
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.dataMgr = self.VC.tracks[self.VC.currentTrack]
        dataMgr.activateCell(atRow: indexPath.row, forLine: lineID)
        collectionView.reloadItemsAtIndexPaths([indexPath])
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        self.dataMgr = self.VC.tracks[self.VC.currentTrack]
        if let data = dataMgr.dataCell(atRow: indexPath.row, forLine: lineID) {
            return CGSize(width: (data.length * 30) - 5, height: 30)
        }
        else {
            return CGSize(width: 25, height: 30)
        }
    }
    
    
}
