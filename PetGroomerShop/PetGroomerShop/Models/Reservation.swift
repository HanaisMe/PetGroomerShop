//
//  Reservation.swift
//  PetGroomerShop
//
//  Created by Lee, Jeongsik on 2019/06/20.
//  Copyright © 2019 Lee, Jeongsik. All rights reserved.
//

import Foundation

struct Reservation: Equatable
{
    // MARK: Pet Info
    var petName: String
    var petSpecies: String
    
    // MARK: Pet Owner Info
    var ownerName: String
    var ownerPhone: String
    
    // MARK: Grooming Info
    var groomerName: String
    var groomTime: Date
    
    // MARK: Misc
    var id: String?
}

func ==(lhs: Reservation, rhs: Reservation) -> Bool
{
    return lhs.petName == rhs.petName
        && lhs.petSpecies == rhs.petSpecies
        && lhs.ownerName == rhs.ownerName
        && lhs.ownerPhone == rhs.ownerPhone
        && lhs.groomerName == rhs.groomerName
        && lhs.groomTime == rhs.groomTime
        && lhs.id == rhs.id
}
