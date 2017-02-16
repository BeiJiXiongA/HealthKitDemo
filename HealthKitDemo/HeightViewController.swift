
//
//  HeightViewController.swift
//  HealthKitDemo
//
//  Created by ZhangWei-SpaceHome on 2017/2/13.
//  Copyright © 2017年 zhangwei. All rights reserved.
//

import UIKit
import HealthKit

class HeightViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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


    var heightUnit: HeightUnits = .Millimeters
    
   func willSet{
        readHeightInfomation()
    }
    
    let heightQuantityType = HKQuantityType.quantityType(forIdentifier: .height)! as HKQuantityType
    
    var selectedIndexPath = NSIndexPath.init(row: 0, section: 0)
    
    let inputTextField = UITextField.init(frame: CGRect.init(x: 50, y: 100, width: WIDTH - 100, height: 40))
    let saveButton = UIButton.init(type: UIButtonType.custom)
    
    let unitTableView: UITableView! = UITableView.init(frame: CGRect.zero, style: .plain)
    
    lazy var types: NSSet = {
        return NSSet(objects: self.heightQuantityType)
    }()
    
    lazy var healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        saveButton.frame = CGRect.init(x:WIDTH/2 - 30 , y:inputTextField.frame.origin.y + inputTextField.frame.size.height + 30, width: 60, height: 30)
        saveButton.setTitle("save", for: .normal)
        saveButton.setTitleColor(UIColor.blue, for: .normal)
        self.view.addSubview(saveButton)
        
        unitTableView.frame = CGRect.init(x: 10, y: saveButton.bottom()+30, width: WIDTH - 20, height: HEIGHT - unitTableView.top() - 30);
        unitTableView.backgroundColor = UIColor.green
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewInfo.cellIndentifier, for: indexPath) as UITableViewCell
        let heightUnit = HeightUnits.allValus[indexPath.row]
        cell.textLabel?.text = heightUnit.rawValue
        if indexPath == (selectedIndexPath as IndexPath){
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previouslySelectedIndexPath = selectedIndexPath
        selectedIndexPath = indexPath as NSIndexPath
        
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
                
                let currentlySelectedUnit = strongSelf.heightu
            }else{
                print("Could not read the user's height ")
                print("or no height data was available")
            }
        }
//        let query = HKSampleQuery.init(sampleType: heightQuantityType, predicate: nil, limit: 1, sortDescriptors:[sortDescriptor]) {[weak self] (query: HKSampleQuery, results: [AnyObject]!, error: NSError!) in
//            let strongSelf = self!
//            if results.count > 0{
//                
//            }else{
//                print("Could not read the user's height ")
//                print("or no height data was available")
//            }
//        }
        healthStore.execute(query)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
