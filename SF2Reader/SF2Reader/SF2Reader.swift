//
// Created by John Bobington on 10/01/2016.
// Copyright (c) 2016 ___ORPHEE___. All rights reserved.
//

import Foundation

///  Provides the left-most Byte of given Unsigned integer.
///
///  - parameter input: Any unsigned integer
///
///  - returns: The left-most Byte of the input.
func getFullByte<T where T: UnsignedIntegerType>(input: T) -> UInt8 {
    return UInt8(input.toUIntMax() & 0xFF);
}

///  Build an unsigned integer from provided Bytes.
///
///  - parameter input: Any array of Bytes.
///
///  - returns: An unsigned integer composed from the input.
public func composeFromBytes(input: [UInt8]) -> UInt {

    var out: UInt = 0
    for (idx, byte) in input.reverse().enumerate() {
        print(idx, ":", byte)
        out |= UInt(byte) << UInt(8 * idx)
    }
    return out;
}

///  Build an unsigned integer from provided buffer.
///
///  - parameter input: The buffer from wich to construct the integer.
///
///  - returns: An unsigned integer composed from the input.
func composeFromBytes(input: UnsafePointer<UInt8>, size: Int) -> UInt {

    var out: UInt = 0
    var inp = input
    for pos in (0..<size) {
        let byte = inp.memory
        out += UInt(byte) << UInt(8 * pos)
        inp = inp.successor()
        print(pos, ":", byte)
    }
    return out
}

class SF2Reader {

    let path: String
    let reader: DefaultReader

    init(forPath path: String) {
        self.path = path
        self.reader = try! DefaultReader(path: path)
    }

    func getChunkID(data: ByteBuffer) -> eSF2ChunkID {
        let str: String = data.getUTF8(4)
        return eSF2ChunkID(rawValue: str)
    }

    func getChunkSize(data: ByteBuffer, limit: (UInt32) -> Bool = { _ in return true }) -> Int {
        let value = data.getUInt32()
        guard limit(value) else {
            return -1
        }
        return Int(value)
    }

    func getChunkData(var data: ByteBuffer, chunkSize: Int) -> [UInt8] {
        data.position += chunkSize
        return []
    }

    func dispatchReader(chunkId id: eSF2ChunkID) -> Bool {
        if (id == eSF2ChunkID.INFO) { return false }
        else if (id == eSF2ChunkID.SFBK) { return false }
        else if (id == eSF2ChunkID.LIST) { return false }
        else if (id == eSF2ChunkID.SDTA) { return false }
        else if (id == eSF2ChunkID.PDTA) { return false }
        return false
    }
}
