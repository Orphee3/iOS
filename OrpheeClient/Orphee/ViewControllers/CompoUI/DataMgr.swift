//
//  DataMgr.swift
//  CompoUI
//
//  Created by John Bobington on 26/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import MIDIToolbox

typealias TimedMidiMsg = (MusicTimeStamp, MIDINoteMessage)

class DataMgr: NSObject {

    struct sDataCell {
        var active: Bool = false
        var length: Int = 4
        var noteMsg: MIDINoteMessage? = nil
    }

    var highestNote: Int = 127
    var data = [[sDataCell]]()
    let sizes = [1, 2, 4, 8]
    var lines: Int { return data.count }
    var cellCount: Int { return data.reduce(0, combine: { $0 + $1.count }) }

    init(lineCount: Int, cellPerLine: Int, highestNote: Int = 127) {
        self.highestNote = DataMgr.normaliseNote(highestNote)
        for _ in 0..<lineCount {
            var line = [sDataCell]()
            line.appendContentsOf([sDataCell](count: cellPerLine, repeatedValue: sDataCell()))
            data.append(line)
        }
    }

    override convenience init() {
        self.init(lineCount: 128, cellPerLine: 25)
    }

    func addCellsToAllLines(cellCount: Int) {
        for line in 0..<lines {
            self.addCells(cellCount, forLine: line)
        }
    }

    func addCells(cellCount: Int, forLine line: Int) {
        if self.isValidIndex(nil, line: line) {
            data[line].appendContentsOf([sDataCell](count: cellCount, repeatedValue: sDataCell()))
        }
    }

    func lineForIndex(idx: Int) -> [sDataCell]? {
        if self.isValidIndex(nil, line: idx) {
            return data[idx]
        }
        return nil
    }

    func cellCountForLine(index: Int) -> Int {
        if index < lines && index >= 0 {
            return data[index].count
        }
        return -1
    }

    func dataCell(atRow row: Int, forLine line: Int) -> sDataCell? {
        if self.isValidIndex(row, line: line) {
            return data[line][row]
        }
        return nil
    }

    func activateCell(atRow row: Int, forLine line: Int) {
        if self.isValidIndex(row, line: line) {
            var cell = self.data[line][row]
            cell.active = !cell.active
            if cell.active {
                cell.noteMsg = MIDINoteMessage(channel: 0, note: UInt8(self.noteForLine(line)), velocity: 76, releaseVelocity: 0, duration: Float(cell.length))
            }
            else { cell.noteMsg = nil }
            self.data[line][row] = cell
        }
    }

    func activeCellsForLine(line: Int) -> [sDataCell?] {
        if self.isValidIndex(nil, line: line) {
            var lastIdx = -1
            for (idx, lastActiveCell) in data[line].reverse().enumerate() {
                if lastActiveCell.active { lastIdx = idx; break }
            }
            let count = data[line].count
            if lastIdx >= 0 {
            return data[line][0..<(count - lastIdx)].map() { ($0.active ? $0 : nil) as sDataCell? }
            }
        }
        return []
    }

    func activeCells() -> [[sDataCell?]] {
        var cells = [[sDataCell?]]()
        for line in 0..<lines { cells.append(self.activeCellsForLine(line)) }
        return cells
    }

    func noteForLine(line: Int) -> Int {
        if self.isValidIndex(nil, line: line) {
            return highestNote - line
        }
        return 0
    }

    func lineIdxForNote(note: Int) -> Int {
        if note > self.highestNote { return 0 }
        return self.highestNote - note
    }

    func timedMidiMsgsForActiveCellsInLine(line: Int) -> [TimedMidiMsg] {
        if self.isValidIndex(nil, line: line) {
            var midiMsgs: [TimedMidiMsg] = []
            for (idx, cell) in self.data[line].enumerate() {
                if cell.active {
                    let timeStmp = MusicTimeStamp(self.timeForCell(atRow: idx, forLine: line))
                    midiMsgs.append(TimedMidiMsg(timeStmp, cell.noteMsg!))
                }
            }
            return midiMsgs
        }
        return []
    }

    func timedMidiMsgsForActiveCells() -> [[TimedMidiMsg]] {
        var msgs = [[TimedMidiMsg]]()
        for line in 0..<lines {
            msgs.append(self.timedMidiMsgsForActiveCellsInLine(line))
        }
        return msgs
    }

    func dataAsTimedMidiMsgsCollection() -> TimedMidiMsgCollection {
        var timedMidiMsgCollections: TimedMidiMsgCollection = [:]
        let allTimedMidiMsgs = self.timedMidiMsgsForActiveCells()
        for line in allTimedMidiMsgs {
            for timedMsg in line {
                if let _ = timedMidiMsgCollections[timedMsg.0] {
                    timedMidiMsgCollections[timedMsg.0]!.append(timedMsg.1)
                }
                else {
                    timedMidiMsgCollections[timedMsg.0] = [timedMsg.1]
                }
            }
        }
        return timedMidiMsgCollections
    }

    func timeForCell(atRow row: Int, forLine line: Int) -> Int {
        if self.isValidIndex(row, line: line) {
            let ln = data[line]
            return ln[0..<row].reduce(0, combine: { $0 + $1.length })
        }
        return -1
    }

    func isValidIndex(row: Int?, line: Int) -> Bool {
        if line < 0 || line > lines { return false }
        if let row = row where row < 0 || row > data[line].count  { return false }
        return true
    }

    class func normaliseNote(note: Int, highestNote: Int = 127) -> Int {
        if note > highestNote { return highestNote }
        if note < 0 { return 0 }
        return note
    }
}
