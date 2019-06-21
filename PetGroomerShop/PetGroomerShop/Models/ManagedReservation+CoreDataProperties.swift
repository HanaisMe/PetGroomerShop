//
//  ManagedReservation+CoreDataProperties.swift
//  PetGroomerShop
//
//  Created by Lee, Jeongsik on 2019/06/20.
//  Copyright © 2019 Lee, Jeongsik. All rights reserved.
//

import Foundation
import CoreData

extension ManagedReservation
{
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedReservation>
    {
        return NSFetchRequest<ManagedReservation>(entityName: "ManagedReservation")
    }
    
    @NSManaged public var petName: String?
    @NSManaged public var petSpecies: String?
    @NSManaged public var ownerName: String?
    @NSManaged public var ownerPhone: String?
    @NSManaged public var groomerName: String?
    @NSManaged public var groomTime: Date?
    @NSManaged public var id: String?
}
