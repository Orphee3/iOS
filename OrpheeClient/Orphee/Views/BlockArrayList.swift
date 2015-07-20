//
//  BlockArrayList.swift
//  Orphee
//
//  Created by JohnBob on 05/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

class BlockArrayList {

    var blockArrays: [UITimeBlockArray] = [];
    var endPos: (x: Int, y: Int) = (0, 0);
    var blockLength: Int = 0;
    var arrayCount: Int {
        get {
            return blockArrays.count;
        }
    }

    private func getRawNoteList() -> [[Int]] {

        var list: [[Int]] = [];
        for array in blockArrays {
            for (idx, block) in enumerate(array.buttons) {
                var noteValue = block!.active ? Int(block!.note) : 0;
                if (list.endIndex > idx) {
                    list[idx].append(noteValue);
                }
                else {
                    list.append([noteValue]);
                }
            }
        }
        return list;
    }

    private func cleanList(rawList: [[Int]]) -> [[Int]] {

        var cleanList: [[Int]] = [];
        for subl in rawList {
            var cleaned = subl.filter({ return $0 != 0 });
            if (cleaned.count > 0) {
                cleanList.append(subl)
            }
            else {
                cleanList.append(cleaned);
            }
        }
        return cleanList;
    }

    func getFormattedNoteList() -> [[Int]] {

        return cleanList(getRawNoteList());
    }

    /// FIXME: Make it so attribution of notes depends on the note's value. \
    //         (Crash ATM, if given less notes than arrays).
    func setBlocksFromList(list: [[Int]]) {

        for (idx, array) in enumerate(blockArrays) {

            for (dt, notesAtTime) in enumerate(list) {
                if (notesAtTime.count > 0) {
                    array.buttons[dt]?.active = notesAtTime[idx] > 0;
                }
            }
        }
    }

    func resetBlocks() {

        for array in blockArrays {
            for block in array.buttons {
                block?.active = false;
            }
        }
    }

    func addBlocks(number: Int) {

        blockLength += number;
        for array in blockArrays {
            array.addButtons(number, color: UIColor.redColor());
            endPos = array.endPos;
        }
    }

    func removeBlocks(number: Int) {

        blockLength -= number;
        for array in blockArrays {
            array.removeButtons(number);
            endPos = array.endPos;
        }
    }

    func updateProperties() {

        for array in blockArrays {
            endPos = array.endPos;
            blockLength = array.getSize();
        }
    }
}
