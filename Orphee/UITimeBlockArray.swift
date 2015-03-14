//
//  TimeBlockArray.swift
//  Orphee
//
//  Created by JohnBob on 04/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

class UITimeBlockArray: UIView {

    var buttons: [UITrackTimeBlock?] = [];
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

        for (var col = 0; col < count; col++) {
            var tBlock = UITrackTimeBlock.timeBlock(color: color, row: row, column: col + size);

            buttons.append(tBlock);
            addSubview(tBlock);
        }
        size = buttons.count;
    }

    func removeButtons(count: Int) {

        let safeCount = (count <= size) ? count : size;

        for (var idx = 0; idx < safeCount; idx++) {
            var button = buttons.removeLast();

            button?.removeFromSuperview();
            button = nil;
        }
        size = buttons.count;
    }
}