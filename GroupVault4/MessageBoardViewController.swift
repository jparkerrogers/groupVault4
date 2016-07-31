

import UIKit

class MessageBoardViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, ImageTimerDelegate {
    
    static let sharedController = MessageBoardViewController()
    
    var group: Group?
    var groupMessages: [Message] = []
    var currentGroup = ""
    var timer: Timer?
    var message: Message?
    let currentUser = UserController.sharedController.currentUser
    
    var UIImageVC: UIViewController?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mockKeyboardView: UIView!
    @IBOutlet weak var mockTextView: UITextView!
    @IBOutlet weak var mockCameraImageButton: UIButton!
    @IBOutlet weak var mockSendButton: UIButton!
    
    
    @IBOutlet var trueKeyboardView: UIView!
    @IBOutlet weak var trueCameraButton: UIButton!
    @IBOutlet weak var trueSendButton: UIButton!
    @IBOutlet weak var trueTextView: UITextView!
    
    @IBOutlet var imageAccessoryView: UIView!
    @IBOutlet weak var imageAccessoryImageView: UIImageView!
    @IBOutlet weak var imageAccessoryCancelButton: UIButton!
    @IBOutlet weak var imageAccessoryTimerLabel: UILabel!
    @IBOutlet weak var mockViewForInputAccessoryView: UIView!
    
    
    @IBOutlet weak var mockKeyboardViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var blurryView: UIView!
    @IBOutlet weak var fetchingGroupMessagesIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageBoardViewController.keyboardShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageBoardViewController.keyboardHidden(_:)), name: UIKeyboardDidHideNotification, object: nil)
        tapGestureToDismissKeyBoard()
        
        fetchingGroupMessagesIndicator.hidesWhenStopped = true
        fetchingGroupMessagesIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        blurryView.hidden = true
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        mockTextView.inputAccessoryView = trueKeyboardView
        mockTextView.delegate = self
        trueTextView.delegate = self
        
        //User Interface
        
        mockTextView.layer.borderWidth = 2.5
        mockTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        mockTextView.layer.cornerRadius = 6.0
        mockSendButton.layer.cornerRadius = 6.0
        mockSendButton.layer.borderColor = UIColor.whiteColor().CGColor
        mockSendButton.layer.borderWidth = 2.0
        mockKeyboardView.backgroundColor = UIColor.myMainLightBlueColor()
        
        trueTextView.layer.borderWidth = 2.0
        trueTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        trueTextView.layer.cornerRadius = 6.0
        trueSendButton.layer.cornerRadius = 6.0
        trueSendButton.backgroundColor = UIColor(white: 0.75, alpha: 0.25)
        trueSendButton.layer.borderColor = UIColor.whiteColor().CGColor
        trueSendButton.layer.borderWidth = 2.0
        trueKeyboardView.backgroundColor = UIColor.myMainLightBlueColor()
        
        self.navigationController?.navigationBar.tintColor = UIColor.myLightGrayMessageColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.myDarkGrayColor()
        
        mockViewForInputAccessoryView.hidden = true
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let cameraTapGesture = UITapGestureRecognizer(target: self, action: #selector(MessageBoardViewController.cameraImageTapped))
        trueCameraButton.userInteractionEnabled = true
        trueCameraButton.addGestureRecognizer(cameraTapGesture)
        
        let mockCameraTapGesture = UITapGestureRecognizer(target: self, action: #selector(MessageBoardViewController.cameraImageTapped))
        mockCameraImageButton.userInteractionEnabled = true
        mockCameraImageButton.addGestureRecognizer(mockCameraTapGesture)
        
        imageAccessoryImageView.userInteractionEnabled = true
        
        let imageDownSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MessageBoardViewController.messageImageTimerComplete))
        imageDownSwipe.direction = .Down
        self.imageAccessoryImageView.addGestureRecognizer(imageDownSwipe)
        
        let imageUpSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MessageBoardViewController.messageImageTimerComplete))
        imageUpSwipe.direction = .Up
        self.imageAccessoryImageView.addGestureRecognizer(imageUpSwipe)
        
        let cancelButtonTouched = UITapGestureRecognizer(target: self, action: #selector(MessageBoardViewController.messageImageTimerComplete))
        imageDownSwipe.direction = .Down
        self.imageAccessoryCancelButton.addGestureRecognizer(cancelButtonTouched)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        let allMessages = groupMessages
        for message in allMessages {
            if message.timer != nil {
                TimerController.sharedInstance.stopTimer(message.timer ?? Timer())
            }
        }
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        if trueTextView.text != "" {
            trueTextView.resignFirstResponder()
            mockTextView.resignFirstResponder()
            trueKeyboardView.hidden = true
            mockKeyboardView.hidden = false
            createMessage()
            trueTextView.text = ""
            mockTextView.text = ""
            
        }
    }
    
    func createMessage() {
        guard let currentUser = self.currentUser,
            currentUserID = self.currentUser.identifier,
            currentUserImage = self.currentUser.imageString,
            group = group,
            groupID = group.identifier else { return }
        
        if let message = trueTextView.text {
            MessageController.createMessage(currentUserID, senderName: currentUser.username, senderProfileImage: currentUserImage, groupID: groupID, text: message, image: nil, timer: Timer(), viewedBy: [], completion: { (success, message) in
                
                if success == true {
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.tableView.reloadData()
                        
                    })
                } else {
                    self.tableView.reloadData()
                    print("message not saved")
                }
                
            })
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.groupMessages.count
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let message = groupMessages[indexPath.row]
        
        if message.sender == self.currentUser.identifier {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("senderCell", forIndexPath: indexPath) as! SenderTableViewCell
            cell.delegate = self
            cell.message = message
            guard let currentUser = UserController.sharedController.currentUser.identifier,
                viewedByArray = message.viewedBy else { return cell }
            if viewedByArray.contains(currentUser) {
                cell.goBackToLockImageView()
            } else {
                cell.lockImageViewForSender()
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("receiverCell", forIndexPath: indexPath) as! ReceiverTableViewCell
            cell.delegate = self
            cell.message = message
            
            guard let currentUser = UserController.sharedController.currentUser.identifier,
                viewedByArray = message.viewedBy else { return cell }
            if viewedByArray.contains(currentUser) {
                cell.goBackToLockImageView()
            } else {
                cell.lockImageViewForReceiver()
            }
            return cell
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        
        let selectedMessage = self.groupMessages[indexPath.row]
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { (UITableViewRowAction, NSIndexPath) -> Void in
            
            self.groupMessages.removeAtIndex(indexPath.row)
            selectedMessage.delete()
            tableView.reloadData()
        }
        
        let reportAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Report") { (UITableViewRowAction, NSIndexPath) -> Void in
            
            
            let reportMenu = UIAlertController(title: nil, message: "Are you sure you want to report \(selectedMessage.senderName)?", preferredStyle: .ActionSheet)
            
            let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.Default, handler: { (deleteMenu) in
                MessageController.reportUserForInappropriateContent(selectedMessage)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
            
            reportMenu.addAction(reportAction)
            reportMenu.addAction(cancelAction)
            
            self.presentViewController(reportMenu, animated: true, completion: nil)
        }
        if selectedMessage.sender == self.currentUser.identifier {
            return [deleteAction]
        } else {
            return [reportAction]
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func updateWith(group: Group) {
        
        self.navigationItem.title = group.groupName
        self.group = group
        
        self.startFetchingDataIndicator()
        MessageController.fetchMessagesForGroup(group) { (success, messages) in
            if success == true {
                MessageController.deleteGroupMessageBasedOnDate(messages)
                self.stopFetchingDataIndicator()
                if messages.count > self.groupMessages.count {
                    self.groupMessages = messages.sort({ $0.identifier < $1.identifier })
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.tableView.reloadData()
                        self.scrollToBottom(true)
                    })
                }
            } else {
                
                self.stopFetchingDataIndicator()
                self.groupMessages = messages.sort({ $0.identifier < $1.identifier })
            }
        }
        
    }
    
    func cameraImageTapped() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        trueTextView.resignFirstResponder()
        mockTextView.resignFirstResponder()
        
        let cameraAlert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            cameraAlert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (_) -> Void in
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                cameraAlert.addAction(UIAlertAction(title: "Take Photo or Video", style: .Default, handler: { (_) in
                    imagePicker.allowsEditing = true
                    imagePicker.sourceType = .Camera
                    imagePicker.cameraCaptureMode = .Photo
                    self.presentViewController(imagePicker, animated: true, completion: nil)
                }))
            }
        }
        
        cameraAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(cameraAlert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        guard let image = pickedImage,
            currentUser = self.currentUser,
            currentUserID = self.currentUser.identifier,
            currentUserImage = self.currentUser.imageString else { return }
        if let group = group, let groupID = group.identifier {
            MessageController.createMessage(currentUserID, senderName: currentUser.username, senderProfileImage: currentUserImage, groupID: groupID, text: "", image: image, timer: Timer(), viewedBy: [], completion: { (success, message) in
                if success == true {
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.tableView.reloadData()
                    })
                } else {
                    print("image not saved")
                }
            })
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("user cancelled image")
        dismissViewControllerAnimated(true) {
            // anything you want to happen when the user selects cancel
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
    
    //        func profileImagePressed() {image s
    //            let messageIndexPath = NSIndexPath()
    //            let selectedMessage = self.groupMessages[messageIndexPath.row]
    //            tableView.reloadData()
    //            MessageController.reportUserForInappropriateContent(selectedMessage)
    //        }
    
    func presentImage(message: Message) {
        self.message = message
        self.imageAccessoryImageView.image = message.image
        self.imageAccessoryImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageAccessoryCancelButton.backgroundColor = UIColor.myMainLightBlueColor()
        self.imageAccessoryCancelButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.imageAccessoryCancelButton.layer.borderWidth = 0.5
        self.imageAccessoryTimerLabel.backgroundColor = UIColor.myMainLightBlueColor()
        self.imageAccessoryTimerLabel.layer.borderColor = UIColor.whiteColor().CGColor
        self.imageAccessoryTimerLabel.layer.borderWidth = 0.5
        self.imageAccessoryView.frame = self.mockViewForInputAccessoryView.frame
        self.imageAccessoryView.layer.borderColor = UIColor.whiteColor().CGColor
        self.imageAccessoryView.layer.borderWidth = 5.0
        self.imageAccessoryView.backgroundColor = UIColor.blackColor()
        self.imageAccessoryView.tag = 100
        self.blurryView.hidden = false
        self.view.addSubview(imageAccessoryView)
        message.timer?.imageDelegate = self
    }
    
    func dismissImage() {
        imageAccessoryView.removeFromSuperview()
        self.blurryView.hidden = true
    }
    
    func updateImageTimerLabel() {
        self.imageAccessoryTimerLabel.text = message?.timer?.timeAsString()
    }
    
    func messageImageTimerComplete() {
        if let message = self.message {
            MessageController.userViewedMessage(message, completion: { (success, message) in
                self.dismissImage()
            })
        }
        message?.save()
        tableView.reloadData()
    }
    
    func scrollToBottom(bool: Bool){
        if self.groupMessages.count > 0 {
            let lastRowNumer = self.groupMessages.count - 1
            let indexPath = NSIndexPath(forRow: lastRowNumer, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: bool)
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.trueTextView.becomeFirstResponder()
        if let constraint = self.trueKeyboardView.constraints.filter({$0.identifier == "_UIKBAutolayoutHeightConstraint"}).first {
            
            constraint.constant = self.trueTextView.contentSize.height + 10
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        
        UIView.animateWithDuration(0.2) {
            
            if let constraint = self.trueKeyboardView.constraints.filter({$0.identifier == "_UIKBAutolayoutHeightConstraint"}).first {
                
                if self.trueTextView.contentSize.height <= 160 {
                    constraint.constant = self.trueTextView.contentSize.height + 10
                } else {
                    constraint.constant = 160
                }
            }
        }
    }
    
    func keyboardShown(notification: NSNotification) {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        let rawFrame = value.CGRectValue
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        
        trueKeyboardView.hidden = false
        mockKeyboardView.hidden = true
        scrollToBottom(true)
        tableViewBottomConstraint.constant = keyboardFrame.height
    }
    
    func keyboardHidden(notification: NSNotification) {
        tableViewBottomConstraint.constant = 46
        trueKeyboardView.hidden = true
        mockKeyboardView.hidden = false
        trueTextView.text = ""
        mockTextView.text = ""
        scrollToBottom(false)
    }
    
    func startFetchingDataIndicator() {
        self.blurryView.hidden = false
        fetchingGroupMessagesIndicator.startAnimating()
    }
    
    func stopFetchingDataIndicator() {
        self.blurryView.hidden = true
        fetchingGroupMessagesIndicator.stopAnimating()
    }
    
    func tapGestureToDismissKeyBoard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MessageBoardViewController.tapGestureToDismissKeyBoard))
        tapGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture)
    }
}



