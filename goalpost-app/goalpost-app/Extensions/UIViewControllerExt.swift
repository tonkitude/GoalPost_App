//
//  UIViewControllerExt.swift
//  goalpost-app
//
//  Created by Yashika Tonk on 11/03/23.
//

import UIKit

extension UIViewController {
    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push //CATransitionType.push
        transition.subtype = .fromRight //CATransitionSubtype.fromRightT
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        
        present(viewControllerToPresent, animated: false)
    }
    
    func presentSecondaryDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push //CATransitionType.push
        transition.subtype = .fromRight //CATransitionSubtype.fromRight
        
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        
        guard let presentedViewController = presentedViewController else { return }
        presentedViewController.dismiss(animated: false){
            self.view.window?.layer.add(transition, forKey: kCATransition)
            self.present(viewControllerToPresent, animated: false)
        }
    }
    
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push //CATransitionType.push
        transition.subtype = .fromLeft //CATransitionSubtype.fromLeft
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false)
    }
    
    func saveGoal(_ description: String, type: String, completionValue: Int32, progress: Int32, completion: (_ goalCreated: Goal?, _ complete: Bool) -> ()) {
            guard let manageContext = appDelegate?.persistentContainer.viewContext else { return }
            let goal = Goal(context: manageContext)
            goal.goalDescription = description
            goal.goalType = type
            goal.goalCompletionValue = completionValue
            goal.goalProgress = progress
            
            do {
                try manageContext.save()
                completion(goal, true)
            } catch {
                debugPrint("Could not save: \(error.localizedDescription)")
                completion(nil, false)
            }
        }
}
