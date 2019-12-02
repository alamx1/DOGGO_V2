//
//  BluetoothTableViewController.swift
//  DOGGO-redo
//
//  Created by Michelle Natasha on 11/19/19.
//  Copyright © 2019 Michelle Natasha. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

// MARK: - Core Bluetooth service IDs
let BLE_UART_Service_CBUUID = CBUUID(string: kBLEService_UUID)
//let BLE_Battery_Service_CBUUID = CBUUID(string: "0x")

// MARK: - Core Bluetooth characteristic IDs
//let BLE_Battery_Characteristic_CBUUID = CBUUID(string: "0x")
let BLE_UART_Characteristic_CBUUID_TX = kBLE_Characteristic_uuid_Tx
let BLE_UART_Characteristic_CBUUID_RX = kBLE_Characteristic_uuid_Rx

class BluetoothTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate, CLLocationManagerDelegate {
    

    //MARK: - Class Variables
    var locationManager: CLLocationManager?
    var centralManager: CBCentralManager?
    var peripheralHeartRateMonitor: CBPeripheral?
    
    // MARK: - UI outlets / member variables
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    //MARK: - Bluetooth Functions
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
            case .unknown:
                print("Bluetooth status is UNKNOWN")
                //bluetoothOffLabel.alpha = 1.0
            case .resetting:
                print("Bluetooth status is RESETTING")
                //bluetoothOffLabel.alpha = 1.0
            case .unsupported:
                print("Bluetooth status is UNSUPPORTED")
                //bluetoothOffLabel.alpha = 1.0
            case .unauthorized:
                print("Bluetooth status is UNAUTHORIZED")
                //bluetoothOffLabel.alpha = 1.0
            case .poweredOff:
                print("Bluetooth status is POWERED OFF")
                //bluetoothOffLabel.alpha = 1.0
            case .poweredOn:
                print("Bluetooth status is POWERED ON")
                
//                DispatchQueue.main.async { () -> Void in
//                    self.bluetoothOffLabel.alpha = 0.0
//                    self.connectingActivityIndicator.startAnimating()
//                }
                
                // STEP 3.2: scan for peripherals that we're interested in
                centralManager?.scanForPeripherals(withServices: [BLE_UART_Service_CBUUID])
                
            } // END switch
            
        } // END func centralManagerDidUpdateState
    
    //MARK: - Location Functions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for:
                CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
                
            }
        }
        
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
