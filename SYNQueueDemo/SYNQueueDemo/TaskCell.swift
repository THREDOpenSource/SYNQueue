//
//  TaskCell.swift
//  SYNQueueDemo
//
//  Created by John Hurliman on 6/18/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import UIKit
import SYNQueue

class TaskCell : UICollectionViewCell {
    @IBOutlet weak var succeedButton: UIButton!
    @IBOutlet weak var failButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    weak var task: SYNQueueTask? = nil
    
    @IBAction func succeedTapped(sender: UIButton) {
        if let task = task {
            task.completed(nil)
        }
    }
    
    @IBAction func failTapped(sender: UIButton) {
        if let task = task {
            let err = Utils.error("User tapped Fail on task \(task.taskID)")
            task.completed(err)
        }
    }
}
