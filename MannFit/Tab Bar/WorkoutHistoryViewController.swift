//
//  WorkoutHistoryViewController.swift
//  MannFit
//
//  Created by Luis Abraham on 2017-12-28.
//  Copyright © 2017 MannFit Labs. All rights reserved.
//

import UIKit
import CoreData

class WorkoutHistoryViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    
    private let userDefaults: UserDefaults = UserDefaults.standard
    
    private lazy var fetchedResultsController: NSFetchedResultsController<WorkoutItem> = {
        let fetchRequest: NSFetchRequest<WorkoutItem> = WorkoutItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest,
                                          managedObjectContext: self.managedObjectContext,
                                          sectionNameKeyPath: #keyPath(WorkoutItem.formattedDate),
                                          cacheName: nil)
    }()
    
    private func setupNavigationBar() {
        self.title = "Workouts"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    fileprivate func filterWorkouts() {
        if let storedFilter = getStoredWorkoutFilter() {
            self.fetchedResultsController.fetchRequest.predicate = createPredicate(from: storedFilter)
        }
    }
    
    fileprivate func createPredicate(from workout: Workout) -> NSPredicate? {
        return (workout == .All) ? nil : NSPredicate(format: "game = %@", workout.rawValue)
    }
    
    fileprivate func getStoredWorkoutFilter() -> Workout? {
        guard let storedString = userDefaults.value(forKey: UserDefaultsKeys.filteredWorkoutKey) as? String else {
            return nil
        }
        
        return Workout(rawValue: storedString)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.navigationController?.delegate = self
        self.fetchedResultsController.delegate = self
        self.setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            filterWorkouts()
            try self.fetchedResultsController.performFetch()
        } catch {
            // TODO: Handle the error cleanly
            print(error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = self.fetchedResultsController.sections else {
            return 0
        }
        
        return sections.count
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Grab item from fetched results controller and inform MOC to delete
            let item = self.fetchedResultsController.object(at: indexPath)
            self.managedObjectContext.delete(item)
            self.managedObjectContext.saveChanges()
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionInfo = self.fetchedResultsController.sections?[section] else {
            fatalError("Unexpected section")
        }
        
        let blurView = self.createBlurView()
        let headerLabel = self.createHeaderLabel(with: blurView.frame)
        
        headerLabel.text = sectionInfo.name

        blurView.contentView.addSubview(headerLabel)

        return blurView
    }
    
    private func createBlurView() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRect(x: 15, y: -15, width: tableView.bounds.size.width, height: 60)
        blurView.autoresizingMask = .flexibleWidth
        
        return blurView
    }
    
    private func createHeaderLabel(with frame: CGRect) -> UILabel {
        let headerLabel = UILabel()
        headerLabel.frame = frame
        headerLabel.autoresizingMask = .flexibleWidth
        headerLabel.textColor = UIColor.white
        headerLabel.font = UIFont.systemFont(ofSize: 20)
        
        return headerLabel
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = self.fetchedResultsController.sections?[section] else {
            fatalError("Unexpected section")
        }
        
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.WorkoutCell, for: indexPath) as! WorkoutTableViewCell
        
        let item = self.fetchedResultsController.object(at: indexPath)
        
        cell.configureCell(workoutItem: item)
        
        return cell
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.SegueWorkoutHistoryToDetail {
            guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
            
            let item = self.fetchedResultsController.object(at: indexPath)
            let destinationVC = segue.destination as! WorkoutDetailViewController
            
            destinationVC.workoutName = item.game
            destinationVC.absementScore = item.formattedAbsementScore
            destinationVC.date = item.date
            destinationVC.duration = item.workoutDuration
            destinationVC.workoutGameImage = item.gameImage
            destinationVC.highScore = getHighScore(for: item.game) ?? item.formattedAbsementScore
            destinationVC.improvement = calculateWorkoutImprovement(for: item) ?? "0.0%"

        } else if segue.identifier == Storyboard.SegueFilterWorkouts {
            let destinationVC = segue.destination as! FilterWorkoutTableViewController
            destinationVC.delegate = self
            destinationVC.storedWorkoutFilter = getStoredWorkoutFilter()
        }
    }
    
    private func getHighScore(for game: String) -> String? {
        guard let items = fetchedResultsController.fetchedObjects else { return nil }
        
        let filteredWorkouts = items.filter { $0.game == game }
        
        let highScore = filteredWorkouts.min { $0.absement < $1.absement }
        
        guard let _highScore = highScore else { return nil }
        
        return String(format: "%.2f", _highScore.absement)
    }
    
    private func calculateWorkoutImprovement(for workout: WorkoutItem) -> String? {
        guard let items = fetchedResultsController.fetchedObjects else { return nil }
        
        let filteredWorkouts = items.filter { $0.game == workout.game }
        
        guard filteredWorkouts.count > 1 else { return nil }
        
        guard let index = filteredWorkouts.index(of: workout),
            filteredWorkouts.count > index + 1 else { return nil }
        
        let previousWorkout = filteredWorkouts[index + 1]
        
        var workoutImprovement = -(workout.absement - previousWorkout.absement) / previousWorkout.absement
        
        // Special case, with floats, 0s have signs as well
        if workoutImprovement == -0.0 {
            workoutImprovement *= -1
        }
        
        return String(format: "%.1f%%", workoutImprovement * 100)
    }
}

// MARK: - CoreDataCompliant
extension WorkoutHistoryViewController: CoreDataCompliant {
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension WorkoutHistoryViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // When a change occurs in the MOC, update the table view
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .delete {
            guard let indexPath = indexPath else { return }
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if type == .delete {
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        }
    }
}

// MARK: - FilterWorkoutsDelegate
extension WorkoutHistoryViewController: FilterWorkoutsDelegate {
    func didSelect(_ workout: Workout) {
        userDefaults.set(workout.rawValue, forKey: UserDefaultsKeys.filteredWorkoutKey)
        self.fetchedResultsController.fetchRequest.predicate = createPredicate(from: workout)
        navigationController?.popViewController(animated: true)
    }
}

extension WorkoutHistoryViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.viewWillAppear(true)
    }
}
