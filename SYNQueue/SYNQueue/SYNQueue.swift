//
//  SYNQueue.swift
//  SYNQueue
//
//  Created by John Hurliman on 6/18/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import Foundation

public protocol SYNQueueSerializationProvider {
    
    func serializeTask(task: SYNQueueTask)
    func deserializeTasksWithQueue(queue: SYNQueue) -> Array<SYNQueueTask>
    func removeTask(task: SYNQueueTask)
}

public class SYNQueue : NSOperationQueue {
    public let maxRetries: Int
    public let serializationProvider: SYNQueueSerializationProvider?
    var taskHandlers: [String: SYNTaskCallback] = [:]
    let completionBlock: SYNTaskCallback?
    
    public init(queueName: String, maxConcurrency: Int, maxRetries: Int,
        serializationProvider: SYNQueueSerializationProvider?,
        completionBlock: SYNTaskCallback?)
    {
        self.maxRetries = maxRetries
        self.serializationProvider = serializationProvider
        self.completionBlock = completionBlock
        
        super.init()
        
        self.name = queueName
        self.maxConcurrentOperationCount = maxConcurrency
    }
    
    public func addTaskHandler(taskType: String, taskHandler:SYNTaskCallback) {
        taskHandlers[taskType] = taskHandler
    }
    
    override public func addOperation(op: NSOperation) {
        if  let op = op as? SYNQueueTask,
            let sp = serializationProvider {
            sp.serializeTask(op)
        }
        
        op.completionBlock = { self.taskComplete(op) }
        
        super.addOperation(op)
    }
    
    func runTask(task:SYNQueueTask) {
        if let handler = taskHandlers[task.taskType] {
            handler(task)
        } else {
            println("No handler registered for task \(task.taskID)")
            task.cancel()
        }
    }
    
    func taskComplete(op: NSOperation) {
        if let task = op as? SYNQueueTask {
            if let handler = completionBlock {
                handler(task)
            }
            
            if let sp = serializationProvider {
                sp.removeTask(task)
            }
        }
    }
}
