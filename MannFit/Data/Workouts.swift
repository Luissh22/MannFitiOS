//
//  Workouts.swift
//  MannFit
//
//  Created by Luis Abraham on 2018-03-24.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import Foundation

enum Workout: String {
    case All = "All Workouts"
    case PacMan
    case Circle = "Circle Balance"
    case Water = "Water Tap"
    case Pong
    
    static let workouts = [All, PacMan, Circle, Water, Pong]
}
