//
//  ReservationsAPI.swift
//  PetGroomerShop
//
//  Created by Lee, Jeongsik on 2019/06/20.
//  Copyright © 2019 Lee, Jeongsik. All rights reserved.
//

import Foundation

class ReservationsAPI: ReservationsStoreProtocol, ReservationsStoreUtilityProtocol
{
    // MARK: - CRUD operations - Optional error
    
    func fetchReservations(completionHandler: @escaping ([Reservation], ReservationsStoreError?) -> Void)
    {
    }
    
    func fetchReservation(id: String, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    {
    }
    
    func createReservation(reservationToCreate: Reservation, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    {
    }
    
    func updateReservation(reservationToUpdate: Reservation, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    {
    }
    
    func deleteReservation(id: String, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    {
    }
    
    // MARK: - CRUD operations - Generic enum result type
    
    func fetchReservations(completionHandler: @escaping ReservationsStoreFetchReservationsCompletionHandler)
    {
    }
    
    func fetchReservation(id: String, completionHandler: @escaping ReservationsStoreFetchReservationCompletionHandler)
    {
    }
    
    func createReservation(reservationToCreate: Reservation, completionHandler: @escaping ReservationsStoreCreateReservationCompletionHandler)
    {
    }
    
    func updateReservation(reservationToUpdate: Reservation, completionHandler: @escaping ReservationsStoreUpdateReservationCompletionHandler)
    {
    }
    
    func deleteReservation(id: String, completionHandler: @escaping ReservationsStoreDeleteReservationCompletionHandler)
    {
    }
    
    // MARK: - CRUD operations - Inner closure
    
    func fetchReservations(completionHandler: @escaping (() throws -> [Reservation]) -> Void)
    {
    }
    
    func fetchReservation(id: String, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    {
    }
    
    func createReservation(reservationToCreate: Reservation, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    {
    }
    
    func updateReservation(reservationToUpdate: Reservation, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    {
    }
    
    func deleteReservation(id: String, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    {
    }
}
