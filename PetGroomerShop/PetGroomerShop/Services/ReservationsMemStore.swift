//
//  ReservationsMemStore.swift
//  PetGroomerShop
//
//  Created by Lee, Jeongsik on 2019/06/20.
//  Copyright © 2019 Lee, Jeongsik. All rights reserved.
//

import Foundation

class ReservationsMemStore: ReservationsStoreProtocol, ReservationsStoreUtilityProtocol
{
    // MARK: - Data
    
    static var reservations = [
        Reservation.init(petName: "Choco", petSpecies: "dog", ownerName: "Hana", ownerPhone: "070-1111-1111", groomerName: "Hasami", groomTime: Date(), id: "happyDay123"),
        Reservation.init(petName: "Mint", petSpecies: "hedgehog", ownerName: "Dul", ownerPhone: "070-2222-2222", groomerName: "KamaKiri", groomTime: Date(), id: "niceDay555")
    ]
    
    // MARK: - CRUD operations - Optional error
    
    func fetchReservations(completionHandler: @escaping ([Reservation], ReservationsStoreError?) -> Void)
    {
        completionHandler(type(of: self).reservations, nil)
    }
    
    func fetchReservation(id: String, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    {
        if let index = indexOfReservationWithID(id: id) {
            let reservation = type(of: self).reservations[index]
            completionHandler(reservation, nil)
        } else {
            completionHandler(nil, ReservationsStoreError.CannotFetch("Cannot fetch reservation with id \(id)"))
        }
    }
    
    func createReservation(reservationToCreate: Reservation, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    {
        var reservation = reservationToCreate
        generateReservationID(reservation: &reservation)
        type(of: self).reservations.append(reservation)
        completionHandler(reservation, nil)
    }
    
    func updateReservation(reservationToUpdate: Reservation, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    {
        if let index = indexOfReservationWithID(id: reservationToUpdate.id) {
            type(of: self).reservations[index] = reservationToUpdate
            let reservation = type(of: self).reservations[index]
            completionHandler(reservation, nil)
        } else {
            completionHandler(nil, ReservationsStoreError.CannotUpdate("Cannot fetch Reservation with id \(String(describing: reservationToUpdate.id)) to update"))
        }
    }
    
    func deleteReservation(id: String, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    {
        if let index = indexOfReservationWithID(id: id) {
            let reservation = type(of: self).reservations.remove(at: index)
            completionHandler(reservation, nil)
            return
        }
        completionHandler(nil, ReservationsStoreError.CannotDelete("Cannot fetch Reservation with id \(id) to delete"))
    }
    
    // MARK: - CRUD operations - Generic enum result type
    
    func fetchReservations(completionHandler: @escaping ReservationsStoreFetchReservationsCompletionHandler)
    {
        completionHandler(ReservationsStoreResult.Success(result: type(of: self).reservations))
    }
    
    func fetchReservation(id: String, completionHandler: @escaping ReservationsStoreFetchReservationCompletionHandler)
    {
        let reservation = type(of: self).reservations.filter { (reservation: Reservation) -> Bool in
            return reservation.id == id
            }.first
        if let reservation = reservation {
            completionHandler(ReservationsStoreResult.Success(result: reservation))
        } else {
            completionHandler(ReservationsStoreResult.Failure(error: ReservationsStoreError.CannotFetch("Cannot fetch reservation with id \(id)")))
        }
    }
    
    func createReservation(reservationToCreate: Reservation, completionHandler: @escaping ReservationsStoreCreateReservationCompletionHandler)
    {
        var reservation = reservationToCreate
        generateReservationID(reservation: &reservation)
        type(of: self).reservations.append(reservation)
        completionHandler(ReservationsStoreResult.Success(result: reservation))
    }
    
    func updateReservation(reservationToUpdate: Reservation, completionHandler: @escaping ReservationsStoreUpdateReservationCompletionHandler)
    {
        if let index = indexOfReservationWithID(id: reservationToUpdate.id) {
            type(of: self).reservations[index] = reservationToUpdate
            let reservation = type(of: self).reservations[index]
            completionHandler(ReservationsStoreResult.Success(result: reservation))
        } else {
            completionHandler(ReservationsStoreResult.Failure(error: ReservationsStoreError.CannotUpdate("Cannot update Reservation with id \(String(describing: reservationToUpdate.id)) to update")))
        }
    }
    
    func deleteReservation(id: String, completionHandler: @escaping ReservationsStoreDeleteReservationCompletionHandler)
    {
        if let index = indexOfReservationWithID(id: id) {
            let reservation = type(of: self).reservations.remove(at: index)
            completionHandler(ReservationsStoreResult.Success(result: reservation))
            return
        }
        completionHandler(ReservationsStoreResult.Failure(error: ReservationsStoreError.CannotDelete("Cannot delete Reservation with id \(id) to delete")))
    }
    
    // MARK: - CRUD operations - Inner closure
    
    func fetchReservations(completionHandler: @escaping (() throws -> [Reservation]) -> Void)
    {
        completionHandler { return type(of: self).reservations }
    }
    
    func fetchReservation(id: String, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    {
        if let index = indexOfReservationWithID(id: id) {
            completionHandler { return type(of: self).reservations[index] }
        } else {
            completionHandler { throw ReservationsStoreError.CannotFetch("Cannot fetch Reservation with id \(id)") }
        }
    }
    
    func createReservation(reservationToCreate: Reservation, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    {
        var reservation = reservationToCreate
        generateReservationID(reservation: &reservation)
        type(of: self).reservations.append(reservation)
        completionHandler { return reservation }
    }
    
    func updateReservation(reservationToUpdate: Reservation, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    {
        if let index = indexOfReservationWithID(id: reservationToUpdate.id) {
            type(of: self).reservations[index] = reservationToUpdate
            let reservation = type(of: self).reservations[index]
            completionHandler { return reservation }
        } else {
            completionHandler { throw ReservationsStoreError.CannotUpdate("Cannot fetch Reservation with id \(String(describing: reservationToUpdate.id)) to update") }
        }
    }
    
    func deleteReservation(id: String, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    {
        if let index = indexOfReservationWithID(id: id) {
            let reservation = type(of: self).reservations.remove(at: index)
            completionHandler { return reservation }
        } else {
            completionHandler { throw ReservationsStoreError.CannotDelete("Cannot fetch Reservation with id \(id) to delete") }
        }
    }
    
    // MARK: - Convenience methods
    
    private func indexOfReservationWithID(id: String?) -> Int?
    {
        return type(of: self).reservations.firstIndex { return $0.id == id }
    }
}
