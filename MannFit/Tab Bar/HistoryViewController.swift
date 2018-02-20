//
//  HistoryViewController.swift
//  MannFit
//
//  Created by Luis Abraham on 2018-02-20.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import UIKit
import JTAppleCalendar

class HistoryViewController: UIViewController {
    let dateFormatter = DateFormatter()

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup label
        calendarView.scrollToDate(Date())
        calendarView.visibleDates { [weak self] visibleDates in
            self?.setupCalendarView(from: visibleDates)
        }
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CalendarCell else { return }

        validCell.dateLabel.textColor = (cellState.dateBelongsTo == .thisMonth) ? UIColor.white : UIColor.gray
    }
    
    func setupCalendarView(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date

        dateFormatter.dateFormat = "yyyy"
        yearLabel.text = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "MMMM"
        monthLabel.text = dateFormatter.string(from: date)
    }
}

extension HistoryViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {

    }

    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell

        cell.dateLabel.text = cellState.text
        handleCellTextColor(view: cell, cellState: cellState)

        return cell
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarView(from: visibleDates)
    }
}

extension HistoryViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        let startDate = dateFormatter.date(from: "2018 01 01")!
        let endDate = dateFormatter.date(from: "2025 12 31")!
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        
        return parameters
    }
}

