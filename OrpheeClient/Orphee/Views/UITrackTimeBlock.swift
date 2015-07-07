//
//  UITrackTimeBlock.swift
//  Orphee
//
//  Created by JohnBob on 04/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

/// A button representing an arbitrary time unit in the composition area.
/// This button snaps to a grid defined by the `width` and `height` class properties.
class UITrackTimeBlock: UIButton {

    /// A UITrackTimeBlock button's width.
    class var width: Int { return 50; };

    /// A UITrackTimeBlock button's height.
    class var height: Int { return 50; };

    /// The button's column.
    /// When set, it updates `originX`
    var pos: Int = 0 {
        willSet(x) {
            self.originX = x * (UITrackTimeBlock.width + 10) + 10;
        }
    }

    /// The button's row.
    /// When set, it updates `originY`
    var row: Int = 0 {
        willSet(y) {
            self.originY = y * (UITrackTimeBlock.height + 10);
        }
    }

    /// The button's horizontal origin.
    /// When set, it updates the button's frame position.
    var originX: Int = 0 {
        willSet(x) {
            self.frame.origin.x = CGFloat(x);
        }
    }

    /// The button's vertical origin.
    /// When set, it updates the butoon's frame position.
    var originY: Int = 0 {
        willSet(y) {
            self.frame.origin.y = CGFloat(y);
        }
    }

    /// The button's last horizontal line of pixel's position.
    var endX: Int {
        get{
            return (self.originX + UITrackTimeBlock.width);
        }
    }

    /// The button's last vertical line of pixel's position.
    var endY: Int {
        get {
            return (self.originY + UITrackTimeBlock.height);
        }
    }

    /// MARK: Constructors
    //

    /// Creates a UITrackTimeBlock button.
    ///
    /// :param: color   The new button's color.
    /// :param: row     The row the new button will belong to.
    /// :param: column  The column the new button will belong to.
    ///
    /// :returns: A UITrackTimeBlock `color` button belonging at `row` X `column`
    class func timeBlock(#image: UIImage, row: Int, column: Int) -> UITrackTimeBlock {

        var tBlock: UITrackTimeBlock = UITrackTimeBlock(row: row, column: column);

        tBlock.pos = column;
        tBlock.row = row;
        tBlock.setImage(image, forState: .Normal);
        tBlock.addTarget(tBlock, action: Selector("onClick"), forControlEvents: UIControlEvents.TouchUpInside);
        return tBlock;
    }

    /// MARK: Initializers
    //

    /// Returns an object initialized from data in a given unarchiver.
    ///
    /// :param: aDecoder    An unarchiver object.
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);

        var frame = self.frame;
        self.originX = Int(frame.origin.x);
        self.originY = Int(frame.origin.y);
    }

    /// Returns a UITrackTimeBlock button initialized at the given row and column.
    ///
    /// :param: row     The row the new button will belong to.
    /// :param: column  The column the new button will belong to.
    init(row: Int, column: Int) {
        super.init(frame: CGRect(x: 0, y: 0, width: UITrackTimeBlock.width, height: UITrackTimeBlock.height));

        self.pos = column;
        self.row = row;
    }

    /// Returns a UITrackTimeBlock button initialized at the given position (rounded to nearest row and column).
    ///
    /// :param: pos_x   The position on the X axis the new button will belong to (rounded to the closest column).
    /// :param: pos_y   The position on the Y axis the new button will belong to (rounded to the closest row).
    private init(pos_x: Int, pos_y: Int) {
        super.init(frame: CGRect(x: pos_x, y: pos_y, width: UITrackTimeBlock.width, height: UITrackTimeBlock.height));

        self.pos = pos_x / (UITrackTimeBlock.width + 10);
        self.row = pos_y / (UITrackTimeBlock.height + 10);
    }

    /// MARK: Responders
    //

    /// The responder called when the button is clicked.
    func onClick() {
        
        println("button #\(pos) on row #\(row)");
    }
}