extension MessageBoardViewController: SenderTableViewCellDelegate, RecieverTableViewCellDelegate {
    
    func senderMessageButtonTapped(sender: SenderTableViewCell) {
        
        guard let message = sender.message,
            currentUserID = self.currentUser.identifier,
            viewedByArray = message.viewedBy else { return }
        if viewedByArray.contains(currentUserID) {
            sender.goBackToLockImageView()
        } else if message.image != nil {
            TimerController.sharedInstance.startTimer(message.timer ?? Timer())
            self.presentImage(message)
        } else if message.text != "" {
            TimerController.sharedInstance.startTimer(message.timer ?? Timer())
            sender.messageViewForSender(message)
            //            self.profileImagePressed()
        }
    }
    
    func receiverLockImageButtonTapped(sender: ReceiverTableViewCell) {
        
        guard let message = sender.message,
            currentUserID = self.currentUser.identifier,
            viewedByArray = message.viewedBy else { return }
        if viewedByArray.contains(currentUserID) {
            sender.goBackToLockImageView()
        } else if message.image != nil {
            TimerController.sharedInstance.startTimer(message.timer ?? Timer())
            self.presentImage(message)
        } else if message.text != "" {
            TimerController.sharedInstance.startTimer(message.timer ?? Timer())
            sender.messageViewForReceiver(message)
        }
    }
}
