//
//  AddEditTableViewController.swift
//  AddressBook

import CoreData
import UIKit

// MasterViewController and DetailViewController conform to this
// to be notified when a contact is added or edited, respectively
protocol AddEditTableViewControllerDelegate {
    func didSaveContact(controller: AddEditTableViewController)
}

class AddEditTableViewController: UITableViewController,
            UITextFieldDelegate {
    
    @IBOutlet var inputFields: [UITextField]!
    
    // field names used in loops to get/set Contact attribute values via NSManagedObject methods value for key
    private let fieldNames = ["firstname", "lastname", "email", "phone", "street", "city", "state", "zip"]
    
    var delegate: AddEditTableViewControllerDelegate?
    var contact: Contact? // Contact to add or edit
    var editingContact = false // differentiates adding/editing

    override func viewDidLoad() {
        super.viewDidLoad()
    
        for textField in inputFields {
            textField.delegate = self
        }
        
        // if editing a contact, display its data
        if editingContact {
            for i in 0..<fieldNames.count {
                // query contact objec with value for key
                if let value: AnyObject = contact?.valueForKey(fieldNames[i]) {
                    inputFields[i].text = value.description
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue!
        let size = frame.CGRectValue().size
        
        // get duration of keyboard's slide-in animation
        let animationTime =
        userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        
        // scroll self.tableView so selected UITextField above keyboard
        UIView.animateWithDuration(animationTime) {
            var insets = self.tableView.contentInset
            insets.bottom = size.height
            self.tableView.contentInset = insets
            self.tableView.scrollIndicatorInsets = insets
        }
        
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return 0
//    }
    
    // called when app receives UIKeyboardWillHideNotification
    func keyboardWillHide(notification: NSNotification) {
        var insets = self.tableView.contentInset
        insets.bottom = 0
        self.tableView.contentInset = insets
        self.tableView.scrollIndicatorInsets = insets
    }

    // hide keyboard if user touches Return key
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if inputFields[0].text.isEmpty || inputFields[1].text.isEmpty {
            let alertController = UIAlertController(title: "Error", message: "First and last names required", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            // update contact in core data from input fields
            for i in 0..<fieldNames.count {
                let value = (!inputFields[i].text.isEmpty ? inputFields[i].text : nil)
                self.contact?.setValue(value, forKey: fieldNames[i])
            }
            self.delegate?.didSaveContact(self)
        }
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
