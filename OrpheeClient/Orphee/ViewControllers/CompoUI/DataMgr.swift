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

public extension Dictionary where Key: FloatLiteralConvertible, Value: CollectionType, Value.Generator.Element == MIDINoteMessage {//Value: _ArrayType, Value.Generator.Element == MIDINoteMessage {
    func getMinMaxNotes() -> (Min: UInt8, Max: UInt8) {
        let mins = self.flatMap { (k, v) in v.minElement({ $0.note < $1.note })?.note }
        let maxs = self.flatMap { (k, v) in v.maxElement({ $0.note < $1.note })?.note }
        let min = mins.minElement() ?? 0
        let max = maxs.maxElement() ?? min
        return (min, max)
    }

    func getMinNoteLength() -> Float32 {
        return self.flatMap { (k, v) in v.minElement({ $0.duration < $1.duration })?.duration }.sort().first ?? 0
    }
}

class DataMgr: NSObject {

    struct sDataCell {
        var active: Bool = false
        var length: Int = 4
        var noteMsg: MIDINoteMessage? = nil {
            willSet {
                if let note = newValue {
                    self.length = DataMgr.sizes[note.duration] ?? 1
                }
            }
        }
    }

    var highestNote: Int = 127
    var minimalDuration = 2
    var data = [[sDataCell]]()
    static let sizes: [Float32 : Int] = [
        eNoteLength.minim.rawValue : 8,
        eNoteLength.crotchet.rawValue : 4,
        eNoteLength.quaver.rawValue : 2,
        eNoteLength.semiquaver.rawValue : 1
    ]
    static let lengths: [Int : Float32] = [
        8 : eNoteLength.minim.rawValue,
        4 : eNoteLength.crotchet.rawValue,
        2 : eNoteLength.quaver.rawValue,
        1 : eNoteLength.semiquaver.rawValue
    ]
    var lines: Int { return data.count }
    var cellCount: Int { return data.reduce(0, combine: { $0 + $1.count }) }

    init(lineCount: Int, cellPerLine: Int, highestNote: Int = 127) {
        self.highestNote = DataMgr.normaliseNote(highestNote)
        for _ in 0..<lineCount {
            let line = [sDataCell](count: cellPerLine, repeatedValue: sDataCell())
            //            line.appendContentsOf()
            data.append(line)
        }
    }

