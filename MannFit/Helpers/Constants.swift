//
//  Constants.swift
//  MannFit
//
//  Created by Daniel Till on 12/29/17.
//  Copyright © 2017 MannFit Labs. All rights reserved.
//

struct UserDefaultsKeys {
    static let settingsMotionSensitivityKey = "settingsMotionSensitivityKey"
    static let settingsMusicKey = "settingsMusicKey"
    static let settingsVolumeKey = "settingsVolumeKey"
}

struct SettingsValues {
    static let sensitivityDefault: Float = 0.5
}

struct GameData {
    
    // Pacman Game
    static let pacmanName = "Pacman Path"
    static let pacmanImageName = "pacmanPlayerOpen"
    static let pacmanIdentifier = "pacmanIdentifier"
    static let pacmanDefaultTime = 20.0
    
    // Circle Game
    static let circleName = "Circle Balance"
    static let circleImageName = "CircleBalanceImage"
    static let circleIdentifier = "circleIdentifier"
    static let circleDefaultTime = 20.0
    
    // Water Tap Game
    static let waterTapName = "Water Tap"
    static let waterTapImageName = "Water Tap"
    static let waterTapIdentifier = "waterTapIdentifier"
    static let waterTapDefaultTime = 20.0
    
    // Test Game
    static let testingName = "Testing"
    static let testingImageName = "testingGameImage"
    static let testingIdentifier = "testingIdentifier"
}

struct CoreData {
    static let WorkoutItem = "WorkoutItem"
}

struct Storyboard {
    static let WorkoutCell = "workoutCell"
    static let SegueWorkoutHistoryToDetail = "workoutHistoryToDetail"
}
