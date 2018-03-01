//
//  HistoryViewController.swift
//  MannFit
//
//  Created by Luis Abraham on 2018-02-20.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import UIKit
import JTAppleCalendar
import CoreData
import Charts

class HistoryViewController: UIViewController {
    let dateFormatter = DateFormatter()
    let workoutDateFormat = "yyyy-MM-dd"
    var managedObjectContext: NSManagedObjectContext!
    
    var workoutData: [WorkoutItem]?
    var workoutDates: [Date]?
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendarView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchWorkoutData()
        setupBarChart()
        calendarView.reloadData()
    }
    
    private func setupCalendarView() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.scrollToDate(Date()) { [weak self] in
            self?.calendarView.selectDates([Date()])
        }
        
        calendarView.visibleDates { [weak self] visibleDates in
            self?.setupCalendarView(from: visibleDates)
        }
    }
    
    private func fetchWorkoutData() {
        do {
            let fetchRequest = NSFetchRequest<WorkoutItem>(entityName: CoreData.WorkoutItem)
            let fetchedData = try managedObjectContext.fetch(fetchRequest)
            workoutData = fetchedData
            
            workoutDates = fetchedData.map({
                dateFormatter.dateFormat = workoutDateFormat
                let dateString = dateFormatter.string(from: $0.date)
                
                return dateFormatter.date(from: dateString)!
            })
            
        } catch {
            fatalError("Failed to fetch workout data: \(error)")
        }
    }
    
    private func setupBarChart() {
        setupBarChartAxis()
        setupBarChartBackground()
        
        guard let data = workoutData else { return }
        
        load(data, for: Date())
    }
    
    private func load(_ data: [WorkoutItem], for date: Date) {
        guard let barChartData = getBarChartData(from: data, for: date) else {
            barChartView.data = nil
            barChartView.notifyDataSetChanged()
            return
        }

        barChartView.data = barChartData
        barChartView.notifyDataSetChanged()
    }
    
    private func getBarChartData(from workoutData: [WorkoutItem], for date: Date) -> BarChartData? {
        guard let desiredData = get(workoutData, for: date) else { return nil }
        
        let yAxisValues = populateYAxis(with: desiredData)
        
        var barChartData = [BarChartDataEntry]()
        for i in 0..<24 {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(yAxisValues[i]))
            barChartData.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: barChartData, label: nil)
        chartDataSet.drawValuesEnabled = false
        chartDataSet.axisDependency = .left
        
        return BarChartData(dataSet: chartDataSet)
    }
    
    private func get(_ data: [WorkoutItem], for date: Date) -> [WorkoutItem]? {
        var desiredData = [WorkoutItem]()
        
        dateFormatter.dateFormat = workoutDateFormat
        guard let desiredDate = dateFormatter.date(from: dateFormatter.string(from: date)) else { return nil }
        
        data.forEach {
            guard let workoutDate = dateFormatter.date(from: dateFormatter.string(from: $0.date)) else { return }
            if workoutDate == desiredDate {
                desiredData.append($0)
            }
        }

        return desiredData
    }
    
    private func setupBarChartBackground() {
        barChartView.noDataText = "No workout data available."
        barChartView.noDataTextColor = UIColor.white
        
        barChartView.backgroundColor = .black
        barChartView.gridBackgroundColor = .black
        barChartView.drawGridBackgroundEnabled = true
        barChartView.chartDescription?.enabled = false
        barChartView.legend.enabled = false
        barChartView.setScaleEnabled(false)
    }
    
    private func setupBarChartAxis() {
        let formatter = AxisValueFormatter()
        
        barChartView.xAxis.valueFormatter = formatter
        barChartView.xAxis.labelTextColor = .white
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false
        
        barChartView.leftAxis.spaceBottom = 0
        barChartView.leftAxis.labelTextColor = .white
        
        barChartView.rightAxis.enabled = false
    }
    
    private func populateYAxis(with data: [WorkoutItem]) -> [Float]{
        var yAxisValues = Array(repeating: Float(0.0), count: 24)
        
        for item in data {
            let hourIndex = Calendar.current.component(.hour, from: item.date)
            yAxisValues[hourIndex] += item.absement
        }
        
        return yAxisValues
    }
    
    private func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CalendarCell else { return }

        validCell.dateLabel.textColor = (cellState.dateBelongsTo == .thisMonth) ? UIColor.white : UIColor.gray
    }
    
    private func setupCalendarView(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date

        dateFormatter.dateFormat = "yyyy"
        yearLabel.text = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "MMMM"
        monthLabel.text = dateFormatter.string(from: date)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension HistoryViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {

    }

    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: Storyboard.CalendarCell, for: indexPath) as! CalendarCell

        cell.dateLabel.text = cellState.text
        handleCellTextColor(view: cell, cellState: cellState)
        
        if let dates = workoutDates {
            cell.isWorkoutDate = dates.contains(date) && !cellState.isSelected
        }
        
        cell.selectedIndicator.isHidden = !cellState.isSelected
        

        return cell
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarView(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell,
        let data = workoutData else { return }
        
        guard cellState.dateBelongsTo == .thisMonth else {
            calendar.scrollToDate(date) {
                calendar.selectDates([date])
            }
            return
        }
        
        validCell.selectedIndicator.isHidden = false
        validCell.dateLabel.textColor = UIColor.white
        
        load(data, for: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else { return }
        validCell.selectedIndicator.isHidden = true
        
        if validCell.isWorkoutDate {
            validCell.dateLabel.textColor = Colours.workoutBlue
        } else {
            handleCellTextColor(view: cell, cellState: cellState)
        }
        
    }
    
    func calendarDidScroll(_ calendar: JTAppleCalendarView) {
        calendar.deselectAllDates()
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

extension HistoryViewController: CoreDataCompliant { }
