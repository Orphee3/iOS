//
//  BlockArrayList.swift
//  Orphee
//
//  Created by JohnBob on 05/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import FileManagement

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
            for (idx, button) in array.buttons.enumerate() {
                let noteValue = button!.active ? Int(array.note) : 0;
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
        for notesAtDt in rawList {
            var activeNotesAtDt = notesAtDt.filter({ return $0 != 0 });
            if (activeNotesAtDt.count > 0) {
                cleanList.append(notesAtDt)
            }
            else {
                cleanList.append(activeNotesAtDt);
            }
        }
        return cleanList;
    }

    func getCleanedList() -> [[Int]] {
        return cleanList(getRawNoteList());
    }

    func getFormattedNoteList() -> [[MIDINoteMessage]] {

        let cleanedList = getCleanedList();
        var midiNoteMsgs: [[MIDINoteMessage]] = [[MIDINoteMessage]](count: cleanedList.count, repeatedValue: []);
        for array in blockArrays {
            let notesForLine = cleanedList.map({ $0.contains(Int(array.note)) });
            for (idx, note) in notesForLine.enumerate() where note == true {
                midiNoteMsgs[idx].append(
                    MIDINoteMessage(channel: 0, note: UInt8(array.note), velocity: 76, releaseVelocity: 0, duration: eNoteLength.crotchet.rawValue)
                );
            }
        }
        print(cleanedList);
        print(midiNoteMsgs);
        return midiNoteMsgs;
    }

    /// FIXME: Make it so attribution of notes depends on the note's value. \
    //         (Crash ATM, if given less notes than arrays).
    func setBlocksFromList(list: [[Int]]) {

        for (idx, array) in blockArrays.enumerate() {
            for (dt, contains) in list.map({ $0.contains(Int(array.note)) }).enumerate() {
                blockArrays[idx].buttons[dt]?.active = contains;
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
