//
//  Pet.swift
//  DOGGO-redo
//
//  Created by Michelle Natasha on 11/6/19.
//  Copyright © 2019 Michelle Natasha. All rights reserved.
//

import Foundation
import UIKit
import os.log

class Pet: NSObject, NSCoding {
    
    //MARK: Properties
    var petname: String = ""
    var petphoto: UIImage?
    var petstatus: Int = 0
    var petowner: String = ""
    var petaddress: String = ""
    var ownernumber: String = ""

    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("pets")
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let status = "status"
        static let owner = "owner"
        static let address = "address"
        static let number = "number"
    }
    
    //MARK: Initialization
     
    init?(name: String, photo: UIImage?, status: Int, owner: String, address: String, num: String) {
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        guard !owner.isEmpty else {
            return nil
        }
        
        guard !address.isEmpty else {
            return nil
        }
        
        let checkNum:Int? = Int(num) // if phone num is number, checkNum==nil if not numbers
        guard (!num.isEmpty) && (checkNum != nil ) else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively
        guard (status >= 0) && (status <= 1) else {
            return nil
        }
        
        // Initialize stored properties.
        self.petname = name
        self.petphoto = photo
        self.petstatus = status
        self.petowner = owner
        self.petaddress = address
        self.ownernumber = num
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(petname, forKey: PropertyKey.name)
        aCoder.encode(petphoto, forKey: PropertyKey.photo)
        aCoder.encode(petstatus, forKey: PropertyKey.status)
        aCoder.encode(petowner, forKey: PropertyKey.owner)
        aCoder.encode(petaddress, forKey: PropertyKey.address)
        aCoder.encode(ownernumber, forKey: PropertyKey.number)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Pet object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let owner = aDecoder.decodeObject(forKey: PropertyKey.owner) as? String else {
            os_log("Unable to decode the name for a Pet object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let address = aDecoder.decodeObject(forKey: PropertyKey.address) as? String else {
            os_log("Unable to decode the name for a Pet object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let number = aDecoder.decodeObject(forKey: PropertyKey.number) as? String else {
            os_log("Unable to decode the name for a Pet object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        let status = aDecoder.decodeInteger(forKey: PropertyKey.status)
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, status: status, owner: owner, address: address, num: number)
        
    }
}
