//
//  MasterViewController.swift
//  AddressBook

import UIKit
import CoreData

class MasterViewController: UITableViewController,
                                NSFetchedResultsControllerDelegate,
                                AddEditTableViewControllerDelegate,
                                DetailViewControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil


    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        displayFirstContactOrInstructions()
    }
    
    func displayFirstContactOrInstructions() {
        if let splitViewController = self.splitViewController {
        
            // check if split view
            if !splitViewController.collapsed {
                // display first contact
                if self.tableView.numberOfRowsInSection(0) > 0 {
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
                    self.performSegueWithIdentifier("showContactDetail", sender: self)
                } else {
                    // display intruction view
                    self.performSegueWithIdentifier("showInstructions", sender: self)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.navigationItem.leftBarButtonItem = self.editButtonItem()
//        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
//        self.navigationItem.rightBarButtonItem = addButton
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as NSManagedObject
             
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue(NSDate(), forKey: "timeStamp")
             
        // Save the context.
        var error: NSError? = nil
        if !context.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showContactDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let selectedContact = self.fetchedResultsController.objectAtIndexPath(indexPath) as Contact
                
                // configure DetailViewController
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                controller.delegate = self
                controller.detailItem = selectedContact
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "showAddContact" {
            // create a new contact object that is not yet managed
            let entity = self.fetchedResultsController.fetchRequest.entity!
            let newContact = Contact(entity: entity, insertIntoManagedObjectContext: nil)
            
            // configure AddEditTableViewController
            let controller = (segue.destinationViewController as UINavigationController).topViewController as AddEditTableViewController
            controller.navigationItem.title = "Add Contact"
            controller.delegate = self
            controller.editingContact = false // adding, not editing
            controller.contact = newContact
        }
    }
    
    // called by AddEditViewController after a contact is added
    func didSaveContact(controller: AddEditTableViewController) {
        // context and insert newly added contact
        let context = self.fetchedResultsController.managedObjectContext
        context.insertObject(controller.contact!)
        self.navigationController?.popToRootViewControllerAnimated(true)
        
        // save context to store the new contact
        var error: NSError? = nil
        if !context.save(&error) {
            displayError(error, title: "Error saving data", message: "Unable to save contact")
        } // if no error, display new contact details
        let sectionInfo = self.fetchedResultsController.sections![0] as NSFetchedResultsSectionInfo
        if let row = find(sectionInfo.objects as [NSManagedObject], controller.contact!) {
            let path = NSIndexPath(forRow: row, inSection: 0)
            tableView.selectRowAtIndexPath(path, animated: true, scrollPosition: .Middle)
            performSegueWithIdentifier("showContactDetail", sender: nil)
        }
    }
    
    // called by DetailViewController after a contact is edited
    func didEditContact(controller: DetailViewController) {
        let context = self.fetchedResultsController.managedObjectContext
        var error: NSError? = nil
        if !context.save(&error) {
            displayError(error, title: "Error saving data", message: "Unable to save contact")
        }
    }
    
    func displayError(error: NSError?, title: String, message: String) {
        // create alert controller and display error
        let alertController = UIAlertController(title: title, message: String(format: "%@\nError:\(error)\n", message), preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as Contact)
                
            var error: NSError? = nil
            if !context.save(&error) {
                displayError(error, title: "Unable to load data", message: "Address unable to access database")
                abort()
            }
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let contact = self.fetchedResultsController.objectAtIndexPath(indexPath) as Contact
        cell.textLabel!.text = contact.lastname
        cell.detailTextLabel!.text = contact.firstname
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Contact", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // sort by last name then first name ascending
        let lastNameSortDescriptor = NSSortDescriptor(key: "lastname", ascending: true, selector: "caseInsensitiveCompare:")
        let firstNameSortDescriptor = NSSortDescriptor(key: "firstname", ascending: true, selector: "caseInsensitiveCompare:")
        fetchRequest.sortDescriptors = [lastNameSortDescriptor, firstNameSortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
    	var error: NSError? = nil
    	if !_fetchedResultsController!.performFetch(&error) {
            displayError(error, title: "Error fetching data", message: "Unable to get data from data source")
    	}
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

