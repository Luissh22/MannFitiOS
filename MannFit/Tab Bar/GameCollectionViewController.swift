//
//  GameCollectionViewController.swift
//  MannFit
//
//  Created by Luis Abraham on 2017-11-06.
//  Copyright © 2017 MannFit Labs. All rights reserved.
//

import UIKit
import CoreData

class GameCollectionViewController: UICollectionViewController {

    // MARK: - Properties
    private var statusBarShouldBeHidden = false
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private let itemsPerRow: CGFloat = 2
    private let gameDataSource = GameDataSource()
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundView?.backgroundColor = .black
        self.collectionView?.backgroundColor = .black
        self.collectionView?.dataSource = self.gameDataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show the status bar
        statusBarShouldBeHidden = false
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let storyboard = self.storyboard else { return }
        
        let game = self.gameDataSource.object(at: indexPath)
        
        // If this view controller does not comply with the CoreData contract, exit because we cannot save data.
        guard let viewController = storyboard.instantiateViewController(withIdentifier: game.storyboardIdentifier) as? CoreDataCompliant else { return }
        viewController.managedObjectContext = self.managedObjectContext
        
        // Hide the status bar
        statusBarShouldBeHidden = true
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        // We know this is a GameViewController, so cast back
        let gameViewController = viewController as! UIViewController
        self.present(gameViewController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GameCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - padding
        let itemWidth = availableWidth / itemsPerRow
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

// MARK: - CoreDataCompliant
extension GameCollectionViewController: CoreDataCompliant { }
