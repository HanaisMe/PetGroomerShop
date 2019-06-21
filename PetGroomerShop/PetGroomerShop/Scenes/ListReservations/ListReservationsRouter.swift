//
//  ListReservationsRouter.swift
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

@objc protocol ListReservationsRoutingLogic
{
    func routeToCreateReservation(segue: UIStoryboardSegue?)
    func routeToShowReservation(segue: UIStoryboardSegue?)
}

protocol ListReservationsDataPassing
{
    var dataStore: ListReservationsDataStore? { get }
}

class ListReservationsRouter: NSObject, ListReservationsRoutingLogic, ListReservationsDataPassing
{
    weak var viewController: ListReservationsViewController?
    var dataStore: ListReservationsDataStore?
    
    // MARK: Routing
    
    func routeToCreateReservation(segue: UIStoryboardSegue?)
    {
        if let segue = segue {
            let destinationVC = segue.destination as! CreateReservationViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToCreateReservation(source: dataStore!, destination: &destinationDS)
        } else {
            let destinationVC = viewController?.storyboard?.instantiateViewController(withIdentifier: "CreateReservationVC") as! CreateReservationViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToCreateReservation(source: dataStore!, destination: &destinationDS)
            navigateToCreateReservation(source: viewController!, destination: destinationVC)
        }
    }
    
    func routeToShowReservation(segue: UIStoryboardSegue?)
    {
        if let segue = segue {
            let destinationVC = segue.destination as! ShowReservationViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToShowReservation(source: dataStore!, destination: &destinationDS)
        } else {
            let destinationVC = viewController?.storyboard?.instantiateViewController(withIdentifier: "ShowReservationViewController") as! ShowReservationViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToShowReservation(source: dataStore!, destination: &destinationDS)
            navigateToShowReservation(source: viewController!, destination: destinationVC)
        }
    }
    
    // MARK: Navigation
    
    func navigateToCreateReservation(source: ListReservationsViewController, destination: CreateReservationViewController)
    {
        source.show(destination, sender: nil)
    }
    
    func navigateToShowReservation(source: ListReservationsViewController, destination: ShowReservationViewController)
    {
        source.show(destination, sender: nil)
    }
    
    // MARK: Passing data
    
    func passDataToCreateReservation(source: ListReservationsDataStore, destination: inout CreateReservationDataStore)
    {
    }
    
    func passDataToShowReservation(source: ListReservationsDataStore, destination: inout ShowReservationDataStore)
    {
        let selectedRow = viewController?.tableView.indexPathForSelectedRow?.row
        destination.reservation = source.reservations?[selectedRow!]
    }
    
}