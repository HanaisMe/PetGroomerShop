//
//  ShowReservationViewController.swift
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

protocol ShowReservationDisplayLogic: class
{
    func displayReservation(viewModel: ShowReservation.GetReservation.ViewModel)
}

class ShowReservationViewController: UIViewController, ShowReservationDisplayLogic
{
    var interactor: ShowReservationBusinessLogic?
    var router: (NSObjectProtocol & ShowReservationRoutingLogic & ShowReservationDataPassing)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = ShowReservationInteractor()
        let presenter = ShowReservationPresenter()
        let router = ShowReservationRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getReservation()
    }
    
    // MARK: - Get reservation
    
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var groomTimeLabel: UILabel!
    
    func getReservation() {
        let request = ShowReservation.GetReservation.Request()
        interactor?.getReservation(request: request)
    }
    
    func displayReservation(viewModel: ShowReservation.GetReservation.ViewModel)
    {
        let displayedReservation = viewModel.displayedReservation
        petNameLabel.text = displayedReservation.petName
        groomTimeLabel.text = displayedReservation.groomTime
    }
}