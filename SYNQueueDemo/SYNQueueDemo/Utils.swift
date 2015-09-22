//
//  Utils.swift
//  SYNQueueDemo
//
//  Created by John Hurliman on 6/19/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import Foundation
import SYNQueue

func arrayMax<T: Comparable>(array: [T]) -> T? {
    return array.reduce(array.first) { return $0 > $1 ? $0 : $1 }
}

func findIndex<T: Equatable>(array: [T], _ valueToFind: T) -> Int? {
    for (index, value) in array.enumerate() {
        if value == valueToFind {
            return index
        }
    }
    return nil
}

func runOnMainThread(callback:dispatch_block_t) {
    dispatch_async(dispatch_get_main_queue(), callback)
}

func runOnMainThreadAfterDelay(delay:Double, _ callback:()->()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
        callback()
    })
}

func error(msg: String) -> NSError {
    return NSError(domain: "Error", code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
}
