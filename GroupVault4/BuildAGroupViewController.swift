

import UIKit

class BuildAGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var groupNameTextField: UITextField!
    
    @IBOutlet weak var viewForSearchBar: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var blurryView: UIView!
    
    @IBOutlet weak var fetchAllUsersIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var groupImageView: UIImageView!
    
    var usersDataSource: [User] = []
    //    var filteredDataSource: [User] = []
    var selectedUserIDs: [String] = []
    var currentUser = UserController.sharedController.currentUser
    var user: User?
    var group: Group?
    
    var searchController: UISearchController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        self.blurryView.hidden = true
        self.fetchAllUsersIndicator.hidesWhenStopped = true
        self.fetchAllUsersIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        
        self.startFetchingDataIndicator()
        UserController.fetchAllUsers { (success, users) in
            if success == true {
                self.usersDataSource = users.filter({ (user) -> Bool in
                    return user.identifier != UserController.sharedController.currentUser.identifier
                })
                self.stopFetchingDataIndicator()
                self.tableView.reloadData()
            }
            self.downSwipeGesture()
            self.upSwipeGesture()
            self.tableView.keyboardDismissMode = .OnDrag
            
        }
        
        navigationItem.title = "Build A Group"
        setupSearchController()
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        
        createGroup()
    }
    
    func setupSearchController() {
        let resultsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("filteredResults")
        searchController = UISearchController(searchResultsController: resultsController)
        guard let searchController = searchController else { return }
        searchController.view.frame = self.view.frame
        searchController.searchBar.placeholder = "Search users"
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = self
        searchController.definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.barTintColor = UIColor.lightGrayColor()
        searchController.searchBar.backgroundColor = UIColor.myMainLightBlueColor()
        searchController.searchBar.tintColor = UIColor.myMainLightBlueColor()
        self.tableView.tableHeaderView = searchController.searchBar
        
        definesPresentationContext = true
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        guard let searchTerm = searchController.searchBar.text?.lowercaseString else { return }
        if let resultsController = searchController.searchResultsController as? FilteredResultsTableViewController {
        resultsController.filteredDataSource = self.usersDataSource.filter({ $0.username.lowercaseString.containsString(searchTerm)})
        searchController.hidesNavigationBarDuringPresentation = false
        self.view.backgroundColor = UIColor.lightGrayColor()
        
        resultsController.tableView.reloadData()
        SearchBarSearchTextEmpty()
        changeViewForSearchBar()
        
        }
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        tableView.reloadData()
    }
    
    func SearchBarSearchTextEmpty() {
        if searchController?.searchBar.text == "" {
            tableView.reloadData()
            
        }
    }
    
    func changeViewForSearchBar() {
        
        guard let searchBar = searchController?.searchBar else {return}
        searchBar.backgroundColor = UIColor.myMainLightBlueColor()
        view.backgroundColor = UIColor.lightGrayColor()
        searchBar.barTintColor = UIColor.blackColor()
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        //        if filteredDataSource.count > 0 {
        //            return filteredDataSource.count
        //        } else {
        //            return usersDataSource.count
        //        }
        //        /// return the number of users
        
        return usersDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! BuildAGroupTableViewCell
        
        cell.delegate = self
        
        let user = usersDataSource[indexPath.row]
        
        cell.userViewOnCell(user)
        
        let selectedForGroup = user.selectedForGroup
        
        if selectedForGroup == true {
            cell.userSelectedForGroup(user)
            
        } else if selectedForGroup == false {
            cell.userNotSelectedForGroup(user)
        }
        
        return cell
    }
    
    func createGroup() {
        
        guard let myIdentifier = UserController.sharedController.currentUser.identifier else { return }
        
        for user in usersDataSource {
            if user.selectedForGroup == true {
                selectedUserIDs.append(user.identifier!)
            }
        }
        
        
        if !selectedUserIDs.contains(myIdentifier) {
            selectedUserIDs.append(myIdentifier)
        }
        
        if groupNameTextField.text == "" || selectedUserIDs.count <= 1 {
            self.showAlert("Error!", message: "Make sure you create a group name and add members.")
            selectedUserIDs = []
        } else {
            GroupController.createGroup(groupNameTextField.text!, users: selectedUserIDs, completion: { (success, group) in
                
                if (success != nil) {
                    GroupController.passGroupIDsToUsers(self.selectedUserIDs, group:group, key: success!)
                    self.group = group
                    self.selectAPhotoPickerController()
                }
            })
        }
    }
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func downSwipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(SignUpViewController.swiped))
        swipeDown.direction = .Down
        self.view.addGestureRecognizer(swipeDown)
    }
    func upSwipeGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(SignUpViewController.swiped)
        )
        swipeUp.direction = .Up
        self.view.addGestureRecognizer(swipeUp)
    }
    
    func swiped(gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.Down:
            groupNameTextField.resignFirstResponder()
        case UISwipeGestureRecognizerDirection.Up:
            groupNameTextField.resignFirstResponder()
        default:
            break
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        groupNameTextField.resignFirstResponder()
        return true
    }
    
    func startFetchingDataIndicator() {
        self.blurryView.hidden = false
        self.fetchAllUsersIndicator.startAnimating()
        
        
    }
    
    func stopFetchingDataIndicator() {
        self.blurryView.hidden = true
        self.fetchAllUsersIndicator.stopAnimating()
        self.setupSearchController()
        
    }
    
    //    func almostDoneAlert(title: String, message: String) {
    //
    //        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    //        let action = UIAlertAction(title: "Ok", style: .Default) { (action) in
    //            self.okButtonTapped()
    //        }
    //        alert.addAction(action)
    //        presentViewController(alert, animated: true, completion: nil)
    //    }
    
    func selectAPhotoPickerController() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alert = UIAlertController(title: "Select a group Image", message: nil, preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (_) -> Void in
                imagePicker.sourceType = .PhotoLibrary
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                alert.addAction(UIAlertAction(title: "Take Photo or Video", style: .Default, handler: { (_) in
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .Camera
                    imagePicker.cameraCaptureMode = .Photo
                    self.presentViewController(imagePicker, animated: true, completion: nil)
                }))
            }
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (_) in
            self.navigationController?.popViewControllerAnimated(true)
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if let image = pickedImage {
            if let group = self.group {
                
                ImageController.uploadGroupImage(group, image: image, completion: { (identifier) in
                    UIView.animateWithDuration(4.0, animations: {
                        self.groupNameTextField.hidden = true
                        self.groupImageView.alpha = 1.0
                        self.groupImageView.image = image
                        self.groupImageView.layer.borderWidth = 4.0
                        self.groupImageView.layer.borderColor = UIColor.whiteColor().CGColor
                        self.groupImageView.clipsToBounds = true
                        self.groupImageView.contentMode = UIViewContentMode.ScaleAspectFill
                        }, completion: { (_) in
                            sleep(1)
                            self.navigationController?.popViewControllerAnimated(true)
                    })
                })
            }
        }
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true) {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func imageWasSavedSuccessfully(image: UIImage, didFinishSavingWithError error: NSError!, context: UnsafeMutablePointer<()>) {
        print("Image saved")
        if let error = error {
            print("An error occured while waving the image. \(error.localizedDescription)")
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
            })
        }
    }
}

extension BuildAGroupViewController: BuildAGroupTableViewCellDelegate {
    
    
    func addUserButtonTapped(sender: BuildAGroupTableViewCell) {
        
        let indexPath = tableView.indexPathForCell(sender)
        
        let user = userStatus(indexPath!)
        
        user.selectedForGroup = !user.selectedForGroup
        
        tableView.reloadData()
        
    }
    
    func userStatus(indexPath: NSIndexPath) -> User {
        
        return usersDataSource[indexPath.row]
        
    }
    
}


