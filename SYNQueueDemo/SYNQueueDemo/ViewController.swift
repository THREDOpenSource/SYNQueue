//
//  ViewController.swift
//  SYNQueueDemo
//
//  Created by John Hurliman on 6/18/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import UIKit
import SYNQueue

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let queueName = ""
//        let queue = SYNQueue(queueName: queueName, maxConcurrency: 2) {
//            (err: NSError?, task: SYNQueueTask) in
//            if let err = err {
//                print("Queue error: \(err)")
//                return
//            }
//            
//            let taskType = task.data["type"] {
//                switch taskType {
//                    
//                }
//            }
//            task.completed(nil)
//            
//            print("Dequeued \(task.name) on queue \(queueName)")
//        }
        
        let queue = SYNQueue(queueName: queueName, maxConcurrency: 2)
        
        queue.addTaskHandler("image") {
            (task) in
            
            // Do the task
            
            // Complete the task
            task.completed(nil)
            
        }
        
        let task = SYNQueueTask(queue: queue, taskID: "234", taskType: "image", dependencyStrs: ["1"], queuePriority: .Normal, qualityOfService: .Default, data: [:], created: NSDate(), started: nil, retries: 0)
        
        queue.addOperation(task)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
