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
    var buttons: [UITrackTimeBlock?] = [];
    var note: UInt32;
    var blockId: String = "";
    weak var graph: AudioGraph!;
    weak var container: UIView?;

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
            let x: Int = size * (UITrackTimeBlock.width + 10) + 10;
            let y: Int = row * (UITrackTimeBlock.height + 10);
            return (x, y);
        }
    }

    /// MARK: Init
    //

    /// Init
    ///
    /// - parameter rowNbr:  The row number represented by this array.
    init(rowNbr: Int, noteValue: Int, inView view: UIView, withGraph: AudioGraph) {

        row = rowNbr;
        note = UInt32(noteValue);
        graph = withGraph;
        container = view;
    }

    /// MARK: Add/Remove buttons
    //

    /// Adds `count` buttons to this array and sets them as subviews to a given view.
    ///
    /// - parameter count:   The number of buttons to add to the array and given view.
    /// - parameter color:   The buttons' color.
    /// - parameter toView:  The view to which to add these buttons.
    func addButtons(count: Int, color: UIColor) {

        for col in 0 ..< count {
            let tBlock = UITrackTimeBlock.timeBlock(row: row, column: col + size, note: note, graph: graph);

            buttons.append(tBlock);
            container!.addSubview(tBlock);
        }
        size = buttons.count;
    }

    /// Removes the `count` last buttons contained in this array from a given view.
    ///
    /// - parameter count:       The number of buttons to remove from the array and given view.
    /// - parameter fromView:    The view from which to remove these buttons.
    func removeButtons(count: Int) {

        let safeCount = (count <= size) ? count : size;

        for _ in 0 ..< safeCount {
            var button = buttons.removeLast();

            button?.removeFromSuperview();
            button = nil;
        }
        size = buttons.count;
    }

    func hide() {
        for tBlock in buttons where (tBlock != nil) {
            tBlock!.hidden = true;
        }
    }

    func show() {
        for tBlock in buttons where (tBlock != nil) {
            tBlock!.hidden = false;
        }
    }

    /// MARK: Accessors
    //

    /// Allows access to the array's size
    func getSize() -> Int {

        return size;
    }
}
