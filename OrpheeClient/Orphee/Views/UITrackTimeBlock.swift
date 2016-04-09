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
    class var width: Int { return 75; };

    /// A UITrackTimeBlock button's height.
    class var height: Int { return 30; };

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

    weak var color: UIColor? = UIColor.whiteColor();
    var note: UInt32 = 0;
    var active: Bool = false {
        willSet(act) {
            self.backgroundColor = act ? UIColor ( red: 1.0, green: 0.8054, blue: 0.0, alpha: 1.0 ) : UIColor(red: (104/255.0), green: (186/255.0), blue: (246/255.0), alpha: 1.0)
;
        }
    };
    weak var graph: AudioGraph! = nil;

    /// MARK: Constructors
    //

    /// Creates a UITrackTimeBlock button.
    ///
    /// - parameter color:   The new button's color.
    /// - parameter row:     The row the new button will belong to.
    /// - parameter column:  The column the new button will belong to.
    ///
    /// - returns: A UITrackTimeBlock `color` button belonging at `row` X `column`
    class func timeBlock(row row: Int, column: Int, note: UInt32, graph: AudioGraph) -> UITrackTimeBlock {

        let tBlock: UITrackTimeBlock = UITrackTimeBlock(row: row, column: column);

        tBlock.pos = column;
        tBlock.row = row;
//        tBlock.setImage(image, forState: .Normal);
        tBlock.note = note;
        tBlock.graph = graph;
        tBlock.addTarget(tBlock, action: #selector(UITrackTimeBlock.onTouchDown), forControlEvents: UIControlEvents.TouchDown);
        tBlock.addTarget(tBlock, action: #selector(UITrackTimeBlock.onClick), forControlEvents: UIControlEvents.TouchUpInside);
        return tBlock;
    }

    /// MARK: Initializers
    //

    /// Returns an object initialized from data in a given unarchiver.
    ///
    /// - parameter aDecoder:    An unarchiver object.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);

        let frame = self.frame;
        self.originX = Int(frame.origin.x);
        self.originY = Int(frame.origin.y);
    }

    /// Returns a UITrackTimeBlock button initialized at the given row and column.
    ///
    /// - parameter row:     The row the new button will belong to.
    /// - parameter column:  The column the new button will belong to.
    init(row: Int, column: Int) {
        super.init(frame: CGRect(x: 0, y: 0, width: UITrackTimeBlock.width, height: UITrackTimeBlock.height));

        self.backgroundColor = UIColor(red: 26 / 255, green: 109 / 255, blue: 1, alpha: 1)
        self.pos = column;
        self.row = row;
    }

    /// Returns a UITrackTimeBlock button initialized at the given position (rounded to nearest row and column).
    ///
    /// - parameter pos_x:   The position on the X axis the new button will belong to (rounded to the closest column).
    /// - parameter pos_y:   The position on the Y axis the new button will belong to (rounded to the closest row).
    private init(pos_x: Int, pos_y: Int) {
        super.init(frame: CGRect(x: pos_x, y: pos_y, width: UITrackTimeBlock.width, height: UITrackTimeBlock.height));

        self.backgroundColor = UIColor(red: 26 / 255, green: 109 / 255, blue: 1, alpha: 1)
        self.pos = pos_x / (UITrackTimeBlock.width + 10);
        self.row = pos_y / (UITrackTimeBlock.height + 10);
    }

    /// MARK: Responders
    //

    /// The responder called when the button is clicked.
    func onClick() {

        print("release button #\(pos) on row #\(row)");
        graph.stopNote(note);
    }

    func onTouchDown() {

        print("press button #\(pos) on row #\(row)");
        active = !active;
        graph.playNote(note);
    }
}
