//
//  GameViewController.swift
//  MannFit
//
//  Created by Luis Abraham on 2017-10-30.
//  Copyright © 2017 MannFit Labs. All rights reserved.
//

import UIKit
import SpriteKit
import CoreData

class PacManGameViewController: UIViewController, CoreDataCompliant {
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        let scene = PacManGameScene(size: view.bounds.size)
        scene.gameOverDelegate = self
        UIApplication.shared.isIdleTimerDisabled = true
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension PacManGameViewController: GameOverDelegate {
    func sendGameData(game: String, duration: Int, absement: Float) {
        self.prepareItem(game: game, duration: duration, absement: absement)
        self.managedObjectContext.saveChanges()
    }
    
    private func prepareItem(game: String, duration: Int, absement: Float) {
        let workoutItem = NSEntityDescription.insertNewObject(forEntityName: "WorkoutItem", into: self.managedObjectContext) as! WorkoutItem
        workoutItem.game = game
        workoutItem.workoutDuration = Int64(duration)
        workoutItem.absement = absement
        
        let date = Date()
        workoutItem.date = date
        workoutItem.formattedDate = self.format(date)
        
        workoutItem.caloriesBurned = 0 // calculate this after
    }
    
    private func format(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    func exitGame() {
        self.dismiss(animated: true, completion: nil)
    }
}
