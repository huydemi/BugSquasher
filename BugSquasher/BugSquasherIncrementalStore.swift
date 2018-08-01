//
//  BugSquasherIncrementalStore.swift
//  BugSquasher
//
//  Created by Dang Quoc Huy on 8/1/18.
//  Copyright © 2018 poccaDot. All rights reserved.
//

import CoreData

class BugSquasherIncrementalStore : NSIncrementalStore {
  var bugsDB: [String] = []
  
  class var storeType: String {
    return String(describing: BugSquasherIncrementalStore.self)
  }
  
  override func loadMetadata() throws {
    
    let uuid = "Bugs Database"
    self.metadata = [NSStoreTypeKey: BugSquasherIncrementalStore.storeType,
                     NSStoreUUIDKey: uuid]
    
    if let dir = FileManager.default.urls(for: .documentDirectory,
                                          in: .userDomainMask).first {
      let path = dir.appendingPathComponent("bugs.txt")
      let loadedArray = NSMutableArray(contentsOf: path)
      
      if loadedArray != nil {
        bugsDB = loadedArray as! [String]
      }
    }
  }

  override func execute(_ request: NSPersistentStoreRequest,
                        with context: NSManagedObjectContext?) throws -> Any {
    return []
  }
  
}
