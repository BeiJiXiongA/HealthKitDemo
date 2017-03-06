



//
//  CalorieViewController.swift
//  HealthKitDemo
//
//  Created by ZhangWei-SpaceHome on 2017/3/6.
//  Copyright © 2017年 zhangwei. All rights reserved.
//

import UIKit
import HealthKit

let HKMetadataKeyExerciseName = "ExeriseName"

extension NSDate{
    func beginningOfDay() -> NSDate {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self as Date)! as NSDate
    }
}

class CalorieViewController: UITableViewController, AddBurnedCaloriesToDietViewControllerDelegate {

    var allCaloriesBurned = [CalorieBurner]()
    
    lazy var formatter: EnergyFormatter = {
        let theFormatter = EnergyFormatter()
        theFormatter.isForFoodEnergyUse = true
        return theFormatter
    }()
    
    let segueIdentifier = "burnCalories"
    var isObservingBurnedCalories = false
    
    lazy var unit = HKUnit.kilocalorie()
    
    struct TableViewValues {
        static let identifier = "Cell"
    }
    
    let burnedEnergyQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)! as HKQuantityType
    
    lazy var types: NSSet = {
        return NSSet(object: self.burnedEnergyQuantityType)
    }()
    
    lazy var healthStore = HKHealthStore()
    
    lazy var predicate: NSPredicate = {
        let options: NSCalendar.Options = .wrapComponents
        
        let nowDate = NSDate()
        
        let beginningOfToday = nowDate.beginningOfDay()
        
        let tomorrowDate: NSDate = Calendar.current.date(byAdding: .day, value: 1, to: NSDate() as Date)! as NSDate
        
        let beginningOfTomorrow = tomorrowDate.beginningOfDay()
        
        return HKQuery.predicateForSamples(withStart: beginningOfToday as Date, end: beginningOfTomorrow as Date, options: .strictEndDate)
    }()
    
    lazy var query: HKObserverQuery = HKObserverQuery(sampleType: self.burnedEnergyQuantityType, predicate: self.predicate) {[weak self]query,completionHandler, error in
        let strongSelf = self!
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
}
