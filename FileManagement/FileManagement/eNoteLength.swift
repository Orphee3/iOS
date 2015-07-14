//
//  eNoteLength.swift
//  FileManagement
//
//  Created by JohnBob on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

///    All supported note lengths
///
///    - breve:              2 notes
///    - semibreve:          1 note
///    - minim:              1/2 note
///    - crotchet:           1/4 note
///    - quaver:             1/8 note
///    - semiquaver:         1/16 note
///    - demisemiquaver:     1/32 note
///    - hemidemisemiquaver: 1/64 note
public enum eNoteLength: Float32 {
    case breve              = 8      // carrée
    case semibreve          = 4      // ronde
    case minim              = 2      // blanche
    case crotchet           = 1      // noire
    case quaver             = 0.5    // croche
    case semiquaver         = 0.25   // double croche
    case demisemiquaver     = 0.125  // triple croche
    case hemidemisemiquaver = 0.0625 // quadruple croche
}
