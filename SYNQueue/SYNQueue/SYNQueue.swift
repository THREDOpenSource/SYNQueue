//
//  SYNQueue.swift
//  SYNQueue
//
//  Created by John Hurliman on 6/18/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import Foundation

public class SYNQueue : NSOperationQueue {
    public let maxRetries: Int
    var taskHandlers: [String: SYNTaskCallback] = [:]
    
    public init(queueName: String, maxConcurrency: Int, maxRetries: Int) {
        self.maxRetries = maxRetries
        
        super.init()
        
        self.name = queueName
        self.maxConcurrentOperationCount = maxConcurrency
    }
    
    public func addTaskHandler(taskType: String, taskHandler:SYNTaskCallback) {
        taskHandlers[taskType] = taskHandler
    }
    
    override public func addOperation(op: NSOperation) {
        // FIXME: Serialization
        
        super.addOperation(op)
    }
    
    public func toDictionary() -> [String: AnyObject?] {
        return [:]
    }
    
    func runTask(task:SYNQueueTask) {
        
        if let handler = taskHandlers[task.taskType] {
            handler(task)
        }
    }
    
    func taskComplete(task: SYNQueueTask) {
        
    }
}
