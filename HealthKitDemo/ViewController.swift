//
//  ViewController.swift
//  HealthKitDemo
//
//  Created by ZhangWei-SpaceHome on 2017/2/9.
//  Copyright © 2017年 zhangwei. All rights reserved.
//

import UIKit
import HealthKit

let WIDTH = UIScreen.main.bounds.size.width
let HEIGHT = UIScreen.main.bounds.size.height

class ViewController: UIViewController {

    
    let heightQuantityType = HKQuantityType.quantityType(forIdentifier: .height)! as HKQuantityType
    
    let weightQuantityType = HKQuantityType.quantityType(forIdentifier: .bodyMass)! as HKQuantityType
    
    let heartRateQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate)! as HKQuantityType
    
    let inputTextField = UITextField.init(frame: CGRect.init(x: 50, y: 100, width: WIDTH - 100, height: 40))
    
    let rightLabel: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 30))
    
    let saveButton = UIButton.init(type: UIButtonType.custom)
    
    lazy var healthStore = HKHealthStore()
    
    lazy var typesShare: NSSet = {
        return NSSet(objects: self.heightQuantityType, self.weightQuantityType)
    }()
    
    lazy var typesRead: NSSet = {
        return NSSet(objects: self.heightQuantityType, self.weightQuantityType, self.heartRateQuantityType)
    }()
    
    lazy var types: NSSet = {
        return NSSet(object: self.weightQuantityType)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.white
        rightLabel.text = "kg"
        rightLabel.font = UIFont.systemFont(ofSize: 13)
        rightLabel.textColor = UIColor.black
        rightLabel.textAlignment = .right
        inputTextField.rightViewMode = .always
        inputTextField.rightView = rightLabel
        
        inputTextField.textAlignment = .center
        inputTextField.borderStyle = .roundedRect
        inputTextField.textColor = UIColor.black
        self.view.addSubview(inputTextField)
        
        saveButton.frame = CGRect.init(x:WIDTH/2 - 30 , y:inputTextField.frame.origin.y + inputTextField.frame.size.height + 30, width: 60, height: 30)
        saveButton.setTitle("保存", for: .normal)
        saveButton.setTitleColor(UIColor.blue, for: .normal)
        saveButton.addTarget(self, action: #Selector("saveUserWeight"), for: .touchUpInside)
        self.view.addSubview(saveButton)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if HKHealthStore.isHealthDataAvailable() {
            
            healthStore.requestAuthorization(toShare: typesRead as? Set<HKSampleType>, read: typesRead as? Set<HKObjectType>) {[weak self] (success, error) in
                let strongSelf = self!
                if success && error == nil {
                    print("successfully received authorization")
                    DispatchQueue.main.async {
                        strongSelf.readWeightInfomation()
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
    
    func readWeightInfomation() {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending:false)
        
        let query = HKSampleQuery.init(sampleType: weightQuantityType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) {[weak self] (query, results, error) in
            if (results?.count)! > 0{
                let sample = results?[0] as! HKQuantitySample
                
                let weightInKilograms: Double = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                
                let formatter = MassFormatter()
                
                let kilogramSuffix = formatter.unitString(fromValue: weightInKilograms, unit: .kilogram)
                
                DispatchQueue.global().sync {
                    let strongSelf = self!
                    
                    strongSelf.rightLabel.text = kilogramSuffix
                    strongSelf.rightLabel.sizeToFit()
                    
                    let weightFormattedAsString = NumberFormatter.localizedString(from: NSNumber.init(value: weightInKilograms), number: .none)
                    
                    strongSelf.inputTextField.text = weightFormattedAsString
                }
            }else{
                print("have not results")
            }
        }
        
        healthStore.execute(query)
    }
    
    func saveUserWeight() {
        let kilogramUnit = HKUnit.gramUnit(with: .kilo)
        let weightQuantity = HKQuantity.init(unit: kilogramUnit, doubleValue: (inputTextField.text! as NSString).doubleValue)
        let now: NSDate = NSDate()
        
        let sample = HKQuantitySample.init(type: weightQuantityType, quantity: weightQuantity, start: now as Date, end: now as Date)
        healthStore.save(sample) { (succeeded, error) in
            if succeeded && error == nil {
                print("save weight success!")
            }else{
                print("save weight failed!")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

