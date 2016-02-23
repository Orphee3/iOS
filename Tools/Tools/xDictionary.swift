//
//  xDictionary.swift
//  Tools
//
//  Created by John Bobington on 19/12/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation

public extension Dictionary {
    public init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
}

public extension Dictionary {
    public func mapPairs<OutKey: Hashable, OutValue>(@noescape transform: Element throws -> (OutKey, OutValue)) rethrows -> [OutKey: OutValue] {
        return Dictionary<OutKey, OutValue>(try map(transform))
    }

    public func map<OutValue>(@noescape transform: Value throws -> OutValue) rethrows -> [Key: OutValue] {
        return Dictionary<Key, OutValue>(try map { (k, v) in (k, try transform(v)) })
    }

    public func filterPairs(@noescape includeElement: Element throws -> Bool) rethrows -> [Key: Value] {
        return Dictionary(try filter(includeElement))
    }
}