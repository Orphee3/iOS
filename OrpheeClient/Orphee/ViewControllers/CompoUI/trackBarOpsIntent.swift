//
//  trackBarOpsIntent.swift
//  CompoUI
//
//  Created by John Bobington on 22/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit
import Tools


class trackBarDataSrc: NSObject, UICollectionViewDataSource {

    @IBOutlet weak var VC: CompositionVC!
    var deleteMode = false

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.VC.tracks.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("trackCell", forIndexPath: indexPath) as! defaultCell
        if let content = cell.content as? trackItemView {
            content.deleteButton.tag = indexPath.row
            content.muteButton.tag = indexPath.row
            content.active = (indexPath.row == self.VC.currentTrack)
            content.muted = self.VC.mutedTracks.contains(indexPath.row)
            content.deleteButton.hidden = !deleteMode
            content.muteButton.hidden = deleteMode
        }
        return cell
    }
}

class trackBarDelegate: NSObject, UICollectionViewDelegate {
    @IBOutlet weak var VC: CompositionVC!

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.VC.changeCurrentTrack(indexPath.row)
        collectionView.reloadData()
    }
}

class trackBarOpsIntent: NSObject {

    @IBOutlet weak var VC: CompositionVC!
    @IBOutlet weak var dataSrc: trackBarDataSrc!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var endDelBtn: UIButton!
    @IBOutlet weak var trackEditBtns: UIStackView!

    @IBAction func addTrack() {
        self.VC.addTrack()
        self.refresh()
    }

    @IBAction func rmTrack(button: UIButton) {
        self.VC.removeTrack(button.tag)
        self.refresh()
    }

    @IBAction func startDeleteMode() {
        self.dataSrc.deleteMode = true
        self.collection.reloadData()
        self.trackEditBtns.hidden = true
        self.trackEditBtns.subviews.forEach { $0.hidden = true }
        self.endDelBtn.hidden = false
        self.endDelBtn.imageView?.hidden = false
    }

    @IBAction func endDeleteMode() {
        self.dataSrc.deleteMode = false
        self.collection.reloadData()
        self.trackEditBtns.hidden = false
        self.trackEditBtns.subviews.forEach { $0.hidden = false }
        self.endDelBtn.hidden = true
    }

    @IBAction func muteTrack(sender: UIButton) {
        self.VC.toggleMute(sender.tag)
        self.refresh()
    }

    func refresh() {
        self.collection.reloadData()
    }
}