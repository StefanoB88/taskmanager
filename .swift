//
//  TaskEntity+CoreDataProperties.swift
//  TaskManager
//
//  Created by Stefano on 11.03.25.
//
//

import Foundation
import CoreData


extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var title: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var priority: String?
    @NSManaged public var dueDate: NSDecimalNumber?
    @NSManaged public var isCompleted: Bool

}

extension TaskEntity : Identifiable {

}
