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
    public let serializationProvider: SYNQueueSerializationProvider
    var taskHandlers: [String: SYNTaskCallback] = [:]
    
    public init(queueName: String, maxConcurrency: Int, maxRetries: Int, serializationProvider: SYNQueueSerializationProvider) {
        self.maxRetries = maxRetries
        self.serializationProvider = serializationProvider
        
        super.init()
        
        self.name = queueName
        self.maxConcurrentOperationCount = maxConcurrency
    }
    
    public func addTaskHandler(taskType: String, taskHandler:SYNTaskCallback) {
        taskHandlers[taskType] = taskHandler
    }
    
    override public func addOperation(op: NSOperation) {
        
        if let op = op as? SYNQueueTask {
            serializationProvider.serializeTask(op)
        } else {
            print("Could not serialize operation because operation was not a SYNQueueTask instance")
        }

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
        
        serializationProvider.removeTask(task)
    }
}
