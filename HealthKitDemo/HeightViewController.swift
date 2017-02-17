
//
//  HeightViewController.swift
//  HealthKitDemo
//
//  Created by ZhangWei-SpaceHome on 2017/2/13.
//  Copyright © 2017年 zhangwei. All rights reserved.
//

import UIKit
import HealthKit

enum HeightUnits: String {
    case Millimeters = "Millimeters"
    case Centimeters = "Centimeters"
    case Meters = "Meters"
    case Inches = "Inches"
    case Feet = "Feet"
    static let allValus = [Millimeters, Centimeters, Meters, Inches, Feet]
    
    func healthKitUnit() -> HKUnit {
        switch self {
        case .Millimeters:
            return HKUnit.meterUnit(with: .milli)
        case .Centimeters:
            return HKUnit.meterUnit(with: .centi)
        case .Meters:
            return HKUnit.meter()
        case .Inches:
            return HKUnit.inch()
        case .Feet:
            return HKUnit.foot()
        }
    }
}

class HeightViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var heightUnit: HeightUnits = .Millimeters{
        willSet{
            readHeightInfomation()
        }
    }
    
    var selectedIndexPath = NSIndexPath.init(row: 0, section: 0)
    
    let heightQuantityType = HKQuantityType.quantityType(forIdentifier: .height)! as HKQuantityType
    
    let inputTextField = UITextField.init(frame: CGRect.init(x: 50, y: 100, width: WIDTH - 100, height: 40))
    let saveButton = UIButton.init(type: UIButtonType.custom)
    
    let unitTableView: UITableView! = UITableView.init(frame: CGRect.zero, style: .plain)
    
    lazy var types: NSSet = {
        return NSSet(objects: self.heightQuantityType)
    }()
    
    lazy var healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "身高"
        self.view.backgroundColor = UIColor.white
        
        inputTextField.borderStyle = .roundedRect
        inputTextField.textColor = UIColor.gray
        self.view.addSubview(inputTextField)

        // Do any additional setup after loading the view.
        saveButton.frame = CGRect.init(x:WIDTH/2 - 30 , y:inputTextField.frame.origin.y + inputTextField.frame.size.height + 30, width: 60, height: 30)
        saveButton.setTitle("save", for: .normal)
        saveButton.setTitleColor(UIColor.blue, for: .normal)
        saveButton.backgroundColor = UIColor.orange
        saveButton.addTarget(self, action: #selector(saveHeight), for: .touchUpInside)
        self.view.addSubview(saveButton)
        
        unitTableView.frame = CGRect.init(x: 10, y: saveButton.bottom()+30, width: WIDTH - 20, height: HEIGHT - unitTableView.top() - 30);
        unitTableView.backgroundColor = UIColor.white
        unitTableView.tableFooterView = UIView.init()
        unitTableView.delegate = self
        unitTableView.dataSource = self
        self.view .addSubview(unitTableView)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if HKHealthStore.isHealthDataAvailable() {
            
            healthStore.requestAuthorization(toShare: types as? Set<HKSampleType>, read: types as? Set<HKObjectType>) {[weak self] (success, error) in
                let strongSelf = self!
                if success && error == nil {
                    print("successfully received authorization")
                    DispatchQueue.main.async {
                        strongSelf.readHeightInfomation()
                    }
                }else{
                    if let theError = error{
                        print("Error occurred = \(theError)")
                    }
                }
            }
        }else{
            print("Health data is not available")
        }
        
    }
    
    struct TableViewInfo {
        static let cellIndentifier = "Cell"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HeightUnits.allValus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: TableViewInfo.cellIndentifier)
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: TableViewInfo.cellIndentifier)
        }
        let heightUnit = HeightUnits.allValus[indexPath.row]
        cell?.textLabel?.text = heightUnit.rawValue
        if indexPath == (selectedIndexPath as IndexPath){
            cell?.accessoryType = .checkmark
        }else{
            cell?.accessoryType = .none
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previouslySelectedIndexPath = selectedIndexPath
        selectedIndexPath = indexPath as NSIndexPath
        heightUnit = HeightUnits.allValus[indexPath.row]
        tableView.reloadRows(at: [previouslySelectedIndexPath as IndexPath, selectedIndexPath as IndexPath], with: .automatic)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readHeightInfomation() {
        let sortDescriptor = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery.init(sampleType: heightQuantityType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) {[weak self] (query, results, error) in
            let strongSelf = self!
            if (results?.count)! > 0{
                let sample = results?[0] as! HKQuantitySample
                
                let currentlySelectedUnit = strongSelf.heightUnit.healthKitUnit()
                
                let heightInUnit = sample.quantity.doubleValue(for: currentlySelectedUnit)
                
                DispatchQueue.main.async {
                    let heightFormattedAsString = NumberFormatter.localizedString(from: NSNumber.init(value: heightInUnit), number: .decimal)
                    strongSelf.inputTextField.text = heightFormattedAsString
                }
            }else{
                print("Could not read the user's height ")
                print("or no height data was available")
            }
        }
        healthStore.execute(query)
    }
    
    func saveHeight() {
        let currentlySelectedUnit = heightUnit.healthKitUnit()
        let heightQuantity = HKQuantity.init(unit: currentlySelectedUnit, doubleValue: (inputTextField.text! as NSString).doubleValue)
        let now: NSDate = NSDate()
        
        let sample = HKQuantitySample.init(type: heightQuantityType, quantity: heightQuantity, start: now as Date, end: now as Date)
        healthStore.save(sample) { (succeeded, error) in
            if succeeded && error == nil {
                print("save height success!")
            }else{
                print("save height failed!")
            }
        }
    }

    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(selectedIndexPath, forKey: "selectedIndexPath")
        coder.encode(heightUnit.rawValue, forKey: "heightUnit")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        selectedIndexPath = coder.decodeObject(forKey: "selectedIndexPath") as! NSIndexPath
        if let newUnit = HeightUnits.init(rawValue: coder.decodeObject(forKey: "heightUnit") as! String){
            heightUnit = newUnit
        }
        
    }
}
