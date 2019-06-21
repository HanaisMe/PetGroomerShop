//
//  ReservationsCoreDataStore.swift
//  PetGroomerShop
//
//  Created by Lee, Jeongsik on 2019/06/20.
//  Copyright © 2019 Lee, Jeongsik. All rights reserved.
//

import CoreData

class ReservationsCoreDataStore: ReservationsStoreProtocol, ReservationsStoreUtilityProtocol
{
    // MARK: - Managed object contexts
    
    var mainManagedObjectContext: NSManagedObjectContext
    var privateManagedObjectContext: NSManagedObjectContext
    
    // MARK: - Object lifecycle
    
    init()
    {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = Bundle.main.url(forResource: "CleanStore", withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        mainManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainManagedObjectContext.persistentStoreCoordinator = psc
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.appendingPathComponent("CleanStore.sqlite")
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        
        privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = mainManagedObjectContext
    }
    
    deinit
    {
        do {
            try self.mainManagedObjectContext.save()
        } catch {
            fatalError("Error deinitializing main managed object context")
        }
    }
    
    // MARK: - CRUD operations - Optional error
    
    func fetchReservations(completionHandler: @escaping ([Reservation], ReservationsStoreError?) -> Void)
    {
        privateManagedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedReservation")
                let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedReservation]
                let reservations = results.map { $0.toReservation() }
                completionHandler(reservations, nil)
            } catch {
                completionHandler([], ReservationsStoreError.CannotFetch("Cannot fetch reservations"))
            }
        }
    }
    
    func fetchReservation(id: String, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    {
        privateManagedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedReservation")
                fetchRequest.predicate = NSPredicate(format: "id == %@", id)
                let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedReservation]
                if let reservation = results.first?.toReservation() {
                    completionHandler(reservation, nil)
                } else {
                    completionHandler(nil, ReservationsStoreError.CannotFetch("Cannot fetch reservation with id \(id)"))
                }
            } catch {
                completionHandler(nil, ReservationsStoreError.CannotFetch("Cannot fetch reservation with id \(id)"))
            }
        }
    }
    
    func createReservation(reservationToCreate: Reservation, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    {
        privateManagedObjectContext.perform {
            do {
                let managedReservation = NSEntityDescription.insertNewObject(forEntityName: "ManagedReservation", into: self.privateManagedObjectContext) as! ManagedReservation
                var reservation = reservationToCreate
                self.generateReservationID(reservation: &reservation)
                managedReservation.fromReservation(reservation: reservation)
                try self.privateManagedObjectContext.save()
                completionHandler(reservation, nil)
            } catch {
                completionHandler(nil, ReservationsStoreError.CannotCreate("Cannot create reservation with id \(String(describing: reservationToCreate.id))"))
            }
        }
    }
    
    func updateReservation(reservationToUpdate: Reservation, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    {
        privateManagedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedReservation")
                fetchRequest.predicate = NSPredicate(format: "id == %@", reservationToUpdate.id!)
                let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedReservation]
                if let managedReservation = results.first {
                    do {
                        managedReservation.fromReservation(reservation: reservationToUpdate)
                        let reservation = managedReservation.toReservation()
                        try self.privateManagedObjectContext.save()
                        completionHandler(reservation, nil)
                    } catch {
                        completionHandler(nil, ReservationsStoreError.CannotUpdate("Cannot update reservation with id \(String(describing: reservationToUpdate.id))"))
                    }
                }
            } catch {
                completionHandler(nil, ReservationsStoreError.CannotUpdate("Cannot fetch reservation with id \(String(describing: reservationToUpdate.id)) to update"))
            }
        }
    }
    
    func deleteReservation(id: String, completionHandler: @escaping (Reservation?, ReservationsStoreError?) -> Void)
    {
        privateManagedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedReservation")
                fetchRequest.predicate = NSPredicate(format: "id == %@", id)
                let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedReservation]
                if let managedReservation = results.first {
                    let reservation = managedReservation.toReservation()
                    self.privateManagedObjectContext.delete(managedReservation)
                    do {
                        try self.privateManagedObjectContext.save()
                        completionHandler(reservation, nil)
                    } catch {
                        completionHandler(nil, ReservationsStoreError.CannotDelete("Cannot delete reservation with id \(id)"))
                    }
                } else {
                    throw ReservationsStoreError.CannotDelete("Cannot fetch reservation with id \(id) to delete")
                }
            } catch {
                completionHandler(nil, ReservationsStoreError.CannotDelete("Cannot fetch reservation with id \(id) to delete"))
            }
        }
    }
    
    // MARK: - CRUD operations - Generic enum result type
    
    func fetchReservations(completionHandler: @escaping ReservationsStoreFetchReservationsCompletionHandler)
    {
        privateManagedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedReservation")
                let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedReservation]
                let reservations = results.map { $0.toReservation() }
                completionHandler(ReservationsStoreResult.Success(result: reservations))
            } catch {
                completionHandler(ReservationsStoreResult.Failure(error: ReservationsStoreError.CannotFetch("Cannot fetch reservations")))
            }
        }
    }
    
    func fetchReservation(id: String, completionHandler: @escaping ReservationsStoreFetchReservationCompletionHandler)
    {
        privateManagedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedReservation")
                fetchRequest.predicate = NSPredicate(format: "id == %@", id)
                let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedReservation]
                if let reservation = results.first?.toReservation() {
                    completionHandler(ReservationsStoreResult.Success(result: reservation))
                } else {
                    completionHandler(ReservationsStoreResult.Failure(error: ReservationsStoreError.CannotFetch("Cannot fetch reservation with id \(id)")))
                }
            } catch {
                completionHandler(ReservationsStoreResult.Failure(error: ReservationsStoreError.CannotFetch("Cannot fetch reservation with id \(id)")))
            }
        }
    }
    
    func createReservation(reservationToCreate: Reservation, completionHandler: @escaping ReservationsStoreCreateReservationCompletionHandler)
    {
        privateManagedObjectContext.perform {
            do {
                let managedReservation = NSEntityDescription.insertNewObject(forEntityName: "ManagedReservation", into: self.privateManagedObjectContext) as! ManagedReservation
                var reservation = reservationToCreate
                self.generateReservationID(reservation: &reservation)
                managedReservation.fromReservation(reservation: reservation)
                try self.privateManagedObjectContext.save()
                completionHandler(ReservationsStoreResult.Success(result: reservation))
            } catch {
                let error = ReservationsStoreError.CannotCreate("Cannot create reservation with id \(String(describing: reservationToCreate.id))")
                completionHandler(ReservationsStoreResult.Failure(error: error))
            }
        }
    }
    
    func updateReservation(reservationToUpdate: Reservation, completionHandler: @escaping ReservationsStoreUpdateReservationCompletionHandler)
    {
        privateManagedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedReservation")
                fetchRequest.predicate = NSPredicate(format: "id == %@", reservationToUpdate.id!)
                let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedReservation]
                if let managedReservation = results.first {
                    do {
                        managedReservation.fromReservation(reservation: reservationToUpdate)
                        let reservation = managedReservation.toReservation()
                        try self.privateManagedObjectContext.save()
                        completionHandler(ReservationsStoreResult.Success(result: reservation))
                    } catch {
                        completionHandler(ReservationsStoreResult.Failure(error: ReservationsStoreError.CannotUpdate("Cannot update reservation with id \(String(describing: reservationToUpdate.id))")))
                    }
                }
            } catch {
                completionHandler(ReservationsStoreResult.Failure(error: ReservationsStoreError.CannotUpdate("Cannot fetch reservation with id \(String(describing: reservationToUpdate.id)) to update")))
            }
        }
    }
    
    func deleteReservation(id: String, completionHandler: @escaping ReservationsStoreDeleteReservationCompletionHandler)
    {
        privateManagedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedReservation")
                fetchRequest.predicate = NSPredicate(format: "id == %@", id)
                let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedReservation]
                if let managedReservation = results.first {
                    let reservation = managedReservation.toReservation()
                    self.privateManagedObjectContext.delete(managedReservation)
                    do {
                        try self.privateManagedObjectContext.save()
                        completionHandler(ReservationsStoreResult.Success(result: reservation))
                    } catch {
                        completionHandler(ReservationsStoreResult.Failure(error: ReservationsStoreError.CannotDelete("Cannot delete reservation with id \(id)")))
                    }
                } else {
                    completionHandler(ReservationsStoreResult.Failure(error: ReservationsStoreError.CannotDelete("Cannot fetch reservation with id \(id) to delete")))
                }
            } catch {
                completionHandler(ReservationsStoreResult.Failure(error: ReservationsStoreError.CannotDelete("Cannot fetch reservation with id \(id) to delete")))
            }
        }
    }
    
    // MARK: - CRUD operations - Inner closure
    
    func fetchReservations(completionHandler: @escaping (() throws -> [Reservation]) -> Void)
    {
        privateManagedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedReservation")
                let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedReservation]
                let reservations = results.map { $0.toReservation() }
                completionHandler { return reservations }
            } catch {
                completionHandler { throw ReservationsStoreError.CannotFetch("Cannot fetch reservations") }
            }
        }
    }
    
    func fetchReservation(id: String, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    {
        privateManagedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedReservation")
                fetchRequest.predicate = NSPredicate(format: "id == %@", id)
                let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedReservation]
                if let reservation = results.first?.toReservation() {
                    completionHandler { return reservation }
                } else {
                    throw ReservationsStoreError.CannotFetch("Cannot fetch reservation with id \(id)")
                }
            } catch {
                completionHandler { throw ReservationsStoreError.CannotFetch("Cannot fetch reservation with id \(id)") }
            }
        }
    }
    
    func createReservation(reservationToCreate: Reservation, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    {
        privateManagedObjectContext.perform {
            do {
                let managedReservation = NSEntityDescription.insertNewObject(forEntityName: "ManagedReservation", into: self.privateManagedObjectContext) as! ManagedReservation
                var reservation = reservationToCreate
                self.generateReservationID(reservation: &reservation)
                managedReservation.fromReservation(reservation: reservation)
                try self.privateManagedObjectContext.save()
                completionHandler { return reservation }
            } catch {
                completionHandler { throw ReservationsStoreError.CannotCreate("Cannot create reservation with id \(String(describing: reservationToCreate.id))") }
            }
        }
    }
    
    func updateReservation(reservationToUpdate: Reservation, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    {
        privateManagedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedReservation")
                fetchRequest.predicate = NSPredicate(format: "id == %@", reservationToUpdate.id!)
                let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedReservation]
                if let managedReservation = results.first {
                    do {
                        managedReservation.fromReservation(reservation: reservationToUpdate)
                        let reservation = managedReservation.toReservation()
                        try self.privateManagedObjectContext.save()
                        completionHandler { return reservation }
                    } catch {
                        completionHandler { throw ReservationsStoreError.CannotUpdate("Cannot update reservation with id \(String(describing: reservationToUpdate.id))") }
                    }
                }
            } catch {
                completionHandler { throw ReservationsStoreError.CannotUpdate("Cannot fetch reservation with id \(String(describing: reservationToUpdate.id)) to update") }
            }
        }
    }
    
    func deleteReservation(id: String, completionHandler: @escaping (() throws -> Reservation?) -> Void)
    {
        privateManagedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedReservation")
                fetchRequest.predicate = NSPredicate(format: "id == %@", id)
                let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedReservation]
                if let managedReservation = results.first {
                    let reservation = managedReservation.toReservation()
                    self.privateManagedObjectContext.delete(managedReservation)
                    do {
                        try self.privateManagedObjectContext.save()
                        completionHandler { return reservation }
                    } catch {
                        completionHandler { throw ReservationsStoreError.CannotDelete("Cannot delete reservation with id \(id)") }
                    }
                } else {
                    throw ReservationsStoreError.CannotDelete("Cannot fetch reservation with id \(id) to delete")
                }
            } catch {
                completionHandler { throw ReservationsStoreError.CannotDelete("Cannot fetch reservation with id \(id) to delete") }
            }
        }
    }
}
