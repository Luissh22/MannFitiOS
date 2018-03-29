//
//  Constants.swift
//  MannFit
//
//  Created by Daniel Till on 12/29/17.
//  Copyright © 2017 MannFit Labs. All rights reserved.
//
import UIKit

struct UserDefaultsKeys {
    static let settingsMotionSensitivityKey = "settingsMotionSensitivityKey"
    static let settingsMusicKey = "settingsMusicKey"
    static let settingsVolumeKey = "settingsVolumeKey"
    static let settingsPongSpeedKey = "settingsPongSpeedKey"
    static let filteredWorkoutKey = "filteredWorkoutKey"
}

struct SettingsValues {
    static let sensitivityDefault: Float = 0.5
    static let pongSpeedDefault: Float = 1.0
    static let maxInputChars: Int = 3
    static let absementSampleRate: Double = 60.0
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
    
    // Pong Game
    static let pongName = "Pong"
    static let pongImageName = "Pong"
    static let pongIdentifier = "pongIdentifier"
    static let pongDefaultTime = 20.0
    
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
    static let CalendarCell = "CalendarCell"
    static let FilterWorkoutCell = "FilterWorkoutCell"
    static let SegueFilterWorkouts = "filterWorkoutsSegue"
}

struct Colours {
    static let workoutBlue = #colorLiteral(red: 0.2784313725, green: 0.5882352941, blue: 1, alpha: 1)
}
