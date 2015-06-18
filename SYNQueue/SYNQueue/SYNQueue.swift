//
//  SYNQueue.swift
//  SYNQueue
//
//  Created by John Hurliman on 6/18/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import Foundation

public class SYNQueue : NSOperationQueue {
    let taskHandler: SYNTaskCallback
    
    public init(queueName: String, maxConcurrency: Int, taskHandler: SYNTaskCallback) {
        self.taskHandler = taskHandler
        
        super.init()
        
        self.name = queueName
        self.maxConcurrentOperationCount = maxConcurrency
    }
    
    //    public convenience init(dictionary: [String: AnyObject?]) {
    //        // FIXME:
    //    }
    
    override public func addOperation(op: NSOperation) {
        // FIXME: Serialization
        
        super.addOperation(op)
    }
    
    public func toDictionary() -> [String: AnyObject?] {
        return [:]
    }
    
    func runTask(task:SYNQueueTask) {
        
    }
}
