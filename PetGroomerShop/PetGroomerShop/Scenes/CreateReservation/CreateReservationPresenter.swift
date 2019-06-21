//
//  CreateReservationPresenter.swift
//  PetGroomerShop
//
//  Created by Lee, Jeongsik on 2019/06/20.
//  Copyright (c) 2019 Lee, Jeongsik. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol CreateReservationPresentationLogic
{
    func presentCreatedReservation(response: CreateReservation.CreateReservation.Response)
    func presentReservationToEdit(response: CreateReservation.EditReservation.Response)
    func presentUpdatedReservation(response: CreateReservation.UpdateReservation.Response)
}

class CreateReservationPresenter: CreateReservationPresentationLogic
{
    weak var viewController: CreateReservationDisplayLogic?
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    // MARK: - Create reservation
    
    func presentCreatedReservation(response: CreateReservation.CreateReservation.Response)
    {
        let viewModel = CreateReservation.CreateReservation.ViewModel(reservation: response.reservation)
        viewController?.displayCreatedReservation(viewModel: viewModel)
    }
    
    // MARK: - Edit reservation
    
    func presentReservationToEdit(response: CreateReservation.EditReservation.Response)
    {
        let reservationToEdit = response.reservation
        let viewModel = CreateReservation.EditReservation.ViewModel (
            reservationFormFields: CreateReservation.ReservationFormFields (
                petName: reservationToEdit.petName,
                petSpecies: reservationToEdit.petSpecies,
                ownerName: reservationToEdit.ownerName,
                ownerPhone: reservationToEdit.ownerPhone,
                groomerName: reservationToEdit.groomerName,
                groomTime: reservationToEdit.groomTime,
                id: reservationToEdit.id
            )
        )
        viewController?.displayReservationToEdit(viewModel: viewModel)
    }
    
    // MARK: - Update reservation
    
    func presentUpdatedReservation(response: CreateReservation.UpdateReservation.Response)
    {
        let viewModel = CreateReservation.UpdateReservation.ViewModel(reservation: response.reservation)
        viewController?.displayUpdatedReservation(viewModel: viewModel)
    }
}
