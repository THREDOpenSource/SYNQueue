//
//  NSUserDefaultsSerializer.swift
//  SYNQueueDemo
//
//  Created by John Hurliman on 6/18/15.
//  Copyright (c) 2015 Syntertainment. All rights reserved.
//

import Foundation
import SYNQueue

class NSUserDefaultsSerializer : SYNQueueSerializationProvider {
    // MARK: - SYNQueueSerializationProvider Methods
    
    func serializeTask(task: SYNQueueTask) {
        
    }
    
    func deserializeTasksWithQueue(queue: SYNQueue) -> Array<SYNQueueTask> {
        return []
    }
    
    func removeTask(task: SYNQueueTask) {
        
    }
}
