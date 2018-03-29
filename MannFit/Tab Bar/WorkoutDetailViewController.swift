//
//  WorkoutDetailViewController.swift
//  MannFit
//
//  Created by Luis Abraham on 2018-02-23.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import UIKit

class WorkoutDetailViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var workoutImageView: UIImageView!
    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var absementScoreLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var workoutTimeLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var improvementLabel: UILabel!
    @IBOutlet weak var absementGraphView: AbsementGraphView!
    
    var workoutName: String!
    var absementScore: String!
    var date: Date!
    var duration: Int64!
    var workoutGameImage: UIImage?
    var highScore: String!
    var improvement: String!
    var absementGraphPoints: [Float]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workoutImageView.image = workoutGameImage
        workoutNameLabel.text = workoutName
        absementScoreLabel.text = absementScore
        highScoreLabel.text = highScore
        improvementLabel.text = improvement
        durationLabel.text = String(format: "%ds", duration)
        absementGraphView.workoutDuration = Array(0...(absementGraphPoints.count - 1))
        absementGraphView.absementGraphPoints = absementGraphPoints
        absementGraphView.setGraphData()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d"
        self.title = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "h:mm a"
        workoutTimeLabel.text = dateFormatter.string(from: date)
    }

}
