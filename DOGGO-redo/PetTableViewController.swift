//
//  PetTableViewController.swift
//  DOGGO-redo
//
//  Created by Michelle Natasha on 11/6/19.
//  Copyright © 2019 Michelle Natasha. All rights reserved.
//

import UIKit
import os.log

class PetTableViewController: UITableViewController {

    //MARK: Properties
     
    var pets = [Pet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved meals, otherwise load sample data.
        if let savedPets = loadPets() {
            pets += savedPets
        }
        else {
            // Load the sample data.
            loadSamplePets()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pets.count
    }

    //MARK: Actions
    @IBAction func unwindToPetList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? PetViewController, let pet = sourceViewController.newPet {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing pet.
                pets[selectedIndexPath.row] = pet
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
            // Add a new meal.
            let newIndexPath = IndexPath(row: pets.count, section: 0)
            
            pets.append(pet)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            // Save the pets.
            savePets()
        }
    }
    //MARK: Private Methods
     private func savePets() {
         let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(pets, toFile: Pet.ArchiveURL.path)
         if isSuccessfulSave {
             os_log("Pets successfully saved.", log: OSLog.default, type: .debug)
         } else {
             os_log("Failed to save pets...", log: OSLog.default, type: .error)
         }
     }
    
    private func loadSamplePets() {
        let photo1 = UIImage(named: "bear")
        let photo2 = UIImage(named: "bulldog")
        let photo3 = UIImage(named: "golden")
        
        guard let pet1 = Pet(name: "Polar", photo: photo1, status: 0, owner: "human1", address: "home", num: "123") else {
            fatalError("Unable to instantiate pet1")
        }
        
        guard let pet2 = Pet(name: "Doggy", photo: photo2, status: 1, owner: "human2", address: "apt", num: "345") else {
            fatalError("Unable to instantiate pet2")
        }
        
        guard let pet3 = Pet(name: "Cutie", photo: photo3, status: 0, owner: "human3", address: "work", num: "890") else {
            fatalError("Unable to instantiate pet3")
        }
        
        pets += [pet1, pet2, pet3]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PetTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PetTableViewCell  else {
            fatalError("The dequeued cell is not an instance of PetTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let p = pets[indexPath.row]
        
        cell.nameLabel?.text = p.petname
        cell.photoImageView?.image = p.petphoto
        if p.petstatus == 0 {
            cell.statusLabel?.text = "IDLE"
        }
        else {
            cell.statusLabel?.text = "Connected"
        }
//        cell.statusLabel?.text = String(p.petstatus)
        
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            pets.remove(at: indexPath.row)
            savePets()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddPet":
            os_log("Adding a new pet.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let petDetailViewController = segue.destination as? PetViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedPetCell = sender as? PetTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedPetCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedPet = pets[indexPath.row]
            petDetailViewController.newPet = selectedPet
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }

    private func loadPets() -> [Pet]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Pet.ArchiveURL.path) as? [Pet]
    }
}
