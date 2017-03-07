//
//  AddBurnedCaloriesToDietViewController.swift
//  HealthKitDemo
//
//  Created by ZhangWei-SpaceHome on 2017/3/6.
//  Copyright © 2017年 zhangwei. All rights reserved.
//

import UIKit
import HealthKit

extension NSDate{
    func dateByAddingMinutes(minutes: Double) -> NSDate {
        return self.addingTimeInterval(minutes * 60.0)
    }
}

struct CalorieBurner {
    var name: String
    var calories: Double
    var startDate = NSDate()
    var endDate = NSDate()
    
    init(name: String, calories: Double, startDate: NSDate, endDate: NSDate) {
        self.name = name
        self.calories = calories
        self.startDate = startDate
        self.endDate = endDate
    }
    
    init(name: String, calories: Double, minutes: Double) {
        self.name = name
        self.calories = calories
        self.startDate = NSDate()
        self.endDate = self.startDate.dateByAddingMinutes(minutes: minutes)
    }
}

@objc(AddBurnedCaloriesToDietViewControllerDelegate)
protocol AddBurnedCaloriesToDietViewControllerDelegate {
    @objc optional func addBurnedCaloriesToDietViewController(
        sender:AddBurnedCaloriesToDietViewController,
        addedCalorieBurnerWithName: String,
        calories: Double,
        startDate: NSDate,
        endDate: NSDate)
}

class AddBurnedCaloriesToDietViewController: UITableViewController {

    struct TableViewValues {
        static let identifier = "Cell"
    }
    
    lazy var formatter: EnergyFormatter = {
        let theFormatter = EnergyFormatter()
        theFormatter.isForFoodEnergyUse = true
        return theFormatter
    }()
    
    var delegate: AddBurnedCaloriesToDietViewControllerDelegate?
    
    lazy var allCaloridBurners: [CalorieBurner] = {
        let cycling = CalorieBurner.init(name: "1 hour on the bike", calories: 450, minutes: 60)
        
        let running = CalorieBurner.init(name: "30 minutes fast-paced running", calories: 300, minutes: 30)
        
        let swimming = CalorieBurner.init(name: "20 minutes crawl-swimmming", calories: 400, minutes: 20)
        return [cycling, running, swimming]
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.selectRow(at: NSIndexPath.init(row: 0, section: 0) as IndexPath, animated: false, scrollPosition: .none)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCaloridBurners.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: TableViewValues.identifier)
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: TableViewValues.identifier)
        }
        let burner = allCaloridBurners[indexPath.row]
        
        let caloridsAsString = formatter.string(fromValue: burner.calories, unit: .kilocalorie)
        
        cell?.textLabel?.text = burner.name
        cell?.detailTextLabel?.text = caloridsAsString
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self .addToDiet()
    }
    
    func addToDiet() {
        let burner = allCaloridBurners[(tableView.indexPathForSelectedRow?.row)!]
        
        if let theDelegate = delegate {
            theDelegate.addBurnedCaloriesToDietViewController!(sender: self, addedCalorieBurnerWithName: burner.name, calories: burner.calories, startDate: burner.startDate, endDate: burner.endDate)
        }
        
        navigationController!.popViewController(animated: true)
    }
}
