//
//  TimeBlockArray.swift
//  Orphee
//
//  Created by JohnBob on 04/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

class UITimeBlockArray: UIView {

    var buttons: [UITrackTimeBlock] = [];
    var row: Int = 0;
    var size: Int = 0;

    var endPos: (x: Int, y: Int) {
        get {
            var x: Int = size * (UITrackTimeBlock.width + 10) + 10;
            var y: Int = row * (UITrackTimeBlock.height + 10);
            return (x, y);
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }

    init(count: Int, rowNbr: Int, color: UIColor) {

        super.init(frame: CGRect(x: 10, y: 0, width: 0, height: 0));

        row = rowNbr;
        addButtons(count, color: color);
    }

    func addButtons(count: Int, color: UIColor) {

        for col in 0...count {
            var tBlock = UITrackTimeBlock.timeBlock(color: color, row: row, column: col + size);

            buttons.append(tBlock);
            addSubview(tBlock);
        }
        size = buttons.count;
        frame.size = CGSizeMake(CGFloat(endPos.x), CGFloat(endPos.y));
    }

    func removeButtons(count: Int) {

        let safeCount = (count <= size) ? count : size;

        for _ in 0...safeCount {
            var button = buttons.removeLast();

            self.willRemoveSubview(button);
        }
        size = buttons.count;
        frame.size = CGSizeMake(CGFloat(endPos.x), CGFloat(endPos.y));
    }
}