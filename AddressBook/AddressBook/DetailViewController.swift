//
//  DetailViewController.swift
//  AddressBook

import CoreData
import UIKit

// MasterViewController conforms to be notified when contact edited
protocol DetailViewControllerDelegate {
    func didEditContact(controller: DetailViewController)
}

class DetailViewController: UIViewController,
    AddEditTableViewControllerDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    
    var delegate: DetailViewControllerDelegate!
    var detailItem: Contact!

//    var detailItem: AnyObject? {
//        didSet {
//            // Update the view.
//            self.configureView()
//        }
//    }

    func configureView() {
        // Update the user interface for the detail item.
//        if let detail: AnyObject = self.detailItem {
//            if let label = self.detailDescriptionLabel {
//                label.text = detail.valueForKey("timeStamp")!.description
//            }
//        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if detailItem != nil {
            displayContact()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func displayContact() {
        self.navigationItem.title = detailItem.firstname + " " + detailItem.lastname
        
        emailTextField.text = detailItem.email?
        phoneTextField.text = detailItem.phone?
        streetTextField.text = detailItem.street?
        cityTextField.text = detailItem.city?
        stateTextField.text = detailItem.state?
        zipTextField.text = detailItem.zip?
    }
    
    func didSaveContact(controller: AddEditTableViewController) {
        displayContact()
        self.navigationController?.popViewControllerAnimated(true)
        delegate?.didEditContact(self)
    }
    
    // call when user taps edit button
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // configure vc to edit current contact
        if segue.identifier == "showEditContact" {
            let controller = (segue.destinationViewController as UINavigationController).topViewController as AddEditTableViewController
            controller.navigationItem.title = "Edit Contact"
            controller.delegate = self
            controller.editingContact = true
            controller.contact = detailItem
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}

