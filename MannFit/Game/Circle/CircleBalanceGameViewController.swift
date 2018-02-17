//
//  CircleBalanceGameViewController.swift
//  MannFit
//
//  Created by Daniel Till on 2/1/18.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import UIKit
import SpriteKit
import CoreData

class CircleBalanceGameViewController: UIViewController, CoreDataCompliant, GameTimeCompliant {
    
    var managedObjectContext: NSManagedObjectContext!
    var inputTime: TimeInterval = GameData.circleDefaultTime
    private var scene: CircleBalanceGameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        self.scene = CircleBalanceGameScene(size: view.bounds.size)
        scene?.gameOverDelegate = self
        scene?.inputTime = inputTime
        UIApplication.shared.isIdleTimerDisabled = true
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene?.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func exit() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CircleBalanceGameViewController: GameOverPromptDelegate {
    func restartGame() {
        // first dismiss popup
        self.dismiss(animated: true, completion: nil)
        self.scene?.restartGame()
    }
    
    func exitGame() {
        // first dismiss popup
        self.dismiss(animated: true, completion: nil)
        self.scene?.engine?.stop()
        self.exit()
    }
}

extension CircleBalanceGameViewController: GameOverDelegate {
    
    func presentPrompt() {
        let view = GameOverPromptView()
        view.delegate = self
        let popup = PopUpViewController(view: view, dismissible: false)
        self.present(popup, animated: true, completion: nil)
    }
    
    func sendGameData(game: String, duration: Int, absement: Float) {
        self.prepareItem(game: game, duration: duration, absement: absement)
        self.managedObjectContext.saveChanges()
    }
    
    private func prepareItem(game: String, duration: Int, absement: Float) {
        let workoutItem = NSEntityDescription.insertNewObject(forEntityName: "WorkoutItem", into: self.managedObjectContext) as! WorkoutItem
        workoutItem.game = game
        workoutItem.workoutDuration = Int64(duration)
        workoutItem.absement = absement
        workoutItem.date = Date()
        workoutItem.caloriesBurned = 0 // calculate this after
    }
}
