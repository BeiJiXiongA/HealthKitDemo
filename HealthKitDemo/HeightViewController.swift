
//
//  HeightViewController.swift
//  HealthKitDemo
//
//  Created by ZhangWei-SpaceHome on 2017/2/13.
//  Copyright © 2017年 zhangwei. All rights reserved.
//

import UIKit
import HealthKit

class HeightViewController: UIViewController {

    let heightQuantityType = HKQuantityType.quantityType(forIdentifier: .height)! as HKQuantityType
    
    lazy var typesShare: NSSet = {
        return NSSet(objects: self.heightQuantityType)
    }()
    
    lazy var healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        if HKHealthStore.isHealthDataAvailable() {
//            
//            healthStore.requestAuthorization(toShare: typesRead as? Set<HKSampleType>, read: typesRead as? Set<HKObjectType>) {[weak self] (success, error) in
//                let strongSelf = self!
//                if success && error == nil {
//                    print("successfully received authorization")
//                    DispatchQueue.main.async {
//                        strongSelf.readWeightInfomation()
//                    }
//                }else{
//                    if let theError = error{
//                        print("Error occurred = \(theError)")
//                    }
//                }
//            }
//        }else{
//            print("Health data is not available")
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
