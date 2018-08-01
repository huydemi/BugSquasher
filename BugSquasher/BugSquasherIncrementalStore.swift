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
  var currentBugID = 0
  
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
    
    if request.requestType == .fetchRequestType {
      let fetchRequest = request as! NSFetchRequest<NSManagedObject>
      
      if fetchRequest.resultType == NSFetchRequestResultType() {
        var fetchedObjects = [NSManagedObject]()
        
        if bugsDB.count > 0 {
          for currentBugID in 1...bugsDB.count {
            let objectID = self.newObjectID(for: fetchRequest.entity!,
                                            referenceObject: currentBugID)
            let curObject = context?.object(with: objectID)
            fetchedObjects.append(curObject!)
          }
        }
        return fetchedObjects
      }
      
      return []
    } else if request.requestType == .saveRequestType {
      let saveRequest = request as! NSSaveChangesRequest
      
      if saveRequest.insertedObjects != nil {
        for bug in saveRequest.insertedObjects! {
          bugsDB.append((bug as! Bug).title)
        }
      }
      
      self.saveBugs()
      
      return [AnyObject]()
    }
    
    return []
  }
  
  override func obtainPermanentIDs(for array: [NSManagedObject]) throws -> [NSManagedObjectID] {
    var objectIDs = [NSManagedObjectID]()
    for managedObject in array {
      let objectID = self.newObjectID(for: managedObject.entity,
                                      referenceObject: managedObject.value(forKey: "bugID")!)
      objectIDs.append(objectID)
    }
    
    return objectIDs
  }
  
  override func newValuesForObject(with objectID: NSManagedObjectID,
                                   with context: NSManagedObjectContext) throws -> NSIncrementalStoreNode {
    
    let values = ["title": bugsDB[currentBugID],"bugID": currentBugID] as [String : Any]
    let node = NSIncrementalStoreNode(objectID: objectID, withValues: values,
                                      version: UInt64(0.1))
    
    currentBugID += 1
    
    return node
  }
  
  func saveBugs() {
    if let dir = FileManager.default.urls(for: .documentDirectory,
                                          in: .userDomainMask).first {
      let path = dir.appendingPathComponent("bugs.txt")
      (bugsDB as NSArray).write(to: path, atomically: true)
    }
  }
  
}
