//
//  SYNQueue.swift
//  SYNQueue
//
//  Created by John Hurliman on 6/18/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import Foundation

public enum LogLevel: Int {
    case Trace   = 0
    case Debug   = 1
    case Info    = 2
    case Warning = 3
    case Error   = 4
    
    public func toString() -> String {
        switch (self) {
            case .Trace:   return "Trace"
            case .Debug:   return "Debug"
            case .Info:    return "Info"
            case .Warning: return "Warning"
            case .Error:   return "Error"
        }
    }
}

public protocol SYNQueueLogProvider {
    func log(level: LogLevel, _ msg: String)
}

public protocol SYNQueueSerializationProvider {
    func serializeTask(task: SYNQueueTask, queueName: String)
    func deserializeTasksInQueue(queue: SYNQueue) -> [SYNQueueTask]
    func removeTask(taskID: String, queue: SYNQueue)
}

public class SYNQueue : NSOperationQueue {
    public let maxRetries: Int
    
    let serializationProvider: SYNQueueSerializationProvider?
    let logProvider: SYNQueueLogProvider?
    var taskHandlers: [String: SYNTaskCallback] = [:]
    let completionBlock: SYNTaskCallback?
    
    public init(queueName: String, maxConcurrency: Int = 1, maxRetries: Int = 5,
        logProvider: SYNQueueLogProvider? = nil,
        serializationProvider: SYNQueueSerializationProvider? = nil,
        completionBlock: SYNTaskCallback? = nil)
    {
        self.maxRetries = maxRetries
        self.logProvider = logProvider
        self.serializationProvider = serializationProvider
        self.completionBlock = completionBlock
        
        super.init()
        
        self.name = queueName
        self.maxConcurrentOperationCount = maxConcurrency
    }
    
    public func addTaskHandler(taskType: String, taskHandler:SYNTaskCallback) {
        taskHandlers[taskType] = taskHandler
    }
    
    public func loadSerializedTasks() {
        if let sp = serializationProvider {
            let tasks = sp.deserializeTasksInQueue(self)
            
            for task in tasks {
                task.setupDependencies(tasks)
                addDeserializedTask(task)
            }
        }
    }
    
    override public func addOperation(op: NSOperation) {
        if  let sp = serializationProvider,
            let op = op as? SYNQueueTask,
            let queueName = op.queue?.name
        {
            sp.serializeTask(op, queueName: queueName)
        }
        
        op.completionBlock = { self.taskComplete(op) }
        super.addOperation(op)
    }
    
    func addDeserializedTask(task: SYNQueueTask) {
        task.completionBlock = { self.taskComplete(task) }
        super.addOperation(task)
    }
    
    func runTask(task: SYNQueueTask) {
        if let handler = taskHandlers[task.taskType] {
            handler(task)
        } else {
            log(.Warning, "No handler registered for task \(task.taskID)")
            task.cancel()
        }
    }
    
    func taskComplete(op: NSOperation) {
        if let task = op as? SYNQueueTask {
            if let handler = completionBlock {
                handler(task)
            }
            
            if let sp = serializationProvider, let queue = task.queue {
                sp.removeTask(task.taskID, queue: queue)
            }
        }
    }
    
    func log(level: LogLevel, _ msg: String) {
        logProvider?.log(level, msg)
    }
}
