//
//  SettingsTableViewController.swift
//  MannFit
//
//  Created by Daniel Till on 12/27/17.
//  Copyright © 2017 MannFit Labs. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var settingsTableView: UITableView!
    @IBOutlet weak var sensitivitySlider: UISlider!
    @IBOutlet weak var musicSwitch: UISwitch!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var pongSpeedSlider: UISlider!
    
    private let userDefaults: UserDefaults = UserDefaults.standard
    private var sensitivity: Float = 0.5
    private var music: Bool = true
    private var volume: Float = 0.5
    private var pongSpeed: Float = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sensitivity = userDefaults.float(forKey: UserDefaultsKeys.settingsMotionSensitivityKey)
        self.music = userDefaults.bool(forKey: UserDefaultsKeys.settingsMusicKey)
        self.volume = userDefaults.float(forKey: UserDefaultsKeys.settingsVolumeKey)
        self.pongSpeed = userDefaults.float(forKey: UserDefaultsKeys.settingsPongSpeedKey)
        
        self.sensitivitySlider.value = self.sensitivity
        self.musicSwitch.isOn = self.music
        self.volumeSlider.value = self.volume
        self.volumeSlider.isEnabled = musicSwitch.isOn
        self.volumeSlider.value = self.pongSpeed
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    @IBAction func sensitivitySlider(_ sender: UISlider) {
        let value = sender.value
        self.sensitivitySlider.value = value
        userDefaults.set(value, forKey: UserDefaultsKeys.settingsMotionSensitivityKey)
    }
    
    @IBAction func musicSwitch(_ sender: UISwitch) {
        let isOn = sender.isOn
        self.volumeSlider.isEnabled = isOn
        userDefaults.set(isOn, forKey: UserDefaultsKeys.settingsMusicKey)
    }
    
    @IBAction func volumeSlider(_ sender: UISlider) {
        let value = sender.value
        self.volumeSlider.value = value
        userDefaults.set(value, forKey: UserDefaultsKeys.settingsVolumeKey)
    }
    
    @IBAction func pongSpeedSlider(_ sender: UISlider) {
        let value = sender.value
        self.pongSpeedSlider.value = value
        userDefaults.set(value, forKey: UserDefaultsKeys.settingsPongSpeedKey)
    }
}
