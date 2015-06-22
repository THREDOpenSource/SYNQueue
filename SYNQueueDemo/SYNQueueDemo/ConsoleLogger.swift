//
//  ConsoleLogger.swift
//  SYNQueueDemo
//
//  Created by John Hurliman on 6/20/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import Foundation
import SYNQueue

func log(level: LogLevel, msg: String) {
    return ConsoleLogger.log(level, msg)
}

@objc
class ConsoleLogger : SYNQueueLogProvider {
    // MARK: - SYNQueueLogProvider Delegates
    
    func log(level: LogLevel, _ msg: String) {
        return ConsoleLogger.log(level, msg)
    }
    
    class func log(level: LogLevel, _ msg: String) {
        runOnMainThread { println("[\(level.toString().uppercaseString)] \(msg)") }
    }
}
