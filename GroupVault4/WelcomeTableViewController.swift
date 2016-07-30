import UIKit
import Firebase

class WelcomeTableViewController: UITableViewController {
    
    static let sharedController = WelcomeTableViewController()
    var groups: [Group] = []
    var currentUser = ""
    
    @IBOutlet weak var groupImageView: UIImageView!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var groupNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let user = UserController.sharedController.currentUser{
            currentUser = user.identifier!
        }else{
            performSegueWithIdentifier("noUserLoggedIn", sender: nil)
        }
        
        if FirebaseController.base.authData == nil {
            
            performSegueWithIdentifier("noUserLoggedIn", sender: nil)
        }
        
        welcomeLabelForUser()
        
        ///UserInterface
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.myMainLightBlueColor()
        tableView.separatorColor = UIColor.myDarkGrayColor()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        UserController.observeGroupsForUser(currentUser) { (group) in
            self.groups = group
            self.tableView.reloadData()
            
            if self.groups.count == 0 {
                self.showAlert("You aren't in any groups yet!", message: "Tap the top right corner to make a group!")
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toolbarButtonTapped(sender: AnyObject) {
        
        self.logoutAlert("", message: "Are you sure you want to logout?")
    }
    
    func welcomeLabelForUser() {
        if UserController.sharedController.currentUser != nil {
            welcomeLabel.text = "Welcome, \(UserController.sharedController.currentUser.username)!"
        }
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("enterAGroup", forIndexPath: indexPath) as! WelcomeTableViewCell
        
        let group = self.groups[indexPath.row]
        
        cell.groupViewOnCell(group)
        
        return cell
    }
    
//    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        
//        let selectedGroup = self.groups[indexPath.row]
//        
//        
//        let leaveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Leave") { (UITableViewRowAction, NSIndexPath) -> Void in
//            
//            
//            
//            //            self.groupMessages.removeAtIndex(indexPath.row)
//            //            selectedMessage.delete()
//            //            tableView.reloadData()
//        }
//        
//        
//        return [leaveAction]
//    }
    
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func logoutAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let logoutAction = UIAlertAction(title: "Logout", style: .Default) { (action) in
            FirebaseController.base.unauth()
            self.performSegueWithIdentifier("noUserLoggedIn", sender: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toEnterAGroup" {
            
            let messageBoardViewController = segue.destinationViewController as? MessageBoardViewController
            
            _ = messageBoardViewController!.view
            
            let cell = sender as? UITableViewCell
            
            let indexPath = tableView.indexPathForCell(cell!)
            
            if let selectedRow = indexPath?.row {
                
                let group = self.groups[selectedRow]
                messageBoardViewController!.updateWith(group)
            }
        }
        
    }
}