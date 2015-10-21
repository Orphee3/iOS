//
//  eNoteLength.swift
//  FileManagement
//
//  Created by JohnBob on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

///  All supported note lengths
public enum eNoteLength: Float32 {
    ///  2 notes
    case breve              = 8      // carrée
    ///  1 note
    case semibreve          = 4      // ronde
    ///  1/2 note
    case minim              = 2      // blanche
    ///  1/4 note
    case crotchet           = 1      // noire
    ///  1/8 note
    case quaver             = 0.5    // croche
    ///  1/16 note
    case semiquaver         = 0.25   // double croche
    ///  1/32 note
    case demisemiquaver     = 0.125  // triple croche
    ///  1/64 note
    case hemidemisemiquaver = 0.0625 // quadruple croche
}
