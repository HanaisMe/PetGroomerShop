//
//  ListReservationsPresenter.swift
//  PetGroomerShop
//
//  Created by Lee, Jeongsik on 2019/06/21.
//  Copyright (c) 2019 Lee, Jeongsik. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol ListReservationsPresentationLogic
{
    func presentFetchedReservations(response: ListReservations.FetchReservations.Response)
}

class ListReservationsPresenter: ListReservationsPresentationLogic
{
    weak var viewController: ListReservationsDisplayLogic?
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    // MARK: - Fetch orders
    
    func presentFetchedReservations(response: ListReservations.FetchReservations.Response)
    {
        var displayedReservations: [ListReservations.FetchReservations.ViewModel.DisplayedReservation] = []
        for reservation in response.reservations {
            let date = dateFormatter.string(from: reservation.groomTime)
            let displayedReservation = ListReservations.FetchReservations.ViewModel.DisplayedReservation(petName: reservation.petName, groomTime: date)
            displayedReservations.append(displayedReservation)
        }
        let viewModel = ListReservations.FetchReservations.ViewModel(displayedReservations: displayedReservations)
        viewController?.displayFetchedReservations(viewModel: viewModel)
    }
    
}
