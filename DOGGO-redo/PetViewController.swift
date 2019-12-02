//
//  ViewController.swift
//  DOGGO-redo
//
//  Created by Michelle Natasha on 11/6/19.
//  Copyright © 2019 Michelle Natasha. All rights reserved.
//

import UIKit
import os.log
import CoreBluetooth
import CoreLocation

class PetViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: properties
    var locationManager: CLLocationManager?
    var newPet: Pet?
    
    //MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var ownerTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneNumTextField: UITextField!
    @IBOutlet weak var distanceReading: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    /*
     This value is either passed by `MealTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new meal.
     */
   
    
    //MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddPetMode = presentingViewController is UINavigationController
        
        if isPresentingInAddPetMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The PetViewController is not inside a navigation controller.")
        }
    }
    
    
    // This method lets you configure a view controller before it's presented.
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let photo = photoImage.image
        let status = 0//Int(statusLabel.text ?? "0")
        let owner = ownerTextField.text ?? ""
        let address = addressTextField.text ?? ""
        let number = phoneNumTextField.text ?? ""
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        newPet = Pet(name: name, photo: photo, status: status, owner: owner, address: address, num: number)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        ownerTextField.delegate = self
        addressTextField.delegate = self
        phoneNumTextField.delegate = self
        
        //Request Location Access
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        // Set up views if editing an existing Pet.
        if let pet = newPet {
            navigationItem.title = pet.petname
            nameTextField.text   = pet.petname
            photoImage.image = pet.petphoto
            if pet.petstatus == 0 {
                statusLabel.text = "Status       : IDLE"
            }
            else {
                statusLabel.text = "Status       : Connected"
            }
            ownerTextField.text = pet.petowner
            addressTextField.text = pet.petaddress
            phoneNumTextField.text = pet.ownernumber
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }

    //MARK: actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: Bluetooth pairing
    
    @IBAction func button(_ sender: UIButton) {
        let url = URL(string: "App-Prefs:root=Bluetooth") //for bluetooth setting
        let app = UIApplication.shared
        app.open(url!, options: [:], completionHandler: nil)
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        //MARK: problem??
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoImage.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }

//MARK: - Location Functions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for:
                CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                    startScanning()
                }
                
            }
        }
    }
    
    func startScanning() {
        //let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let uuid = UUID(uuidString: "DC1DDFE3-5801-4C69-B587-8BC388326425")!//Generated from terminal running uuidgen
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 0, minor: 0, identifier: "DOGGO_Beacon")
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    
//    func update(distance: CLProximity) { UIView.animate(withDuration: 1) {
//        switch distance {
//            case .unknown:
//                self.view.backgroundColor = UIColor.gray
//                self.distanceReading.text = "UNKNOWN"
//            case .far:
//                self.view.backgroundColor = UIColor.blue
//                self.distanceReading.text = "FAR"
//            case .near:
//                self.view.backgroundColor = UIColor.orange
//                self.distanceReading.text = "NEAR"
//            case .immediate:
//                self.view.backgroundColor = UIColor.red
//                self.distanceReading.text = "RIGHT HERE"
//            }
//        }
//    }
    func update(distance: CLProximity) { UIView.animate(withDuration: 2) {
        switch distance {
            case .far:
                //self.view.backgroundColor = UIColor.blue
                self.distanceReading.text = "FAR"
            case .near:
                //self.view.backgroundColor = UIColor.orange
                self.distanceReading.text = "NEAR"
            case .immediate:
                //self.view.backgroundColor = UIColor.red
                self.distanceReading.text = "RIGHT HERE"
            
            default:
                //self.view.backgroundColor = UIColor.gray
                self.distanceReading.text = "LOCATING..."
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }
    
}


