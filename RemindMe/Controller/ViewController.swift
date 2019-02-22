//
//  ViewController.swift
//  RemindMe
//
//  Created by Kate on 21/2/19.
//  Copyright © 2019 Kate Guru. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CanReceive {

    @IBOutlet weak var choresTable: UITableView!
    
    var choresArray = [Chore]()
//DEL    var choreIdToPass : Int = 0
    var modeToPass : String = ""
    var choreRowToPass : Int = 0
    var choreTitleToPass : String = ""
    
    //choreImage
    //choreMusic
    //choreStartDate
    //choreEndDate
    //choreFrequency
    //choreTimesPerDay
    //choreReminderTime1
    
    var modePassedBack : String = ""
    var choreIDPassedBack : Int = 0
    var choresArrayRowPassedBack : Int = 0
    var choreTitlePassedBack : String = ""
    
    //choreImage
    //choreMusic
    //choreStartDate
    //choreEndDate
    //choreFrequency
    //choreTimesPerDay
    //choreReminderTime1
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Chore.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set yourself as the delegate and datasource here:
        choresTable.delegate = self
        choresTable.dataSource = self
        
        // load up the array from user preferences (if we stored something in the file)
        choresTable.rowHeight = 50.0
        loadItems()
        
        //print (dataFilePath)
        choresTable.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choresArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = choresTable.dequeueReusableCell(withIdentifier: "choreItemCell", for: indexPath)
        cell.textLabel?.text = choresArray[indexPath.row].ch_title
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // populate details from selected chore
        modeToPass = "Update"
        choreTitleToPass = choresArray[indexPath.row].ch_title!
//DEL        choreIdToPass = Int(choresArray[indexPath.row].ch_choreId)
        choreRowToPass = indexPath.row
        
        // perform segue to ChoreDetailsController
        self.performSegue(withIdentifier: "goToChoreDetails", sender: self)
    }
    
    
    @IBAction func addNewButtonPressed(_ sender: Any) {
        modeToPass = "New"
        choreTitleToPass = "Enter chore title here"
        choreRowToPass = 0
    }
    
    
    //MARK:  SEGUE FUNCTIONS
     override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let destinationVC = segue.destination as! ChoreDetailsController
        destinationVC.modePassOver = modeToPass
        destinationVC.choreTitlePassOver = choreTitleToPass
//DEL        destinationVC.choreIDPassOver = choreIdToPass
        destinationVC.choreRowPassOver = choreRowToPass
        destinationVC.backscreen = self
    }
    
    func dataReceived(mode: String, title: String, row_id: Int) {
        print("Data received back: \(mode) and \(title) and \(row_id)")
//DEL        choreTitlePassedBack = data
//DEL        choresArrayRowPassedBack = row_id
        if mode == "Update" {
            let request : NSFetchRequest<Chore> = Chore.fetchRequest()
            do {
                let test = try context.fetch(request)
                let objectUpdate = test[row_id] as NSManagedObject
                objectUpdate.setValue(title, forKey: "ch_title")
            } catch {
                print ("Error updating record \(error)")
            }
        
            saveItems()
            loadItems()
        } else {
            let newChore = Chore(context: self.context)
            newChore.ch_title = title
            newChore.ch_choreId = 1234
            newChore.sh_suspended = false
            //what will happen once the user clicks on the Add Item button on our UIAlert
            self.choresArray.append(newChore)
            saveItems()
            loadItems()
        }
    }
    
    
    //MARK: MODEL MANIPULATION METHODS
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving to Core Data, \(error)")
        }
    }
    
    func loadItems() {
        let request : NSFetchRequest<Chore> = Chore.fetchRequest()
        do {
            choresArray = try context.fetch(request)
        } catch {
            print("Error loading item array, \(error)")
        }
        choresTable.reloadData()
    }
    
//    func deleteItems(rowNumber: Int) {
//        context.delete(self.choresArray[rowNumber])
//        choresArray.remove(at: rowNumber)
//    }
    
    

    
    //    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    //        var newToDo = UITextField()
    //        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
    //        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
    //
    //            let newToDoItem = ToDoItem(context: self.context)
    //            newToDoItem.title = newToDo.text!
    //            newToDoItem.done = false
    //
    //            //what will happen once the user clicks on the Add Item button on our UIAlert
    //            self.itemArray.append(newToDoItem)
    //            self.tableView.reloadData()
    //            self.saveItems()
    //        }
    //
    //        alert.addTextField { (alertTextField) in
    //            alertTextField.placeholder = "Create new item"
    //            newToDo = alertTextField
    //        }
    //
    //        alert.addAction(action)
    //        present(alert, animated: true, completion: nil)
    //
    //    }

}

