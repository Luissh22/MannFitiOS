//
//  FilterWorkoutTableViewController.swift
//  MannFit
//
//  Created by Luis Abraham on 2018-03-24.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import UIKit

protocol FilterWorkoutsDelegate {
    func didSelect(_ workout: Workout)
}

class FilterWorkoutTableViewController: UITableViewController {
    
    var delegate: FilterWorkoutsDelegate?
    var storedWorkoutFilter: Workout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Workout.workouts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.FilterWorkoutCell, for: indexPath) as! FilterWorkoutTableViewCell
        let workout = Workout.workouts[indexPath.row]
        
        cell.workoutNameLabel.text = workout.rawValue
        
        if let storedWorkout = storedWorkoutFilter {
            cell.accessoryType = (storedWorkout == workout) ? .checkmark : .none
        } else if workout == .All {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = (cell.accessoryType == .none) ? .checkmark : .none
        
        let workout = Workout.workouts[indexPath.row]
        storedWorkoutFilter = workout
        
        tableView.reloadData()
        
        delegate?.didSelect(workout)
    }
    
}
