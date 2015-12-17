//
//  pFormattedFileManager.swift
//  FileManagement
//
//  Created by JohnBob on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import MIDIToolbox

///    Classes managing standardized files should follow this protocol.
public protocol pFormattedFileManager: class {

    /// The formatted file type's standard extension.
    static var ext: String { get };

    /// The formatted file type's standard storing directory.
    static var store: String { get };


    /// The object used to write to the managed file.
    var writer: pOutputManager { get };

    /// The object used to read from the managed file.
    var reader: pInputManager { get };

    /// The name to the managed file.
    var name: String { get set };

    /// The path to the managed file.
    var path: String { get };

    ///    Required init. Provides the instance with the name to the managed file.
    ///    If the file already exists, creates the `writer` and `reader` objects.
    ///
    ///    - parameter name:    The name of the managed file.
    ///
    ///    - returns:   A properly initialized instance of a pFormattedFileManager-conforming class.
    init(name: String);

    ///    Creates a file with the given name in the file format's standard store
    ///
    ///    - returns:   `true` if the file was created, `false` otherwise.
    func createFile(name: String?) -> Bool;

    ///    Writes the information provided by `content` and transformed by an instance of `dataBuilderType`.
    ///
    ///    - parameter name:			The name of the new file. If nil, the internal `name` is used instead.
    ///    - parameter content:			A dictionnary of values to fill the file.
    ///    - parameter dataBuilderType:	The Type in charge of transforming `content` into construct
    ///
    ///    - returns: `true` if `content` was written successfully, `false` otherwise.
    func writeToFile<T where T: pMIDIByteStreamBuilder>(content content: [String : Any]?, dataBuilderType: T.Type) -> Bool;

    ///    Opens a file with the given name in the file format's standard store
    ///    and reads the data.
    ///
    ///    - parameter	name:	The name of the file. If nil, the internal `name` is used instead.
    ///
    ///    - returns:	The data contained in the file, organized as key-value pairs.
    func readFile() -> [String : Any]?;

    ///    Deletes the managed file.
    func deleteFile();
}
