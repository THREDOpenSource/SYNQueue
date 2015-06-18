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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
