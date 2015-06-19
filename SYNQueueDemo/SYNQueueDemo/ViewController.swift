//
//  ViewController.swift
//  SYNQueueDemo
//
//  Created by John Hurliman on 6/18/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import UIKit
import SYNQueue

class ViewController: UIViewController, SYNQueueSerializationProvider {
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let queueName = "myQueue"
        let queue = SYNQueue(queueName: queueName, maxConcurrency: 2, maxRetries: 10)
        
        queue.addTaskHandler("cellTask") { (task) in
            // Do the task
            
            // Complete the task
            task.completed(NSError(domain: "Queue", code: -1, userInfo: nil))
        }
        
        let task = SYNQueueTask(queue: queue, taskID: "a", taskType: "cellTask",
            dependencyStrs: [], data: [:])
        
        queue.addOperation(task)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTapped(sender: UIButton) {
        
    }
    
    @IBAction func removeTapped(sender: UIButton) {
        
    }
    
    // MARK: SYNQueueSerializationProvider functions
    
    func serializeTask(task: SYNQueueTask) {
        
    }
    
    func deserializeTasksWithQueue(queue: SYNQueue) -> Array<SYNQueueTask> {
        
    }
    
    func removeTask(task: SYNQueueTask) {
        
    }
}
