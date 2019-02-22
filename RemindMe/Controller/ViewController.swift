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
    var choreTitleToPass : String = ""
    //choreImage
    //choreMusic
    //choreStartDate
    //choreEndDate
    //choreFrequency
    //choreTimesPerDay
    //choreReminderTime1
    
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
        choreTitleToPass = choresArray[indexPath.row].ch_title!
        
        // perform segue to ChoreDetailsController
        self.performSegue(withIdentifier: "goToChoreDetails", sender: self)
    }
    
    
    @IBAction func addNewButtonPressed(_ sender: Any) {
        //temporary test values to be removed
//        let newToDoItem = Chore(context: self.context)
//        newToDoItem.ch_title = "Feed Rizhik"
//        newToDoItem.sh_suspended = false
//        newToDoItem.ch_choreId = 1235
//        choresArray.append(newToDoItem)
        //temporary test values to be removed
        

        choresTable.reloadData()
        saveItems()
        loadItems()
    }
    
    
    //MARK:  SEGUE FUNCTIONS
     override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        print("called prepare for segue")
        print(choreTitleToPass)
        let destinationVC = segue.destination as! ChoreDetailsController
        destinationVC.choreTitlePassOver = choreTitleToPass
        destinationVC.backscreen = self
    }
    
    func dataReceived(data: String) {
        print("Data received back: \(data)")
        choreTitlePassedBack = data
        saveItems()
        loadItems()
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
    }
    
    func deleteItems(rowNumber: Int) {
        context.delete(self.choresArray[rowNumber])
        choresArray.remove(at: rowNumber)
    }
    
    

    
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

