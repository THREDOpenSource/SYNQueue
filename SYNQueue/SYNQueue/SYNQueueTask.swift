//
//  SYNQueueTask.swift
//  SYNQueue
//
//  Created by John Hurliman on 6/18/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import Foundation

public typealias SYNTaskCallback = (SYNQueueTask) -> Void
public typealias JSONDictionary = [String: AnyObject?]

@objc
public class SYNQueueTask : NSOperation {
    static let MIN_RETRY_DELAY = 0.2
    static let MAX_RETRY_DELAY = 60.0
    
    public weak var queue: SYNQueue?
    public let taskID: String
    public let taskType: String
    public let data: [String: AnyObject]
    public let created: NSDate
    
    let dependencyStrs: [String]
    var started: NSDate?
    var retries: Int
    var _executing: Bool = false
    var _finished: Bool = false
    
    public override var name:String? { get { return taskID } set { } }
    public override var asynchronous:Bool { return true }
    
    public override var executing: Bool {
        get { return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    public override var finished: Bool {
        get { return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    public init(queue:SYNQueue, taskID: String, taskType: String,
        dependencyStrs: [String], data: [String: AnyObject],
        created: NSDate = NSDate(), started: NSDate? = nil, retries: Int = 0,
        queuePriority: NSOperationQueuePriority = .Normal,
        qualityOfService: NSQualityOfService = .Default)
    {
        self.queue = queue
        self.taskID = taskID
        self.taskType = taskType
        self.dependencyStrs = dependencyStrs
        self.data = data
        self.created = created
        self.started = started
        self.retries = retries
        
        super.init()
        
        self.queuePriority = queuePriority
        self.qualityOfService = qualityOfService
    }
    
    public convenience init?(dictionary: JSONDictionary, queue:SYNQueue) {
        if  let taskID = dictionary["taskID"] as? String,
            let taskType = dictionary["taskType"] as? String,
            let dependencyStrs = dictionary["dependencies"] as? [String],
            let queuePriority = dictionary["queuePriority"] as? NSOperationQueuePriority,
            let qualityOfService = dictionary["qualityOfService"] as? NSQualityOfService,
            let data = dictionary["data"] as? [String: AnyObject],
            let createdStr = dictionary["created"] as? String,
            let startedStr = dictionary["started"] as? String?,
            let retries = dictionary["retries"] as? Int
        {
            let created = NSDate(dateString: createdStr) ?? NSDate()
            let started = (startedStr != nil) ? NSDate(dateString: startedStr!) : nil
            
            self.init(queue: queue, taskID: taskID, taskType: taskType,
                dependencyStrs: dependencyStrs, data: data, created: created,
                started: started, retries: retries, queuePriority: queuePriority,
                qualityOfService: qualityOfService)
        } else {
            self.init(queue: queue, taskID: "", taskType: "", dependencyStrs: [], data: [:])
        }
        
        return nil
    }
    
    public func setupDependencies(allTasks: [SYNQueueTask]) {
        dependencyStrs.map {
            (taskID: String) -> Void in
            
            let found = allTasks.filter({ taskID == $0.name })
            if let task = found.first {
                self.addDependency(task)
            } else {
                let name = self.name ?? "(unknown)"
                print("Discarding missing dependency \(taskID) from \(name)")
            }
        }
    }
    
    public func toDictionary() -> [String: AnyObject?] {
        var dict = [String: AnyObject?]()
        dict["taskID"] = self.taskID
        dict["taskType"] = self.taskType
        dict["dependencies"] = self.dependencyStrs
        dict["queuePriority"] = self.queuePriority.rawValue
        dict["qualityOfService"] = self.qualityOfService.rawValue
        dict["data"] = self.data
        dict["created"] = self.created.toISOString()
        dict["started"] = (self.started != nil) ? self.started!.toISOString() : nil
        dict["retries"] = self.retries
        
        return dict
    }
    
    override public func start() {
        super.start()
        
        executing = true
        run()
    }
    
    func run() {
        queue?.runTask(self)
    }
    
    public func completed(error: NSError?) {
        if let error = error {
            println("Task \(taskID) failed with error: \(error)")
            
            // Check if we've exceeded the max allowed retries
            if ++retries >= queue?.maxRetries {
                println("Max retries exceeded for task \(taskID)")
                markFinished()
                return
            }
            
            // Wait a bit (exponential backoff) and retry this task
            let exp = Double(min(queue?.maxRetries ?? 0, retries))
            let seconds:NSTimeInterval = min(SYNQueueTask.MAX_RETRY_DELAY, SYNQueueTask.MIN_RETRY_DELAY * pow(2.0, exp - 1))
            
            println("Waiting \(seconds) seconds to retry task \(taskID)")
            Utils.runInBackgroundAfter(seconds) { self.run() }
        } else {
            println("Task \(taskID) completed")
            markFinished()
        }
    }
    
    func markFinished() {
        finished = true
        executing = false
    }
}
