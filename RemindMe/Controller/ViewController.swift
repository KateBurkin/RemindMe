//
//  ViewController.swift
//  RemindMe
//
//  Created by Kate on 21/2/19.
//  Copyright © 2019 Kate Guru. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var choresTable: UITableView!
    
    var choresArray = [Chore]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Chore.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        choresTable.delegate = self
        choresTable.dataSource = self
        
        // load up the array from user preferences (if we stored something in the file)
        choresTable.rowHeight = 50.0
        loadItems()
        print (dataFilePath)
        choresTable.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print (choresArray.count)
        return choresArray.count

    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = choresTable.dequeueReusableCell(withIdentifier: "choreItemCell", for: indexPath)
        cell.textLabel?.text = choresArray[indexPath.row].title
        print (choresArray[indexPath.row].title)
        
        //Ternary Operator ==>
        //value = condition ? valueIfTrue : valueIfFalse
        //cell.accessoryType = choresArray[indexPath.row].done ? .checkmark : .none
        //self.saveItems()
        return cell
    }
    

    
    @IBAction func addNewButtonPressed(_ sender: Any) {
        
        let newToDoItem = Chore(context: self.context)
        newToDoItem.title = "Feed Rizhik"
        newToDoItem.suspended = false
        newToDoItem.choreId = 1235
        choresArray.append(newToDoItem)
        choresTable.reloadData()
        saveItems()
        loadItems()
        
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
    
    
    
    
    //MARK - Model Manipulation Methods
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

}