    convenience init(timedMsgCollection: TimedMidiMsgCollection) {
        self.init(lineCount: 128, cellPerLine: 0)

        self.dataFromTimedMidiMsgsCollection(timedMsgCollection)
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
                cell.noteMsg = MIDINoteMessage(channel: 0, note: UInt8(self.noteForLine(line)), velocity: 76, releaseVelocity: 0, duration: DataMgr.lengths[cell.length]!)
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

    func lastActiveCellIndex(forLine line: Int) -> Int? {
        if self.isValidIndex(nil, line: line) {
            var lastActiveCellIdx = 0
            let count = self.data[line].count
            let ln = self.data[line]
            for idx in 0..<count {
                if ln[idx].active {
                    lastActiveCellIdx = idx
                }
            }
            return lastActiveCellIdx
        }
        return nil
    }

    func noteForLine(line: Int) -> Int {
        if self.isValidIndex(nil, line: line) {
            return highestNote - line //lineIdxForNote(line)
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
                    let timeStmp = MusicTimeStamp(self.startTimeForCell(atRow: idx, forLine: line) ?? 0)
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

    func dataFromTimedMidiMsgsCollection(timedMsgCollection: TimedMidiMsgCollection) {
        self.resetData()

        let timedMsgs = timedMsgCollection.sort { $0.0.0 < $0.1.0 }
        let minDuration = timedMsgCollection.getMinNoteLength()

        timedMsgs.forEach { (tmStmp, msgs) in
            msgs.forEach { noteMsg in
                let tmStmp = Float32(tmStmp)
                let lineIdx = Int(noteMsg.note)
                let lastActiveCellTmStmp = Float32(self.endTimeForLastActiveCell(forLine: lineIdx))
                let emptyCellsForLine = (tmStmp - lastActiveCellTmStmp) / minDuration
                var cell = sDataCell(active: false, length: DataMgr.sizes[minDuration]!, noteMsg: nil)
                if emptyCellsForLine > 0 {
                    let cellArray = [sDataCell](count: Int(emptyCellsForLine), repeatedValue: cell)
                    self.data[lineIdx].appendContentsOf(cellArray)
                }
                cell.active = true
                cell.noteMsg = noteMsg
                self.data[lineIdx].append(cell)
            }
        }
        self.padLinesWithCells(DataMgr.sizes[minDuration]!)
    }


    func endTimeForLastActiveCell() -> Float32 {
        var endTime: Float32 = 0
        for line in 0..<lines {
            if case let lineEnd = endTimeForLastActiveCell(forLine: line) where lineEnd > endTime {
                endTime = lineEnd
            }
        }
        return endTime
    }

    func startTimeForLastActiveCell() -> Float32 {
        var lastCellStartTime: Float32 = 0
        for line in 0..<lines {
            if case let lastCellStart = startTimeForLastActiveCell(forLine: line) where lastCellStart > lastCellStartTime {
                lastCellStartTime = lastCellStart
            }
        }
        return lastCellStartTime
    }

    func endTimeForLastActiveCell(forLine line: Int) -> Float32 {
        let index = self.lastActiveCellIndex(forLine: line) ?? 0
        return endTimeForCell(atRow: index, forLine: line) ?? 0
    }

    func startTimeForLastActiveCell(forLine line: Int) -> Float32 {
        let index = self.lastActiveCellIndex(forLine: line) ?? 0
        return startTimeForCell(atRow: index, forLine: line) ?? 0
    }

    func endTimeForCell(atRow row: Int, forLine line: Int) -> Float32? {
        if self.isValidIndex(row, line: line) {
            let ln = data[line]
            return ln[0...row].reduce(0, combine: { $0! + DataMgr.lengths[$1.length]! })
        }
        return nil
    }

    func startTimeForCell(atRow row: Int, forLine line: Int) -> Float32? {
        if self.isValidIndex(row, line: line) {
            let ln = data[line]
            return ln[0..<row].reduce(0, combine: { $0! + DataMgr.lengths[$1.length]! })
        }
        return nil
    }


    func endLengthForLastActiveCell() -> Int {
        var endLength: Int = 0
        for line in 0..<lines {
            if case let lineEnd = endLengthForLastActiveCell(forLine: line) where lineEnd > endLength {
                endLength = lineEnd
            }
        }
        return endLength
    }

    func startLengthForLastActiveCell() -> Int {
        var lastCellStartLength: Int = 0
        for line in 0..<lines {
            if case let lastCellStart = startLengthForLastActiveCell(forLine: line) where lastCellStart > lastCellStartLength {
                lastCellStartLength = lastCellStart
            }
        }
        return lastCellStartLength
    }

    func endLengthForLastActiveCell(forLine line: Int) -> Int {
        let index = self.lastActiveCellIndex(forLine: line) ?? 0
        return endLengthForCell(atRow: index, forLine: line) ?? 0
    }

    func startLengthForLastActiveCell(forLine line: Int) -> Int {
        let index = self.lastActiveCellIndex(forLine: line) ?? 0
        return startLengthForCell(atRow: index, forLine: line) ?? 0
    }

    func endLengthForCell(atRow row: Int, forLine line: Int) -> Int? {
        if self.isValidIndex(row, line: line) {
            let ln = data[line]
            return ln[0...row].reduce(0, combine: { $0 + $1.length })
        }
        return nil
    }

    func startLengthForCell(atRow row: Int, forLine line: Int) -> Int? {
        if self.isValidIndex(row, line: line) {
            let ln = data[line]
            return ln[0..<row].reduce(0, combine: { $0 + $1.length })
        }
        return nil
    }


    func isValidIndex(row: Int?, line: Int) -> Bool {
        if line < 0 || line > lines { return false }
        if let row = row where row < 0 || row >= data[line].count  { return false }
        return true
    }

    func resetData() {
        for line in 0..<self.lines {
            self.data[line].removeAll()
        }
    }

    func padLinesWithCells(length: Int?) {
        var minDuration: Int
        if let duration = length {
            self.minimalDuration = duration
            minDuration = duration
        }
        else { minDuration = self.minimalDuration }
        let maxTmStmp = self.endLengthForLastActiveCell()
        for line in 0..<self.lines {
            let endTime = self.endLengthForLastActiveCell(forLine: line)
            if case let emptyCellsNbr = (maxTmStmp - endTime) / minDuration
                where emptyCellsNbr > 0 {

                let emptyCells = [sDataCell](count: emptyCellsNbr, repeatedValue: sDataCell(active: false, length: minDuration, noteMsg: nil))
                self.data[line].appendContentsOf(emptyCells)
            }
        }
    }

    class func normaliseNote(note: Int, highestNote: Int = 127) -> Int {
        if note > highestNote { return highestNote }
        if note < 0 { return 0 }
        return note
    }
}
