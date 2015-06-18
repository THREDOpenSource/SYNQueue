//
//  SYNQueueTask.swift
//  SYNQueue
//
//  Created by John Hurliman on 6/18/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import Foundation

public typealias SYNTaskCallback = (NSError?, SYNQueueTask) -> Void
public typealias JSONDictionary = [String: AnyObject?]

@objc
public class SYNQueueTask : NSOperation {
    public let queueName: String
    public let data: [String: AnyObject]
    let dependencyStrs: [String]
    let created: NSDate
    var started: NSDate?
    var retries: Int
    
    public override var asynchronous:Bool { return true }
    public override var executing:Bool = false
    public override var finished:Bool = false
    
    public init(taskID: String, queueName: String, dependencyStrs: [String],
        queuePriority: NSOperationQueuePriority, qualityOfService: NSQualityOfService,
        data: [String: AnyObject], created: NSDate, started: NSDate?, retries: Int)
    {
        self.queueName = queueName
        self.dependencyStrs = dependencyStrs
        self.data = data
        self.created = created
        self.started = started
        self.retries = retries
        
        super.init()
        
        self.name = taskID
        self.queuePriority = queuePriority
        self.qualityOfService = qualityOfService
    }
    
    public convenience init?(dictionary: JSONDictionary) {
        if  let taskID = dictionary["taskID"] as? String,
            let queueName = dictionary["queueName"] as? String,
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
            
            self.init(taskID: taskID, queueName: queueName, dependencyStrs: dependencyStrs,
                queuePriority: queuePriority, qualityOfService: qualityOfService,
                data: data, created: created, started: started, retries: retries)
        } else {
            self.init(taskID: "", queueName: "", dependencyStrs: [],
                queuePriority: .VeryLow, qualityOfService: .Default,
                data: [String: AnyObject](), created: NSDate(), started: NSDate(), retries: 0)
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
        dict["taskID"] = self.name
        dict["queueName"] = self.queueName
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
        executing = true
        finished = false
        
    }
}
