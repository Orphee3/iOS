//
//  FileManagementPerfTests.swift
//  FileManagementPerfTests
//
//  Created by JohnBob on 09/09/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import XCTest
@testable import FileManagement

class FileManagementPerfTests: XCTestCase {
    var fm: pFormattedFileManager? = nil;
    var events: [pTimedMidiEvent] = [];
    var smallestTimeDiv: UInt32 = 3072;

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        fm = MIDIFileManager(name: "test");
        smallestTimeDiv = 3072
        let eventTypes = [eMidiEventType](eMidiEventType.allMIDIEvents)
        for i: UInt32 in 0...100_000 {
            events.append(TimedMidiEvent(type: eventTypes[Int(i % 7)], deltaTime: (i % 25) * 250, reader: processUnknownEvent))
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testReadPerf() {
        measureBlock() {
            self.fm!.readFile(nil);
        }
    }

    func testPerfSort() {
        measureBlock() {
            self.smallestTimeDiv = 3072
            let _ = self.events.sort({ $0.deltaTime < $1.deltaTime })
        }
    }

    func testPerf_buildNoteOnList__using_map() {
        measureBlock() {
            self.smallestTimeDiv = 100
            let _ = self.events.map() { event -> [[Int]] in
                var result: [[Int]] = []
                if (event.deltaTime >= self.smallestTimeDiv && event.deltaTime > 0) {
                    let silences = Int(event.deltaTime / self.smallestTimeDiv);
                    result.appendContentsOf([[Int]](count: silences, repeatedValue: []));
                }
                if (event.type == eMidiEventType.noteOn) {
                    result.append([Int(15)]);
                }
                return result
                }.flatMap({ $0 })
        }
    }

    func testPerf_buildNoteOnList__using_forEach() {
        measureBlock() {
            var result: [[Int]] = []
            self.smallestTimeDiv = 100
            self.events.forEach() { event in
                if (event.deltaTime >= self.smallestTimeDiv && event.deltaTime > 0) {
                    let silences = Int(event.deltaTime / self.smallestTimeDiv);
                    result.appendContentsOf([[Int]](count: silences, repeatedValue: []));
                }
                if (event.type == eMidiEventType.noteOn) {
                    result.append([Int(15)]);
                }
            }
        }
    }

    func testPerf_buildNoteOnList__using_loop() {
        measureBlock() {
            self.smallestTimeDiv = 100
            var i: Int = 0;
            var cleanedEvents: [[Int]] = [[]];
            for event in self.events {
                if (event.deltaTime >= self.smallestTimeDiv && event.deltaTime > 0) {
                    let silences = Int(event.deltaTime / self.smallestTimeDiv);
                    cleanedEvents.appendContentsOf([[Int]](count: silences, repeatedValue: []));
                    i += silences;
                }
                if (event.type == eMidiEventType.noteOn) {
                    cleanedEvents[i].append(Int(02));
                }
            }
        }
    }

    func testPerf_determineSmallestTimeDiv__using_minElement() {
        measureBlock() {
            self.smallestTimeDiv = 384
            let dT: pTimedMidiEvent = self.events.minElement() {
                ($0.deltaTime < $1.deltaTime) && ($0.deltaTime != 0) && ($1.deltaTime != 0)
                }!
            self.smallestTimeDiv = (self.smallestTimeDiv > dT.deltaTime) ? dT.deltaTime : self.smallestTimeDiv
        }
        XCTAssertEqual(smallestTimeDiv, 250);
    }

    func testPerf_determineSmallestTimeDiv__using_loop() {
        measureBlock() {
            self.smallestTimeDiv = 384
            for tmEvent in self.events where tmEvent.deltaTime > 0 {
                self.smallestTimeDiv = (self.smallestTimeDiv > tmEvent.deltaTime) ? tmEvent.deltaTime : self.smallestTimeDiv;
            }
        }
        XCTAssertEqual(smallestTimeDiv, 250);
    }
}
