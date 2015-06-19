//
//  Utils.swift
//  SYNQueueDemo
//
//  Created by John Hurliman on 6/19/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import Foundation
import SYNQueue

class Utils {
    private static var once = dispatch_once_t()
    private static var _printQueue: SYNQueue? = nil
    private static var printQueue: SYNQueue = {
        dispatch_once(&once) {
            let queue = SYNQueue(queueName: "printQueue", maxConcurrency: 1,
                maxRetries: 0, logProvider: nil, serializationProvider: nil,
                completionBlock: nil)
            
            queue.addTaskHandler("print", taskHandler: {
                (task: SYNQueueTask) in
                
                if let str = task.data["toPrint"] as? String {
                    println(str)
                }
                task.completed(nil)
            })
            
            _printQueue = queue
        }
        
        return _printQueue!
    }()
    
    class func print(toPrint: String) {
        let task = SYNQueueTask(queue: printQueue, taskID:toPrint,
            taskType: "print", dependencyStrs: [], data: ["toPrint": toPrint])
        
        printQueue.addOperation(task)
    }
    
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
    
    class func runOnMainThreadAfterDelay(delay:Double, callback:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
            callback()
        })
    }
    
    class func error(msg: String) -> NSError {
        return NSError(domain: "Error", code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
    }
}
