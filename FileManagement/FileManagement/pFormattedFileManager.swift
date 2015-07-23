//
//  pFormattedFileManager.swift
//  FileManagement
//
//  Created by JohnBob on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

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
    var name: String { get };

    ///    Required init. Provides the instance with the name to the managed file.
    ///    If the file already exists, creates the `writer` and `reader` objects.
    ///
    ///    - parameter name: The name of the managed file.
    ///
    ///    - returns: A properly initialized instance of a pFormattedFileManager-conforming class.
    init(name: String);

    ///    Creates a file with the given name in the file format's standard store
    ///    and writes a header containing the provided information.
    ///
    ///    - parameter name:   The name of the new file. If nil, the internal `name` is used instead.
    ///    - parameter content: A dictionnary of values to fill the file.
    ///
    ///    - returns:    - `true` if the file was created.
    ///                 - `false` otherwise.
    func createFile(name: String?, content: [String : AnyObject]?) -> Bool;

    ///    Opens a file with the given name in the file format's standard store
    ///    and reads the data.
    ///
    ///    - parameter name:   The name of the file. If nil, the internal `name` is used instead.
    ///
    ///    - returns:    The data contained in the file, organized as key-value pairs.
    func readFile(name: String?) -> [String : AnyObject]?;

    ///    Deletes the managed file.
    func deleteFile();
}
