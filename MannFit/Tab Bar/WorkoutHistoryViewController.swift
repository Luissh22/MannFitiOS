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
    
    private lazy var fetchedResultsController: NSFetchedResultsController<WorkoutItem> = {
        let fetchRequest: NSFetchRequest<WorkoutItem> = WorkoutItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest,
                                          managedObjectContext: self.managedObjectContext,
                                          sectionNameKeyPath: #keyPath(WorkoutItem.formattedDate),
                                          cacheName: nil)
    }()
    
    private lazy var headerBlurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRect(x: 15, y: -15, width: tableView.bounds.size.width, height: 55)
        blurView.autoresizingMask = .flexibleWidth
        
        return blurView
    }()
    
    private lazy var headerLabel: UILabel = {
        let headerLabel = UILabel()
        headerLabel.frame = headerBlurView.frame
        headerLabel.autoresizingMask = .flexibleWidth
        headerLabel.textColor = UIColor.white
        headerLabel.font = UIFont.systemFont(ofSize: 20)
        
        return headerLabel
    }()

    private func setupNavigationBar() {
        self.title = "Workouts"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.fetchedResultsController.delegate = self
        self.setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
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
        
        headerLabel.text = sectionInfo.name
   
        headerBlurView.contentView.addSubview(headerLabel)
        
        return headerBlurView
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
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if type == .delete {
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        }
    }
}
