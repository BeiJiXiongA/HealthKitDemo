



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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCaloriesBurned.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: TableViewValues.identifier)
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: TableViewValues.identifier)
        }
        let burner = allCaloriesBurned[indexPath.row]
        
        let caloriesAsString = formatter.string(fromValue: burner.calories, unit: .kilocalorie)
        
        cell?.textLabel?.text = burner.name
        cell?.detailTextLabel?.text = caloriesAsString
        return cell!
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if HKHealthStore.isHealthDataAvailable(){
            healthStore.requestAuthorization(toShare: nil, read: types as? Set<HKObjectType>){ [weak self](success, error) in
                let strongSelf = self
                if success && error == nil {
                    DispatchQueue.main.async {
                        strongSelf?.startObservingBurnedCaloriesChanges()
                    }
                }else{
                    print("Error occurred = \(error)")
                }
            }
        }else{
            print("Health data is not available")
        }
        
        if allCaloriesBurned.count > 0{
            let firstCell = NSIndexPath.init(row: 0, section: 0)
            tableView.selectRow(at: firstCell as IndexPath, animated: true, scrollPosition: .top)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let rightButton:UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(rightItemClick))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    func rightItemClick() {
        let addCaloriesVC: AddBurnedCaloriesToDietViewController = AddBurnedCaloriesToDietViewController()
        addCaloriesVC.delegate = self;
        self.navigationController?.pushViewController(addCaloriesVC, animated: true)
    }
    
    func addBurnedCaloriesToDietViewController(sender: AddBurnedCaloriesToDietViewController, addedCalorieBurnerWithName: String, calories: Double, startDate: NSDate, endDate: NSDate) {
        let quantity = HKQuantity.init(unit: unit, doubleValue: calories)
        let metadata = [
            HKMetadataKeyExerciseName: addedCalorieBurnerWithName
        ]
        
        let sample = HKQuantitySample.init(type: burnedEnergyQuantityType, quantity: quantity, start: startDate as Date, end: endDate as Date, metadata: metadata)
        
        healthStore.save(sample) { [weak self](succeeded, error) in
            
            let strongSelf = self!
            
            if succeeded && error == nil {
                print("save calories success!")
                strongSelf.tableView.reloadData()
            }else{
                print("save calories failed! \(error)")
            }
        }
    }
    
    func  fetchBurnedCaloriesInLastDay() {
        let sortDescriptor = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery.init(sampleType: burnedEnergyQuantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self](query, results, error) in
            print("Receive new data from the query.Processing...")
            
            let strongSelf = self!
            
            if (results?.count)! > 0{
                strongSelf.allCaloriesBurned = [CalorieBurner]()
                
                for sample in results as! [HKQuantitySample]{
                    let burnerName = sample.metadata?[HKMetadataKeyExerciseName] as? NSString
                    let calories = sample.quantity.doubleValue(for: strongSelf.unit)
                    
//                    let caloriesAsString = strongSelf.formatter.string(fromValue: calories, unit: .kilocalorie)
                    
                    let burner = CalorieBurner.init(name: burnerName as! String, calories: calories, startDate: sample.startDate as NSDate, endDate: sample.endDate as NSDate)
                    
                    strongSelf.allCaloriesBurned.append(burner)
                }
                
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
                
            }else{
                print("Could not read the burened calories or not burned calories data was available")
            }
        }
        healthStore.execute(query)
    }
    
    deinit {
        stopObservingBurnedCaloriesChanges()
    }
    
    func stopObservingBurnedCaloriesChanges() {
        if isObservingBurnedCalories == false{
            return
        }
        
        healthStore.stop(query)
        healthStore.disableAllBackgroundDelivery { [weak self](succeeded, error) in
            if succeeded{
                self?.isObservingBurnedCalories = false
                print("Disabled background delivery of burned energy changes")
            }else{
                if let theError = error{
                    print("Failed to disable background delivery of"+"burned energy changes.")
                    print("Error = \(theError)")
                }
            }
        }
    }
    
    func startObservingBurnedCaloriesChanges()  {
        if  isObservingBurnedCalories {
            return
        }
        
        healthStore.execute(query)
        healthStore.enableBackgroundDelivery(for: burnedEnergyQuantityType, frequency: .immediate) { (succeeded, error) in
            if succeeded{
                self.isObservingBurnedCalories = true
                print("Enable background delivery of burned energy changes")
            }else{
                if let theError = error{
                    print("Failed to enable background delivery"+" of burned energy changes.")
                    print("Error = \(theError)")
                }
            }
        }
    }
}
