//
// Created by John Bobington on 10/01/2016.
// Copyright (c) 2016 ___ORPHEE___. All rights reserved.
//

import Foundation

enum eSF2ChunkID: String {

    case RIFF = "RIFF"
    case SFBK = "sfbk"
    case LIST = "LIST"
    case INFO = "INFO"
    case SDTA = "sdta"
    case PDTA = "pdta"
    case PSTHEAD = "phdr"
    case SFNAME = "INAM"
    case SFID = "irom"
    case INSTNAMES = "inst"


    case UNKNOWN

    init(rawValue: String) {
        switch rawValue {
            case "RIFF": self = .RIFF
            case "sfbk": self = .SFBK
            case "LIST": self = .LIST
            case "INFO": self = .INFO
            case "sdta": self = .SDTA
            case "pdta": self = .PDTA
            case "phdr": self = .PSTHEAD
            case "INAM": self = .SFNAME
            case "irom": self = .SFID
            case "inst": self = .INSTNAMES
            default: self = .UNKNOWN
        }
        print("init eSF2ChunkID with:", "'\(rawValue)'")
    }
}
