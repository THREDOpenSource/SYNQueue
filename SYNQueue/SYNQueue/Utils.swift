//
//  Utils.swift
//  SYNQueue
//
//  Created by John Hurliman on 6/18/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import Foundation

func runInBackgroundAfter(seconds: NSTimeInterval, callback:dispatch_block_t) {
    let delta = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds) * Int64(NSEC_PER_SEC))
    dispatch_after(delta, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), callback)
}

func synced(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

func toJSON(obj: AnyObject) -> String? {
    var err: NSError?
    if let json = NSJSONSerialization.dataWithJSONObject(obj, options: .allZeros, error: &err) {
        return NSString(data: json, encoding: NSUTF8StringEncoding) as String?
    } else {
        // TODO: Change this method to throw NSError in Swift 2.0
        //let error = err?.description ?? "nil"
        return nil
    }
}

func fromJSON(str: String) -> AnyObject? {
    if let json = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
        var err: NSError?
        if let obj: AnyObject = NSJSONSerialization.JSONObjectWithData(json, options: .AllowFragments, error: &err) {
            return obj
        } else {
            // TODO: Change this method to throw NSError in Swift 2.0
            //let error = err?.description ?? "nil"
        }
    }
    
    return nil
}
