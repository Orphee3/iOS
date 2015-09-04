//
// Created by JohnBob on 23/07/15.
// Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

let kOrpheeDebug_MIDIWriter_initFailed: String = "\n\nMIDIWriter init failed.\n\n";
let kOrpheeDebug_MIDIWriter_writeOk: String = "\n\nMIDIWriter write succeeded.\n\n";
let kOrpheeDebug_MIDIWriter_writeFailed: String = "\n\nMIDIWriter write failed.\n\n";

let kOrpheeDebug_eMidiEventType_tooManyPossibleEvents: String = "Too many possible events for this Byte.";

let kOrpheeDebug_procHelpers_reachedEndOfTrack: String = "got end of track. Should exit.";

let kOrpheeDebug_metaEventProc_timeSigDataInvalidLength: String = "TimeSig got wrong length !";
let kOrpheeDebug_metaEventProc_setTempoDataInvalidLength: String = "Tempo got wrong length !";

let kOrpheeDebug_bufferCreator_noEventsInTrack: String = "No events in given track: Ignoring";
let kOrpheeDebug_bufferCreator_printInputDataSize = { (input: Int) -> String in return String("\ntotal data size \(input)") };
let kOrpheeDebug_bufferCreator_printBufferSize = { (var input: Int) -> String in
    let output = String("\ntotal data in file buffer \(input)");
    return output;
};

let kOrpheeDebug_dataParser_printAllEvents = { (midiEvents: [pMidiEvent]) -> String in return String("All track Events: \(midiEvents)") };
let kOrpheeDebug_dataParser_printTimeSigs = { (timeSigs: [pMidiEvent]) -> String in return String("got time sig: \(timeSigs)") };
let kOrpheeDebug_dataParser_printSetTempo = { (tempos: [pMidiEvent]) -> String in return String("got set tempo: \(tempos)") };
let kOrpheeDebug_dataParser_printSortedTimedEvents = { (timedEvents: [UInt32 : [pMidiEvent]]) -> String in

    var str = "";
    let keys = timedEvents.keys.sort()
    for dt in keys { str += "key = \(dt)\nValue = \(timedEvents[dt]!)"; }
    return str;
};
