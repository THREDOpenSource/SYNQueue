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
    
    var queue: SYNQueue?
    var nextTaskID = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        queue = SYNQueue(queueName: "myQueue", maxConcurrency: 2, maxRetries: 3,
            serializationProvider: NSUserDefaultsSerializer(), completionBlock: taskComplete)
        queue!.addTaskHandler("cellTask", taskHandler: taskHandler)
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
        // NOTE: Tasks are not actually handled here like usual since task
        // completion in this example is based on user interaction
        Utils.print("Running task \(task.taskID)")
        
        // Set task completion after 5 seconds
        Utils.runOnMainThreadAfterDelay(5, callback: { () -> () in
            task.completed(nil)
        })
        
        // Redraw this task to show it as active
        if  let queue = queue,
            let index = Utils.findIndex(queue.operations as! [NSOperation], valueToFind: task)
        {
            Utils.runOnMainThread {
                let path = NSIndexPath(forItem: index, inSection: 0)
                self.collectionView.reloadData()
            }
        }
    }
    
    func taskComplete(task: SYNQueueTask) {
        Utils.print("taskComplete(\(task.taskID))")
        Utils.runOnMainThread { self.collectionView.reloadData() }
    }
    
    // MARK: - UICollectionView Delegates
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection
        section: Int) -> Int
    {
        return queue!.operationCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath
        indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            "TaskCell", forIndexPath: indexPath) as! TaskCell
        cell.backgroundColor = UIColor.redColor()
        
        if let task = queue!.operations[indexPath.item] as? SYNQueueTask {
            cell.task = task
            cell.nameLabel.text = "task \(task.taskID)"
            cell.succeedButton.enabled = false // disable because completion is automatic with delay
            if task.executing {
                cell.backgroundColor = UIColor.blueColor()
                cell.failButton.enabled = true
                //cell.succeedButton.enabled = true
            } else {
                cell.backgroundColor = UIColor.grayColor()
                //cell.succeedButton.enabled = false
                cell.failButton.enabled = false
            }
        }
        
        return cell
    }
    
    // MARK: - IBActions
    
    @IBAction func addTapped(sender: UIButton) {
        let task = SYNQueueTask(queue: queue!, taskID: String(nextTaskID++),
            taskType: "cellTask", dependencyStrs: [], data: [:])
        collectionView.reloadData()
        queue!.addOperation(task)
    }
    
    @IBAction func removeTapped(sender: UIButton) {
        // Find the first task in the list
        if let task = queue!.operations.first as? SYNQueueTask {
            Utils.print("Removing task \(task.taskID)")
            task.cancel()
            collectionView.reloadData()
        }
    }
}
