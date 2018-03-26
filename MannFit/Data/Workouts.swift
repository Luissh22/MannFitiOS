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

extension Workout {
    var highScoreKey: String? {
        switch self {
        case .All:
            return nil
        case .PacMan:
            return UserDefaultsKeys.pacmanHighScoreKey
        case .Circle:
            return UserDefaultsKeys.circleHighScoreKey
        case .Water:
            return UserDefaultsKeys.waterHighScoreKey
        case .Pong:
            return UserDefaultsKeys.pongHighScoreKey
        }
    }
}
