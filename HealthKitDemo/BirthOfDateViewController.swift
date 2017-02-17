//
//  BirthOfDateViewController.swift
//  HealthKitDemo
//
//  Created by ZhangWei-SpaceHome on 2017/2/17.
//  Copyright © 2017年 zhangwei. All rights reserved.
//

import UIKit
import HealthKit

class BirthOfDateViewController: UIViewController {

    let dateOfBirthCharacteristicType = HKCharacteristicType.characteristicType(forIdentifier: .dateOfBirth)! as HKCharacteristicType
    
    let birthLabel = UILabel.init(frame: CGRect.init(x: 50, y: 100, width: WIDTH - 100, height: 30))
    
    lazy var types: NSSet = {
        return NSSet(object: self.dateOfBirthCharacteristicType)
    }()
    
    lazy var healthStrore = HKHealthStore()
    
//    lazy var components: NSSet = {
//        return NSSet(object: Calendar.Component)
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if HKHealthStore.isHealthDataAvailable(){
            healthStrore.requestAuthorization(toShare: nil, read: types as? Set<HKObjectType>){ [weak self](success, error) in
                let strongSelf = self
                if success && error == nil {
                    strongSelf?.readDateOfBirthInfomation()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        self.title = "生日"
        
        self.birthLabel.textColor = UIColor.gray
        self.birthLabel.textAlignment = .center
        self.view.addSubview(self.birthLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readDateOfBirthInfomation() {
//        var dateOfBirthError: NSError?
        let birthDate = try? healthStrore.dateOfBirth()
        
//        if dateOfBirthError{
//            print("Could not read user's date of birth")
//            print("error \(dateOfBirthError)")
//        }else{
            if let dateOfBirth = birthDate{
//                let foramtter = NumberFormatter()
                let now = NSDate()
                let set: NSSet = NSSet(object: Calendar.Component.year)
                let components = NSCalendar.current.dateComponents(set as! Set<Calendar.Component>, from: dateOfBirth, to: now as Date)
                
                let age = components.year
                print("The user is \(age) years old")
                print("User's birth \(birthDate)")
                self.birthLabel.text = birthDate?.description
            }else{
                print("User has not specified her date ob birth yet")
            }
//        }
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
