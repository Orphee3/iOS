//
//  SF2ReaderTests.swift
//  SF2ReaderTests
//
//  Created by John Bobington on 10/01/2016.
//  Copyright (c) 2016 ___ORPHEE___. All rights reserved.
//

import XCTest
@testable import SF2Reader

class DataMgr {
    var pos: Int = 0
    var buffer: UnsafeMutablePointer<UInt8>

    let head: UnsafeMutablePointer<UInt8>
    let capacity: Int

    var cleanup: Bool = false

    init(capacity: Int) {
        self.capacity = capacity
        self.buffer = UnsafeMutablePointer<UInt8>.alloc(capacity)
        self.head = self.buffer
        cleanup = true
        memset(self.buffer, 0, capacity)
    }

    init(buffer: UnsafePointer<Void>, capacity: Int) {
        self.capacity = capacity
        self.buffer = UnsafeMutablePointer<UInt8>(buffer)
        self.head = self.buffer
    }

    deinit {
        if cleanup {
            head.dealloc(capacity)
        }
    }

    func putUInt8(data: [UInt8]) -> Bool {
        guard self.pos + data.count < self.capacity else {
            return false
        }

        for byte in data {
            buffer.memory = byte
            buffer = buffer.successor()
            pos++
        }
        return true
    }

    func putUTF8(data: String) -> Bool {
        guard self.pos + data.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < self.capacity else {
            return false
        }

        putUInt8(data.utf8.map{ UInt8($0) })
        return true
    }

    func putBuffer(data: UnsafePointer<Void>, size: Int) -> Bool {
        guard self.pos + size < self.capacity else {
            return false
        }
        return true
    }

    func getDataAsChars() -> [Character] {
        var chars = [Character]()
        var tmp = UnsafePointer<UInt8>(head)
        for _ in 0..<capacity {
            if (tmp.memory == 0) { break }
            print(Character(UnicodeScalar(tmp.memory)), separator: "", terminator: "")
            tmp = tmp.successor()
        }
        return chars
    }
    func reset() {
        pos = 0
        buffer = head
        memset(buffer, 0, capacity)
    }
}

class SF2ReaderTests: XCTestCase {

    var reader: SF2Reader!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let name: String = NSBundle(forClass: SF2ReaderTests.self).pathForResource("testBank", ofType: "sf2")!
        reader = SF2Reader(forPath: name)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testcomposeFromBytes() {

        XCTAssertEqual(composeFromBytes([0, 0, 0, 4]), 4)
        XCTAssertEqual(composeFromBytes([0, 0, 1, 0]), 256)

        let data = ByteBuffer(order: BigEndian(), capacity: 10)
        data.putUInt8([0, 0, 0, 4])
        data.rewind()
//        XCTAssertEqual(composeFromBytes(data.contents, size: 4), 4)
        data.rewind()
        data.putUInt8([0, 0, 1, 0])
        data.rewind()
//        XCTAssertEqual(composeFromBytes(data.contents, size: 4), 256)
    }

    func testGetID_returns__expectedValue__when_dataIs_valid() {

        let data = ByteBuffer(order: BigEndian(), capacity: 10)
        data.putUTF8(eSF2ChunkID.RIFF.rawValue)
        data.rewind()
        XCTAssertEqual(reader.getChunkID(data), eSF2ChunkID.RIFF)
        data.rewind()
        data.putUTF8(eSF2ChunkID.SFBK.rawValue)
        data.rewind()
        XCTAssertEqual(reader.getChunkID(data), eSF2ChunkID.SFBK)
        data.rewind()
        data.putUTF8(eSF2ChunkID.LIST.rawValue)
        data.rewind()
        XCTAssertEqual(reader.getChunkID(data), eSF2ChunkID.LIST)
        data.rewind()
        data.putUTF8(eSF2ChunkID.INFO.rawValue)
        data.rewind()
        XCTAssertEqual(reader.getChunkID(data), eSF2ChunkID.INFO)
        data.rewind()
        data.putUTF8(eSF2ChunkID.SDTA.rawValue)
        data.rewind()
        XCTAssertEqual(reader.getChunkID(data), eSF2ChunkID.SDTA)
        data.rewind()
        data.putUTF8(eSF2ChunkID.PDTA.rawValue)
        data.rewind()
        XCTAssertEqual(reader.getChunkID(data), eSF2ChunkID.PDTA)
    }

    func testGetID_returns__UNKNOWN__when_dataIs_invalid() {

        let data = ByteBuffer(order: BigEndian(), capacity: 10)
        data.putUTF8("TOTO")
        data.rewind()
        XCTAssertEqual(reader.getChunkID(data), eSF2ChunkID.UNKNOWN)
    }

    func testGetChunkSize_returns__expectedValue__when_dataIs_valid__and_noLimitIs_applied() {

        let data = ByteBuffer(order: BigEndian(), capacity: 10)
        data.putUInt8([0x0f, 0xff, 0xff, 0xff])
        data.rewind()
        XCTAssertEqual(reader.getChunkSize(data), 268_435_455)
        data.rewind()
        data.putUInt8([0x00, 0xff, 0xff, 0xff])
        data.rewind()
        XCTAssertEqual(reader.getChunkSize(data), 16_777_215)
    }

