//
//  ReservationsWorker.swift
//  PetGroomerShop
//
//  Created by Lee, Jeongsik on 2019/06/20.
//  Copyright © 2019 Lee, Jeongsik. All rights reserved.
//

import Foundation

class ReservationsWorker
{
    var reservationsStore: ReservationsStoreProtocol
    
    init(reservationsStore: ReservationsStoreProtocol)
    {
        self.reservationsStore = reservationsStore
    }
    
    func fetchReservations(completionHandler: @escaping ([Reservation]) -> Void)
    {
        reservationsStore.fetchReservations { (reservations: () throws -> [Reservation]) -> Void in
            do {
                let reservations = try reservations()
                DispatchQueue.main.async {
                    completionHandler(reservations)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler([])
                }
            }
        }
    }
    
    func createReservation(reservationToCreate: Reservation, completionHandler: @escaping (Reservation?) -> Void)
    {
        reservationsStore.createReservation(reservationToCreate: reservationToCreate) { (reservation: () throws -> Reservation?) -> Void in
            do {
                let reservation = try reservation()
                DispatchQueue.main.async {
                    completionHandler(reservation)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            }
        }
    }
    
    func updateReservation(reservationToUpdate: Reservation, completionHandler: @escaping (Reservation?) -> Void)
    {
        reservationsStore.updateReservation(reservationToUpdate: reservationToUpdate) { (reservation: () throws -> Reservation?) in
            do {
                let reservation = try reservation()
                DispatchQueue.main.async {
                    completionHandler(reservation)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            }
        }
    }
}

// MARK: - Reservations store API

protocol ReservationsStoreProtocol
{
    // MARK: CRUD operations - Optional error
    
    func fetchReservations(completionHandler: @escaping ([Reservation], ReservationsStoreError?) -> Void)
    func fetchReservation(id: String, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    func createReservation(reservationToCreate: Reservation, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    func updateReservation(reservationToUpdate: Reservation, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    func deleteReservation(id: String, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    
    // MARK: CRUD operations - Generic enum result type
    
    func fetchReservations(completionHandler: @escaping ReservationsStoreFetchReservationsCompletionHandler)
    func fetchReservation(id: String, completionHandler: @escaping ReservationsStoreFetchReservationCompletionHandler)
    func createReservation(reservationToCreate: Reservation, completionHandler: @escaping ReservationsStoreCreateReservationCompletionHandler)
    func updateReservation(reservationToUpdate: Reservation, completionHandler: @escaping ReservationsStoreUpdateReservationCompletionHandler)
    func deleteReservation(id: String, completionHandler: @escaping ReservationsStoreDeleteReservationCompletionHandler)
    
    // MARK: CRUD operations - Inner closure
    
    func fetchReservations(completionHandler: @escaping (() throws -> [Reservation]) -> Void)
    func fetchReservation(id: String, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    func createReservation(reservationToCreate: Reservation, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    func updateReservation(reservationToUpdate: Reservation, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    func deleteReservation(id: String, completionHandler: @escaping (() throws -> Reservation?) -> Void)
}

protocol ReservationsStoreUtilityProtocol {}

extension ReservationsStoreUtilityProtocol
{
    func generateReservationID(reservation: inout Reservation)
    {
        guard reservation.id == nil else { return }
        reservation.id = "\(arc4random())"
    }
    
}

// MARK: - Reservations store CRUD operation results

typealias ReservationsStoreFetchReservationsCompletionHandler = (ReservationsStoreResult<[Reservation]>) -> Void
typealias ReservationsStoreFetchReservationCompletionHandler = (ReservationsStoreResult<Reservation>) -> Void
typealias ReservationsStoreCreateReservationCompletionHandler = (ReservationsStoreResult<Reservation>) -> Void
typealias ReservationsStoreUpdateReservationCompletionHandler = (ReservationsStoreResult<Reservation>) -> Void
typealias ReservationsStoreDeleteReservationCompletionHandler = (ReservationsStoreResult<Reservation>) -> Void

enum ReservationsStoreResult<U>
{
    case Success(result: U)
    case Failure(error: ReservationsStoreError)
}

// MARK: - Reservations store CRUD operation errors

enum ReservationsStoreError: Equatable, Error
{
    case CannotFetch(String)
    case CannotCreate(String)
    case CannotUpdate(String)
    case CannotDelete(String)
}

func ==(lhs: ReservationsStoreError, rhs: ReservationsStoreError) -> Bool
{
    switch (lhs, rhs) {
    case (.CannotFetch(let a), .CannotFetch(let b)) where a == b: return true
    case (.CannotCreate(let a), .CannotCreate(let b)) where a == b: return true
    case (.CannotUpdate(let a), .CannotUpdate(let b)) where a == b: return true
    case (.CannotDelete(let a), .CannotDelete(let b)) where a == b: return true
    default: return false
    }
}
