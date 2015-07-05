//
//  FormattedFileManager.swift
//  FileManagement
//
//  Created by JohnBob on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

///    Classes managing standardized files should follow this protocol.
public protocol FormattedFileManager: class {

    /// The formatted file type's standard extension.
    static var ext: String { get };

    /// The formatted file type's standard storing directory.
    static var store: String { get };


    /// The object used to write to the managed file.
    var writer: OutputManager { get };

    /// The object used to read from the managed file.
    var reader: InputManager { get };

    /// The name to the managed file.
    var name: String { get };

    ///    Required init. Provides the instance with the name to the managed file.
    ///    If the file already exists, creates the `writer` and `reader` objects.
    ///
    ///    :param: name The name of the managed file.
    ///
    ///    :returns: A properly initialized instance of a FormattedFileManager-conforming class.
    init(name: String);

    ///    Creates a file with the given name in the file format's standard store
    ///    and writes a header containing the provided information.
    ///
    ///    :param: name   The name of the new file. If nil, the internal `name` is used instead.
    ///    :param: header A dictionnary of values to fill the header if necessary.
    ///
    ///    :returns:    - `true` if the file was created.
    ///                 - `false` otherwise.
    func createFile(name: String?, header: [String : AnyObject]?) -> Bool;

    func readFile(name: String?) -> Bool;

    ///    Deletes the managed file.
    func deleteFile();
}
