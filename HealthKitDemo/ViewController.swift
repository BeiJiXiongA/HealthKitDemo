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

    
    let heightQuantity = HKQuantityType.quantityType(forIdentifier: .height)! as HKQuantityType
    
    let weightQuantity = HKQuantityType.quantityType(forIdentifier: .bodyMass)! as HKQuantityType
    
    let heartRateQuantity = HKQuantityType.quantityType(forIdentifier: .heartRate)! as HKQuantityType
    
    let inputTextField = UITextField.init(frame: CGRect.init(x: 100, y: 60, width: WIDTH - 200, height: 40))
    
    let saveButton = UIButton.init(type: UIButtonType.custom)
    
    lazy var healthStore = HKHealthStore()
    
    lazy var typesShare: NSSet = {
        return NSSet(objects: self.heightQuantity, self.weightQuantity)
    }()
    
    lazy var typesRead: NSSet = {
        return NSSet(objects: self.heightQuantity, self.weightQuantity, self.heartRateQuantity)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.white
        
        
        self.view.addSubview(inputTextField)
        
        saveButton.frame = CGRect.init(x:WIDTH/2 - 30 , y:inputTextField.frame.origin.y + inputTextField.frame.size.height + 30, width: 60, height: 30)
        saveButton.setTitle("保存", for: .normal)
        self.view.addSubview(saveButton)
        
        if HKHealthStore.isHealthDataAvailable() {
            
            healthStore.requestAuthorization(toShare: typesRead as? Set<HKSampleType>, read: typesRead as? Set<HKObjectType>) { (success, error) in
                if success && error == nil {
                    print("successfully received authorization")
                }else{
                    if let theError = error{
                         print("Error occurred = \(theError)")
                     }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

