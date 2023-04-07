//
//  FinishGoalVC.swift
//  goalpost-app
//
//  Created by Yashika Tonk on 16/03/23.
//

import UIKit
import CoreData

class FinishGoalVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var createGoalBtn: UIButton!
    @IBOutlet weak var pointsTextField: UITextField!
    
    var goalDescription : String!
    var goalType: GoalType!
    
    func initData(description: String, type: GoalType) {
        self.goalDescription = description
        self.goalType = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createGoalBtn.bindToKeyboard()
        pointsTextField.delegate =  self
    }
    
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        dismissDetail()
    }
    @IBAction func createGoalBtnWasPressed(_ sender: Any) {
        //pass data into Core Data Goal Model
        if pointsTextField.text != "" {
            self.saveGoal(goalDescription, type: goalType.rawValue, completionValue: Int32(pointsTextField.text!)!, progress: Int32(0)) {
                (goalCreated, complete) in
                    if complete {
                        CurrentGoal.shared.setGoal(goalCreated)
                        self.view.window?.rootViewController?.dismissDetail()
                    }
                }
        }
    }
    
}
