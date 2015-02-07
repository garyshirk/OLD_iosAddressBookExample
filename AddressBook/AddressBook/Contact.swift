//
//  Contact.swift
//  AddressBook
//
//  Created by Gary Shirk on 2/7/15.
//  Copyright (c) 2015 garyshirk. All rights reserved.
//

import Foundation
import CoreData

class Contact: NSManagedObject {

    @NSManaged var firstname: String
    @NSManaged var email: String?
    @NSManaged var lastname: String
    @NSManaged var phone: String?
    @NSManaged var street: String?
    @NSManaged var city: String?
    @NSManaged var state: String?
    @NSManaged var zip: String?

}
