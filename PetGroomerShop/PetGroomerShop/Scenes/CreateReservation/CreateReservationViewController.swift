//
//  CreateReservationViewController.swift
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

protocol CreateReservationDisplayLogic: class
{
    func displayCreatedReservation(viewModel: CreateReservation.CreateReservation.ViewModel)
    func displayReservationToEdit(viewModel: CreateReservation.EditReservation.ViewModel)
    func displayUpdatedReservation(viewModel: CreateReservation.UpdateReservation.ViewModel)
}

class CreateReservationViewController: UITableViewController, CreateReservationDisplayLogic
{
    var interactor: CreateReservationBusinessLogic?
    var router: (NSObjectProtocol & CreateReservationRoutingLogic & CreateReservationDataPassing)?
    
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
        let interactor = CreateReservationInteractor()
        let presenter = CreateReservationPresenter()
        let router = CreateReservationRouter()
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setTextFieldAccessory()
        showReservationToEdit()
    }
    
    let groomTimeDatePicker = UIDatePicker.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.height * 0.4, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.4))
    
    func setTextFieldAccessory() {
        groomTimeDatePicker.datePickerMode = .date
        groomTimeDatePicker.backgroundColor = UIColor.white
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneDatePicker))
        let spaceLeftButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        spaceLeftButton.isEnabled = false
        let titleButton = UIBarButtonItem(title: "Choose a Date", style: .plain, target: self, action: nil)
        titleButton.isEnabled = false
        let spaceRightButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        spaceRightButton.isEnabled = false
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(self.clearDatePicker))
        toolbar.setItems([clearButton, spaceLeftButton, titleButton, spaceRightButton, doneButton], animated: false)
        groomTimeTextField.inputAccessoryView = toolbar
        groomTimeTextField.inputView = groomTimeDatePicker
    }
    
    @objc func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        groomTimeTextField.text = formatter.string(from: groomTimeDatePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func clearDatePicker() {
        groomTimeTextField.text = nil
        self.view.endEditing(true)
    }
    
    // MARK: Text fields
    
    @IBOutlet var textFields: [UITextField]!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        if let index = textFields.firstIndex(of: textField) {
            if index < textFields.count - 1 {
                let nextTextField = textFields[index + 1]
                nextTextField.becomeFirstResponder()
            }
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let cell = tableView.cellForRow(at: indexPath) {
            for textField in textFields {
                if textField.isDescendant(of: cell) {
                    textField.becomeFirstResponder()
                }
            }
        }
    }
    
    // MARK: - Create reservation
    
    // MARK: Pet info
    @IBOutlet weak var petNameTextField: UITextField!
    @IBOutlet weak var petSpeciesTextField: UITextField!
    
    // MARK: Pet Owner Info
    @IBOutlet weak var ownerNameTextField: UITextField!
    @IBOutlet weak var ownerPhoneTextField: UITextField!
    
    // MARK: Grooming Info
    @IBOutlet weak var groomerNameTextField: UITextField!
    @IBOutlet weak var groomTimeTextField: UITextField!
    
    @IBAction func saveButtonTapped(_ sender: Any)
    {
        let petName = petNameTextField.text!
        let petSpecies = petSpeciesTextField.text!
        let ownerName = ownerNameTextField.text!
        let ownerPhone = ownerPhoneTextField.text!
        let groomerName = groomerNameTextField.text!
        let groomTime = groomTimeDatePicker.date
        
        if let reservationToEdit = interactor?.reservationToEdit {
            let request = CreateReservation.UpdateReservation.Request(reservationFormFields: CreateReservation.ReservationFormFields(petName: petName, petSpecies: petSpecies, ownerName: ownerName, ownerPhone: ownerPhone, groomerName: groomerName, groomTime: groomTime, id: reservationToEdit.id))
            interactor?.updateReservation(request: request)
        } else {
            let request = CreateReservation.CreateReservation.Request(reservationFormFields: CreateReservation.ReservationFormFields(petName: petName, petSpecies: petSpecies, ownerName: ownerName, ownerPhone: ownerPhone, groomerName: groomerName, groomTime: groomTime, id: nil))
            interactor?.createReservation(request: request)
        }
    }
    
    func displayCreatedReservation(viewModel: CreateReservation.CreateReservation.ViewModel)
    {
        if viewModel.reservation != nil {
            router?.routeToListReservations(segue: nil)
        } else {
            showReservationFailureAlert(title: "Failed to create reservation", message: "Please correct your reservation and submit again.")
        }
    }
    
    // MARK: - Edit order
    
    func showReservationToEdit()
    {
        let request = CreateReservation.EditReservation.Request()
        interactor?.showReservationToEdit(request: request)
    }
    
    func displayReservationToEdit(viewModel: CreateReservation.EditReservation.ViewModel)
    {
        let reservationFormFields = viewModel.reservationFormFields
        petNameTextField.text = reservationFormFields.petName
        petSpeciesTextField.text = reservationFormFields.petSpecies
        ownerNameTextField.text = reservationFormFields.ownerName
        ownerPhoneTextField.text = reservationFormFields.ownerPhone
        groomerNameTextField.text = reservationFormFields.groomerName
        groomTimeDatePicker.date = reservationFormFields.groomTime
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        groomTimeTextField.text = formatter.string(from: reservationFormFields.groomTime)
    }
    
    // MARK: - Update reservation
    
    func displayUpdatedReservation(viewModel: CreateReservation.UpdateReservation.ViewModel)
    {
        if viewModel.reservation != nil {
            router?.routeToShowReservation(segue: nil)
        } else {
            showReservationFailureAlert(title: "Failed to update order", message: "Please correct your order and submit again.")
        }
    }
    
    // MARK: Error handling
    
    private func showReservationFailureAlert(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        showDetailViewController(alertController, sender: nil)
    }
    
}
