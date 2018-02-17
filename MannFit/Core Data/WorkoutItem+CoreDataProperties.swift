//
//  WorkoutItem+CoreDataProperties.swift
//  MannFit
//
//  Created by Luis Abraham on 2017-11-23.
//  Copyright © 2017 MannFit Labs. All rights reserved.
//
//

import Foundation
import CoreData

extension WorkoutItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutItem> {
        return NSFetchRequest<WorkoutItem>(entityName: "WorkoutItem")
    }

    @NSManaged public var absement: Float
    @NSManaged public var caloriesBurned: Int64
    @NSManaged public var workoutDuration: Int64
    @NSManaged public var date: Date
    @NSManaged public var game: String
 
    @objc var formattedDate: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            return dateFormatter.string(from: self.date)
        }
    }
}
