//
//  ManagedReservation+CoreDataClass.swift
//  PetGroomerShop
//
//  Created by Lee, Jeongsik on 2019/06/20.
//  Copyright © 2019 Lee, Jeongsik. All rights reserved.
//

import Foundation
import CoreData

public class ManagedReservation: NSManagedObject {
    
    func toReservation() -> Reservation
    {
        return Reservation.init(petName: petName!, petSpecies: petSpecies!, ownerName: ownerName!, ownerPhone: ownerPhone!, groomerName: groomerName!, groomTime: groomTime!, id: id!)
    }
    
    func fromReservation(reservation: Reservation)
    {
        petName = reservation.petName
        petSpecies = reservation.petSpecies
        ownerName = reservation.ownerName
        ownerPhone = reservation.ownerPhone
        groomerName = reservation.groomerName
        groomTime = reservation.groomTime
        id = reservation.id
    }
    
}