    func testGetChunkSize_returns__expectedValue__when_dataIs_valid__and_limitIs_applied() {

        let data = ByteBuffer(order: BigEndian(), capacity: 10)
        data.putUInt8([0x0f, 0xff, 0xff, 0xff])
        data.rewind()
        XCTAssertEqual(reader.getChunkSize(data, limit: { val in return val < 20_000_000 }), -1)
        data.rewind()
        data.putUInt8([0x00, 0xff, 0xff, 0xff])
        data.rewind()
        XCTAssertEqual(reader.getChunkSize(data, limit: { val in return val < 20_000_000 }), 16_777_215)
    }

    func testReadSF() {

        let raw = reader.reader.readAllData()
        var data: ByteBuffer = ByteBuffer(order: LittleEndian(), data: UnsafeMutablePointer(raw.bytes), capacity: raw.length + 1, freeOnDeinit: false)

//        let data = DataMgr(buffer: raw.bytes, capacity: raw.length + 1)
        precondition(raw.length > 400)

        var id: eSF2ChunkID
        var size = 0
        var curPos = 0
        var chunk = [UInt8]()

        // GET ID RIFF
        id = reader.getChunkID(data)
        curPos = id.rawValue.characters.count
        print(id)
        XCTAssertEqual(id, eSF2ChunkID.RIFF)

        // GET RIFF CHUNK SIZE
        size = reader.getChunkSize(data)
        curPos += 4
        print(size)
        XCTAssertTrue(size > 0)

        // GET ID RIFF>SFBK
        id = reader.getChunkID(data)
        curPos += id.rawValue.characters.count
        print(id)
        XCTAssertEqual(id, eSF2ChunkID.SFBK)

        // GET ID RIFF>SFBK>LIST
        id = reader.getChunkID(data)
        curPos += id.rawValue.characters.count
        print(id)
        XCTAssertEqual(id, eSF2ChunkID.LIST)

        // GET RIFF>SFBK>LIST>INFO CHUNK SIZE
        size = reader.getChunkSize(data)
        curPos += 4
        print(size)
        XCTAssertTrue(size > 0)

        // GET ID RIFF>SFBK>LIST>INFO
        id = reader.getChunkID(data)
        curPos += id.rawValue.characters.count
        print(id)
        XCTAssertEqual(id, eSF2ChunkID.INFO)

        // GET RIFF>SFBK>LIST>INFO CHUNK DATA
        chunk = reader.getChunkData(data, chunkSize: size - 4)
        curPos += size - 4
//        d!.putUInt8(chunk)
//        print(NSString(bytes: d!.head, length: size - 4, encoding: NSASCIIStringEncoding))
        XCTAssertEqual(chunk.count, size - 4)
//        d = nil

        // GET ID RIFF>SFBK>LIST
        id = reader.getChunkID(data)
        curPos += id.rawValue.characters.count
        print(id)
        XCTAssertEqual(id, eSF2ChunkID.LIST)

        // GET RIFF>SFBK>LIST>SDTA CHUNK SIZE
        size = reader.getChunkSize(data)
        curPos += 4
        print(size)
        XCTAssertTrue(size > 0)

        // GET ID RIFF>SFBK>LIST>SDTA
        id = reader.getChunkID(data)
        curPos += id.rawValue.characters.count
        print(id)
        XCTAssertEqual(id, eSF2ChunkID.SDTA)

        // GET RIFF>SFBK>LIST>SDTA CHUNK DATA
        chunk = reader.getChunkData(data, chunkSize: size - 4)
        curPos += size - 4
        //        print(chunk)
        XCTAssertEqual(chunk.count, size - 4)
//        d = nil


        // GET ID RIFF>SFBK>LIST
        id = reader.getChunkID(data)
        curPos += id.rawValue.characters.count
        print(id)
        XCTAssertEqual(id, eSF2ChunkID.LIST)

        // GET RIFF>SFBK>LIST>PDTA CHUNK SIZE
        size = reader.getChunkSize(data)
        curPos += 4
        print(size)
        XCTAssertTrue(size > 0)

        // GET ID RIFF>SFBK>LIST>PDTA
        id = reader.getChunkID(data)
        curPos += id.rawValue.characters.count
        print(id)
        XCTAssertEqual(id, eSF2ChunkID.PDTA)

        // GET RIFF>SFBK>LIST>PDTA CHUNK DATA
        // GET ID RIFF>SFBK>LIST>PDTA>PHDR
        id = reader.getChunkID(data)
        curPos += id.rawValue.characters.count
        print(id)
        XCTAssertEqual(id, eSF2ChunkID.PSTHEAD)

        // GET RIFF>SFBK>LIST>PDTA CHUNK SIZE
        size = reader.getChunkSize(data)
        curPos += 4
        print(size)
        XCTAssertTrue(size % 38 == 0)

//        var dt = data.head.advancedBy(curPos)
        var it = 0
        let endStructPos = size / 38 - 1
        while (it < endStructPos) {
            let name = data.getUTF8(20)
            print(name.substringToIndex(name.characters.indexOf(Character(UnicodeScalar(0)))!))
            print("preset #", data.getUInt16(), "bank #", data.getUInt16())
            data.getUInt8(14)
//            print(NSString(bytes: data.head.advancedBy(curPos), length: 20, encoding: NSASCIIStringEncoding))
//            let t = DataMgr(buffer: dt, capacity: 20)
//            t.getDataAsChars()
//            dt = dt.advancedBy(38)
//            curPos += 38
            it++
//            print("")
        }
    }
}
