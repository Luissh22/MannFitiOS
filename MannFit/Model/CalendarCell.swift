//
//  CalendarCell.swift
//  MannFit
//
//  Created by Luis Abraham on 2018-02-20.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCell: JTAppleCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedIndicator: UIView!
    var isWorkoutDate: Bool = false {
        didSet {
            dateLabel.textColor = isWorkoutDate ? Colours.workoutBlue : dateLabel.textColor
        }
    }
}
