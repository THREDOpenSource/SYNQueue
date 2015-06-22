//
//  SYNQueue.swift
//  SYNQueue
//
//  Created by John Hurliman on 6/18/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import Foundation

/**
Log level for use in the SYNQueueLogProvider `log()` call

- Trace:   "Trace"
- Debug:   "Debug"
- Info:    "Info"
- Warning: "Warning"
- Error:   "Error"
*/
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

/**
*  Conform to this protocol to provide logging to SYNQueue
*/
public protocol SYNQueueLogProvider {
    func log(level: LogLevel, _ msg: String)
}

/**
*  Conform to this protocol to provide serialization (persistence) to SYNQueue
*/
public protocol SYNQueueSerializationProvider {
    func serializeTask(task: SYNQueueTask, queueName: String)
    func deserializeTasksInQueue(queue: SYNQueue) -> [SYNQueueTask]
    func removeTask(taskID: String, queue: SYNQueue)
}

/**
*  SYNQueue is a generic queue with customizable serialization, logging, task handling, retries, and concurrency behavior
*/
public class SYNQueue : NSOperationQueue {
    
    /// The maximum number of times a task will be retried if it fails
    public let maxRetries: Int
    
    let serializationProvider: SYNQueueSerializationProvider?
    let logProvider: SYNQueueLogProvider?
    var tasks = [String: SYNQueueTask]()
    var taskHandlers = [String: SYNTaskCallback]()
    let completionBlock: SYNTaskCallback?
    
    /**
    Initializes a SYNQueue with the provided options
    
    :param: queueName             The name of the queue
    :param: maxConcurrency        The maximum number of tasks to run in parallel
    :param: maxRetries            The maximum times a task will be retried if it fails
    :param: logProvider           An optional logger, nothing will be logged if this is nil
    :param: serializationProvider An optional serializer, there will be no serialzation (persistence) if nil
    :param: completionBlock       The closure to call when a task finishes
    
    :returns: A new SYNQueue
    */
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
    
    /**
    Add a handler for a task type
    
    :param: taskType    The task type for the handler
    :param: taskHandler The handler for this particular task type, must be generic for the task type
    */
    public func addTaskHandler(taskType: String, taskHandler:SYNTaskCallback) {
        taskHandlers[taskType] = taskHandler
    }
    
    /**
    Deserializes tasks that were serialized (persisted)
    */
    public func loadSerializedTasks() {
        if let sp = serializationProvider {
            let tasks = sp.deserializeTasksInQueue(self)
            
            for task in tasks {
                task.setupDependencies(tasks)
                addDeserializedTask(task)
            }
        }
    }
    
    public func getTask(taskID: String) -> SYNQueueTask? {
        return tasks[taskID]
    }
    
    /**
    Adds a SYNQueueTask to the queue and serializes it
    
    :param: op A SYNQueueTask to execute on the queue
    */
    override public func addOperation(op: NSOperation) {
        if let task = op as? SYNQueueTask {
            if tasks[task.taskID] != nil {
                log(.Warning, "Attempted to add duplicate task \(task.taskID)")
                return
            }
            tasks[task.taskID] = task
            
            // Serialize this operation
            if let sp = serializationProvider, let queueName = task.queue.name {
                sp.serializeTask(task, queueName: queueName)
            }
        }
        
        op.completionBlock = { self.taskComplete(op) }
        super.addOperation(op)
    }
    
    func addDeserializedTask(task: SYNQueueTask) {
        if tasks[task.taskID] != nil {
            log(.Warning, "Attempted to add duplicate deserialized task \(task.taskID)")
            return
        }
        
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
            tasks.removeValueForKey(task.taskID)
            
            if let handler = completionBlock {
                handler(task)
            }
            
            // Remove this operation from serialization
            if let sp = serializationProvider {
                sp.removeTask(task.taskID, queue: task.queue)
            }
        }
    }
    
    func log(level: LogLevel, _ msg: String) {
        logProvider?.log(level, msg)
    }
}
