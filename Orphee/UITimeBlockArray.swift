//
//  TimeBlockArray.swift
//  Orphee
//
//  Created by JohnBob on 04/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

class UITimeBlockArray {

    private var buttons: [UITrackTimeBlock?] = [];

    var row: Int = 0 {
        didSet(newValue) {
            for button in self.buttons {
                button?.row = newValue;
            }
        }
    }

    private var size: Int = 0;

    var endPos: (x: Int, y: Int) {
        get {
            var x: Int = size * (UITrackTimeBlock.width + 10) + 10;
            var y: Int = row * (UITrackTimeBlock.height + 10);
            return (x, y);
        }
    }


    init(rowNbr: Int) {

        row = rowNbr;
    }

    func addButtons(count: Int, color: UIColor, toView view: UIView) {

        for (var col = 0; col < count; col++) {
            var tBlock = UITrackTimeBlock.timeBlock(color: color, row: row, column: col + size);

            buttons.append(tBlock);
            view.addSubview(tBlock);
        }
        size = buttons.count;
    }

    func removeButtons(count: Int, fromView view: UIView) {

        let safeCount = (count <= size) ? count : size;

        for (var idx = 0; idx < safeCount; idx++) {
            var button = buttons.removeLast();

            button?.removeFromSuperview();
            button = nil;
        }
        size = buttons.count;
    }
}
