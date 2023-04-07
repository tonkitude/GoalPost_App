//
//  CurrentGoal.swift
//  goalpost-app
//
//  Created by Yashika Tonk on 05/04/23.
//

import Foundation

class CurrentGoal: Goal {
    
    static var shared = CurrentGoal()
    
    var goal: Goal?
    
    func setGoal(_ goal: Goal?)
    {
        self.goal = goal
    }
    
    func getGoal() -> Goal? {
        return self.goal
    }
}
