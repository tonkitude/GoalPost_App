//
//  ViewController.swift
//  goalpost-app
//
//  Created by Yashika Tonk on 10/03/23.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

var goals: [Goal] = []

class GoalsVC: UIViewController {
    
    var undoTimer: Timer!
    var currentGoal: Goal?
    //var deletedGoal: Goal?
    var undoAction: UndoType?

    //auxData for undo delete
    var auxDescription:String?
    var auxType: String?
    var auxCompletionValue: Int32 = 0
    var auxProgress: Int32 = 0

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var undoView: UIView!
    @IBOutlet weak var undoLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        //var goal = Goal()
        //goal.goalProgress = Int32(exactly: 12.0)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("13")
        fetchCoreDataObjects()
        tableView.reloadData()
        print("34")
        
        currentGoal = CurrentGoal.shared.getGoal()
        if currentGoal != nil {
            undoAction = .created
            CurrentGoal.shared.setGoal(nil)
            startTimer()
        }
    }

    func startTimer() {
        self.undoView.isHidden = false
        switch undoAction {
        case .created:
            self.undoLbl.text = undoAction!.rawValue
        case .removed:
            self.undoLbl.text = undoAction!.rawValue
        default: break
        }
        undoTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { (_) in
            self.undoView.isHidden = true
        })
    }
    
    func stopTimer() {
        undoView.isHidden = true
        undoTimer.invalidate()
    }
    
    func fetchCoreDataObjects() {
        self.fetch{ (complete) in
            if complete {
                if goals.count > 0 {
                    tableView.isHidden = false
                }
                else{
                    self.tableView.isHidden = true
                }
            }
        }
    }
    
    @IBAction func addGoalButtonWasPressed(_ sender: Any) {
        guard let createGoalVC = storyboard?.instantiateViewController(withIdentifier: "CreateGoalVC")else{ return }
        dismiss(animated: true)
        presentDetail(createGoalVC)
    }
    
    @IBAction func undoBtnWasPressed(_ sender: Any) {
        print("entered")
        switch undoAction {
            case .created:
                if currentGoal != nil {
                    removeGoal(currentGoal!)
                    self.refreshTableView()
                }
                break
            case .removed:
                //create again the goal
            if self.auxDescription != nil {
                //print(deletedGoal!)
                self.saveGoal(self.auxDescription!, type: self.auxType!, completionValue: self.auxCompletionValue, progress: self.auxProgress)
                { (_, complete) in
                    if complete {
                        self.refreshTableView()
                    }
                }
            }
            default: break
        }
    }
    
    func refreshTableView() {
            fetchCoreDataObjects()
            stopTimer()
            tableView.reloadData()
        }
}

extension GoalsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell") as? GoalCell else {return UITableViewCell()}
        
        let goal = goals[indexPath.row]
        cell.ConfigureCell(goal: goal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            let aux = goals[indexPath.row]
            self.auxDescription = aux.goalDescription
            self.auxType = aux.goalType
            self.auxProgress = aux.goalProgress
            self.auxCompletionValue = aux.goalCompletionValue
            
            self.removeGoal(atIndexPath: indexPath)
            self.fetchCoreDataObjects()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.undoAction = .removed
            self.startTimer()
        }
        
        let addAction = UITableViewRowAction(style: .normal, title: "ADD 1") { rowAction, indexPath in
            self.setProgress(atIndexpath: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        addAction.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        
        return [deleteAction, addAction]
    }
}

extension GoalsVC {
    
    func setProgress( atIndexpath indexPath: IndexPath) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let chosenGoal = goals[indexPath.row]
        if chosenGoal.goalProgress < chosenGoal.goalCompletionValue {
            chosenGoal.goalProgress += 1
        }
        else { return }
        
        do{
            try managedContext.save()
            print("Successfully set progress!")
        } catch {
            debugPrint("Could not set Progress: \(error.localizedDescription)")
        }
    }
    
    func removeGoal(atIndexPath indexPath: IndexPath) {
        removeGoal(goals[indexPath.row])
    }
    
    func removeGoal(_ goal: Goal) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        managedContext.delete(goal)
        
        do{
            try managedContext.save()
            print("Sucessfully removed goal")
        } catch {
            debugPrint("Could not remove! \(error.localizedDescription)")
        }
    }
    
    func fetch(completion: (_ complete: Bool) -> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let fetchRequest = NSFetchRequest<Goal>(entityName: "Goal")
        
        do
        {
            goals = try managedContext.fetch(fetchRequest)
            print("Successfully fetched data.")
            completion(true)
        }catch
        {
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
    
}
