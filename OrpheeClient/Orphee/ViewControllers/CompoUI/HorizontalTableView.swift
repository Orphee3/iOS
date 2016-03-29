//
//  HorizontalTableView.swift
//  CompoUI
//
//  Created by John Bobington on 23/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

class HorizontalTableView: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var tabDelegate: horizontalCVFDelegate!
    var tabDataSource: horizontalCVDataSource!
    @IBOutlet weak var VC: CompositionVC!

    var layout = UICollectionViewFlowLayout()
    var lineID: Int = 0

    weak var dataMgr: DataMgr!

    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        self.collectionView.frame.size = CGSize(width: self.frame.width - 5, height: 30)
        self.collectionView.layoutIfNeeded()
    }

    private override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupGraphics() {
        self.selectionStyle = .None
//        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.alwaysBounceHorizontal = false
        (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionHeadersPinToVisibleBounds = true
    }

    func setupLayout() {
        self.layout.scrollDirection = .Horizontal
        self.layout.headerReferenceSize = CGSize(width: 50, height: 30)
        self.layout.sectionHeadersPinToVisibleBounds = true
        self.layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10)
        self.layout.minimumInteritemSpacing = 0
        self.layout.minimumLineSpacing = 2.5
    }

    func updateCellData(dataMgr: DataMgr, lineID: Int) {
        self.dataMgr = dataMgr
        self.lineID = lineID
        self.tabDelegate = horizontalCVFDelegate(dataMgr: self.dataMgr, lineID: self.lineID)
        self.tabDataSource = horizontalCVDataSource(dataMgr: self.dataMgr, lineID: self.lineID)
        self.collectionView.dataSource = self.tabDataSource
        self.collectionView.delegate = self.tabDelegate
    }

    func setViewController(vc: CompositionVC) {
        self.VC = vc
        self.tabDelegate.VC = vc
        self.tabDataSource.VC = vc
    }

    func normalizeIndex(row: Int) -> NSIndexPath {
        if row < 0 { return NSIndexPath(forItem: 0, inSection: 0) }
        let rowCount = self.collectionView.numberOfItemsInSection(0)
        if row > rowCount { return NSIndexPath(forItem: rowCount - 1, inSection: 0) }
        return NSIndexPath(forItem: row, inSection: 0)
    }

    func timeForItem(atRow: Int, forLine: Int) -> Float32 {
        return self.dataMgr.startTimeForCell(atRow: atRow, forLine: forLine) ?? 0
    }

    func cellIndexForTime(time: Float32) -> Int {
        if let line = self.dataMgr.lineForIndex(self.lineID) {
            var newTm: Float32 = 0
            for (idx, cell) in line.enumerate() {
                newTm += DataMgr.lengths[cell.length]!
                if newTm >= time { return idx }
            }
        }
        return -1
    }

    func timeForContentOffset(offset: CGPoint) -> Float32 {
        let path = collectionView.indexPathForItemAtPoint(offset)!
        return timeForItem(path.row, forLine: lineID)
    }

    func contentOffsetForTime(time: Float32) -> CGPoint {
        let idx = cellIndexForTime(time)
        let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: idx, inSection: 0))
        let cellPoint = cell?.frame.origin ?? CGPointZero
        let offset = collectionView.convertPoint(cellPoint, fromView: cell)
        return CGPoint(x: offset.x, y: self.collectionView.contentOffset.y)
//        return collectionView
//        return CGPoint(x: CGFloat(Double(time) * 27.5), y: self.collectionView.contentOffset.y)
    }

    func scrollToTime(time: Float32, animated: Bool = true) {
        let r = self.collectionView.frame.size
        let rect = CGRect(origin: self.contentOffsetForTime(time), size: r)
        self.collectionView.scrollRectToVisible(rect, animated: animated)
    }

    func scrollWithOffset(x: CGFloat, animated: Bool = true) {
        let rect = CGRectMake(x, 0, self.collectionView.frame.width, self.collectionView.frame.height)
        self.collectionView.scrollRectToVisible(rect, animated: animated)
    }
}
