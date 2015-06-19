//
//  Utils.swift
//  SYNQueueDemo
//
//  Created by John Hurliman on 6/19/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import Foundation

class Utils {
    class func findIndex<T: Equatable>(array: [T], valueToFind: T) -> Int? {
        for (index, value) in enumerate(array) {
            if value == valueToFind {
                return index
            }
        }
        return nil
    }
    
    class func runOnMainThread(callback:dispatch_block_t) {
        dispatch_async(dispatch_get_main_queue(), callback)
    }
    
    class func error(msg: String) -> NSError {
        return NSError(domain: "Error", code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
    }
}
