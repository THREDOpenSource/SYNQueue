//
//  ViewController.swift
//  SYNQueueDemo
//
//  Created by John Hurliman on 6/18/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import UIKit
import SYNQueue

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let queue = SYNQueue(queueName: "myQueue", maxConcurrency: 2, maxRetries: 5, serializationProvider: NSUserDefaultsSerializer())
    var tasks = [SYNQueueTask]()
    var nextTaskID = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        queue.addTaskHandler("cellTask", taskHandler: taskHandler)
    }
    
    override func viewDidLayoutSubviews() {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSizeMake(collectionView.bounds.size.width, 50)
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func taskHandler(task: SYNQueueTask) {
        // Do the task
        
        // Complete the task
        task.completed(NSError(domain: "Queue", code: -1, userInfo: nil))
    }
    
    // MARK: - UICollectionView Delegates
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let task = tasks[indexPath.item]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TaskCell", forIndexPath: indexPath) as! TaskCell

        cell.taskID = tasks[indexPath.item].name
        cell.backgroundColor = task.executing ? UIColor.blueColor() : UIColor.grayColor()
        
        return cell
    }
    
    // MARK: - IBActions
    
    @IBAction func addTapped(sender: UIButton) {
        let task = SYNQueueTask(queue: queue, taskID: String(nextTaskID++), taskType: "cellTask",
            dependencyStrs: [], data: [:])
        tasks.append(task)
        collectionView.reloadData()
        queue.addOperation(task)
    }
    
    @IBAction func removeTapped(sender: UIButton) {
        // Find the first task in the list
        if let task = tasks.first {
            task.cancel()
            tasks.removeAtIndex(0)
            collectionView.reloadData()
        }
    }
    
    
}
