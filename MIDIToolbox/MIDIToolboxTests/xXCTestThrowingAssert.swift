//
//  xXCTestThrowingAssert.swift
//  FileManagement
//
//  Created by JohnBob on 31/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import XCTest

func XCTAssertThrows<T>(@autoclosure fn: () throws -> T, message: String = "") {

    do {
        let result = try fn()
        XCTFail(message + " got \(result)");
    }
    catch {
    }
}

func XCTAssertThrowsSpecific<R, T where T: ErrorType, T: Equatable>(@autoclosure fn: () throws -> R, exception: T, message: String = "") {

    do {
        let result = try fn()
        XCTFail(message + " got \(result)");
    }
    catch let e as T {
        XCTAssertEqual(e, exception, message)
    }
    catch {
        XCTFail(message + " got \(error)");
    }
}

func XCTAssertDoesNotThrow<T>(@autoclosure fn: () throws -> T, message: String = "") {

    do {
        try fn()
    }
    catch {
        XCTFail(message + "\n=> \(error)");
    }
}

func XCTAssertDoesNotThrowSpecific<R, T where T: ErrorType, T: Equatable>(@autoclosure fn: () throws -> R, exception: T, message: String = "") {

    do {
        try fn()
    }
    catch {
        if let err = error as? T where err == exception {
            XCTFail(message + "\n=> \(error)");
            return;
        }
        else {
            debugPrint(error);
        }
    }
}
