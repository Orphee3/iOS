//
//  TimeBlockArray.swift
//  Orphee
//
//  Created by JohnBob on 04/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

/// This class is a wrapper around a `UITrackTimeBlock` array.
/// It provides
class UITimeBlockArray {

    /// The actual array of `UITrackTimeBlocks`
    private var buttons: [UITrackTimeBlock?] = [];

    /// The row this array represents in the UI.
    var row: Int = 0 {
        didSet(newValue) {
            for button in self.buttons {
                button?.row = newValue;
            }
        }
    }

    /// The number of `UITrackTimeBlocks` this array contains.
    private var size: Int = 0;

    /// The position of the furthest point represented by this array.
    /// The value is calculated when required based on the `size`, the `row` number and the size of the contained buttons.
    var endPos: (x: Int, y: Int) {
        get {
            var x: Int = size * (UITrackTimeBlock.width + 10) + 10;
            var y: Int = row * (UITrackTimeBlock.height + 10);
            return (x, y);
        }
    }

    /// MARK: Init
    //

    /// Init
    ///
    /// :param: rowNbr  The row number represented by this array.
    init(rowNbr: Int) {

        row = rowNbr;
    }

    /// MARK: Add/Remove buttons
    //

    /// Adds `count` buttons to this array and sets them as subviews to a given view.
    ///
    /// :param: count   The number of buttons to add to the array and given view.
    /// :param: color   The buttons' color.
    /// :param: toView  The view to which to add these buttons.
    func addButtons(count: Int, color: UIColor, toView view: UIView) {

        for (var col = 0; col < count; col++) {
            var tBlock = UITrackTimeBlock.timeBlock(image: UIImage(named: "buttonBlue")!, row: row, column: col + size);

            buttons.append(tBlock);
            view.addSubview(tBlock);
        }
        size = buttons.count;
    }

    /// Removes the `count` last buttons contained in this array from a given view.
    ///
    /// :param: count       The number of buttons to remove from the array and given view.
    /// :param: fromView    The view from which to remove these buttons.
    func removeButtons(count: Int, fromView view: UIView) {

        let safeCount = (count <= size) ? count : size;

        for (var idx = 0; idx < safeCount; idx++) {
            var button = buttons.removeLast();

            button?.removeFromSuperview();
            button = nil;
        }
        size = buttons.count;
    }

    /// MARK: Accessors
    //

    /// Allows access to the array's size
    func getSize() -> Int {

        return size;
    }
}
