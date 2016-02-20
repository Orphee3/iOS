//
//  trackBarOpsIntent.swift
//  CompoUI
//
//  Created by John Bobington on 22/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit
import Tools

class trackBarOpsIntent: NSObject {

    var trackItems: [trackItemView] = []

    var scroll: UIScrollView!
    @IBOutlet weak var trackBar: UIToolbar!
    @IBOutlet weak var VC: CompositionVC!
    @IBOutlet weak var item1: UIBarButtonItem!
    @IBOutlet weak var item2: UIBarButtonItem!

    func updateLayout() {
//        trackBar.layoutIfNeeded()
//        trackBar.bounds.size.width = trackBar.superview!.bounds.width - 190
//        scroll.frame.size.width = trackBar.bounds.width - 250
//        scroll.frame.origin.x = trackBar.frame.origin.x + 120
//        scroll.frame.origin.y = 7.5
        //        scroll.layoutIfNeeded()
        scroll.frame.size.width = trackBar.frame.width - scroll.frame.origin.x - 200
        print("layout update")
//        for view in trackBar.subviews {
            print(scroll.frame)
//        }
//        print("")
    }

    func setup() {
        self.scroll = item1.customView as! UIScrollView
        scroll.frame.size.height = 20
//        scroll.frame.origin.x += 50
        scroll.frame.size.width = trackBar.frame.width - scroll.frame.origin.x - 200
//        scroll.autoresizingMask = .None
        scroll.showsHorizontalScrollIndicator = false
        scroll.layer.cornerRadius = 10
//        trackBar.items?.insert(UIBarButtonItem(customView: scroll), atIndex: 1)
//        trackBar.addSubview(scroll)
        print(scroll.bounds)
        for _ in self.VC.tracks {
            self.addTrack(self)
        }
    }

    @IBAction func addTrack(sender: AnyObject) {
        let v: trackItemView = trackItemView.fromNib("trackItemView")
        let idx = trackItems.count

        v.deleteButton.addTarget(self, action: Selector("rmTrack:"), forControlEvents: .TouchUpInside)
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("changeTrack:")))
        v.frame.offsetInPlace(dx: CGFloat(idx) * v.frame.width + CGFloat(idx * 10), dy: 0)
        v.active = false
        scroll.addSubview(v)
        trackItems.append(v)
        scroll.contentSize.width += v.frame.width + 10
    }

    @IBAction func rmTrack(sender: UIButton) {
        if let v = sender.superview as? trackItemView, let idx = trackItems.indexOf(v) {
            if v.active { self.trackItems[0].active = true }
            v.removeFromSuperview()
            trackItems.removeAtIndex(idx)
            scroll.contentSize.width -= v.frame.width + 10
            for index in idx..<trackItems.count {
                let view = trackItems[index]
                view.frame.offsetInPlace(dx: -view.frame.width - 10, dy: 0)
            }
        }
    }

    @IBAction func changeTrack(sender: UITapGestureRecognizer) {
        if let view = sender.view as? trackItemView {
            trackItems.forEach() { $0.active = false }
            view.active = true
        }
    }
}