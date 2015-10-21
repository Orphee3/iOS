//
// Created by JohnBob on 23/07/15.
// Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

/// MIDIWriter's initialization failed.
public let kOrpheeDebug_MIDIWriter_initFailed: String = "\n\nMIDIWriter init failed.\n\n";
/// MIDIWriter write succeeded.
public let kOrpheeDebug_MIDIWriter_writeOk: String = "\n\nMIDIWriter write succeeded.\n\n";
/// MIDIWriter write failed.
public let kOrpheeDebug_MIDIWriter_writeFailed: String = "\n\nMIDIWriter write failed.\n\n";

/// Got too many possible events for given Byte.
public let kOrpheeDebug_eMidiEventType_tooManyPossibleEvents: String = "Too many possible events for this Byte.";

/// Got `End of track` event.
public let kOrpheeDebug_procHelpers_reachedEndOfTrack: String = "got end of track. Should exit.";

/// Invalid data length for 'time signature' event.
public let kOrpheeDebug_metaEventProc_timeSigDataInvalidLength: String = "TimeSig got wrong length !";
/// Invalid data length for 'set tempo' event.
public let kOrpheeDebug_metaEventProc_setTempoDataInvalidLength: String = "Tempo got wrong length !";

/// No events in track.
public let kOrpheeDebug_bufferCreator_noEventsInTrack: String = "No events in given track: Ignoring";
/// Prints data size.
public let kOrpheeDebug_bufferCreator_printInputDataSize = { (input: Int) -> String in return String("\ntotal data size \(input)") };
/// Prints buffer size.
public let kOrpheeDebug_bufferCreator_printBufferSize = { (var input: Int) -> String in
    let output = String("\ntotal data in file buffer \(input)");
    return output;
};

/// Prints all given events.
public let kOrpheeDebug_dataParser_printAllEvents = { (midiEvents: [pMidiEvent]) -> String in return String("All track Events: \(midiEvents)") };
/// Prints all "time signature" events.
public let kOrpheeDebug_dataParser_printTimeSigs = { (timeSigs: [pMidiEvent]) -> String in return String("got time sig: \(timeSigs)") };
/// Prints all "set tempo" events.
public let kOrpheeDebug_dataParser_printSetTempo = { (tempos: [pMidiEvent]) -> String in return String("got set tempo: \(tempos)") };
/// Prints all timed events, sorted by delta-time.
public let kOrpheeDebug_dataParser_printSortedTimedMidiEvents = { (timedEvents: [UInt32 : [pMidiEvent]]) -> String in

    var str = "";
    let keys = timedEvents.keys.sort()
    for dt in keys { str += "key = \(dt)\nValue = \(timedEvents[dt]!)"; }
    return str;
};
