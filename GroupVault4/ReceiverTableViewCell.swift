

import UIKit

class ReceiverTableViewCell: UITableViewCell, ReceiverTimerDelegate {
    
    static let sharedCell = ReceiverTableViewCell()
    
    @IBOutlet weak var receiverDate: UILabel!
    
    @IBOutlet weak var receiverUserName: UILabel!
    
    @IBOutlet weak var sendersProfileImageView: UIImageView!
    
    @IBOutlet weak var receiverMessageView: UIView!
    
    @IBOutlet weak var receiverMessageText: UILabel!
    
    @IBOutlet weak var lockAndUnlockButton: UIButton!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var receiverTextMessageStackView: UIStackView!
    
    @IBOutlet weak var leftBubbleConstraint: NSLayoutConstraint!
    
    weak var delegate: RecieverTableViewCellDelegate?
    
    var message: Message?
    
    var cell: ReceiverTableViewCell?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sendersProfileImageView.layer.borderWidth = 1
        sendersProfileImageView.layer.masksToBounds = false
        sendersProfileImageView.layer.borderColor = UIColor.blackColor().CGColor
        sendersProfileImageView.clipsToBounds = true
        
        //        let imageLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MessageBoardViewController.profileImagePressed))
        //        sendersProfileImageView.userInteractionEnabled = true
        //        sendersProfileImageView.addGestureRecognizer(imageLongPressGestureRecognizer)
        
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func showMessageButtonTapped(sender: AnyObject) {
        if let delegate = delegate {
            delegate.receiverLockImageButtonTapped(self)
        }
    }
    
    func lockImageViewForReceiver() {
        if let message = self.message {
            timerLabel.hidden = true
            lockAndUnlockButton.hidden = false
            lockAndUnlockButton.setBackgroundImage(UIImage(named: "lockedLock"), forState: .Normal)
            sendersProfileImageView.hidden = false
            ImageController.imageForUser(message.senderProfileImage) { (success, image) in
                if success {
                    self.sendersProfileImageView.image = image
                } else {
                    self.sendersProfileImageView.image = UIImage(named: "defaultProfileImage")
                }
            }
            receiverMessageView.hidden = true
            receiverMessageText.hidden = true
            receiverDate.textColor = UIColor.lightGrayColor()
            receiverDate.text = message.dateString
            receiverDate.font = UIFont.boldSystemFontOfSize(12)
            receiverUserName.font = UIFont.boldSystemFontOfSize(18)
            receiverUserName.text = message.senderName
            receiverUserName.font = UIFont.boldSystemFontOfSize(12)
        }
    }
    
    func goBackToLockImageView() {
        if let message = self.message {
            timerLabel.hidden = true
            lockAndUnlockButton.hidden = false
            lockAndUnlockButton.setBackgroundImage(UIImage(named: "unlockedLock"), forState: .Normal)
            sendersProfileImageView.hidden = false
            ImageController.imageForUser(message.senderProfileImage) { (success, image) in
                if success {
                    self.sendersProfileImageView.image = image
                } else {
                    self.sendersProfileImageView.image = UIImage(named: "defaultProfileImage")
                }
            }
            receiverTextMessageStackView.hidden = false
            sendersProfileImageView.hidden = false
            receiverUserName.hidden = false
            receiverDate.hidden = false
            receiverMessageView.hidden = true
            receiverMessageText.hidden = true
            receiverDate.textColor = UIColor.lightGrayColor()
            receiverDate.text = message.dateString ?? ""
            receiverDate.font = UIFont.boldSystemFontOfSize(12)
            receiverUserName.font = UIFont.boldSystemFontOfSize(18)
            receiverUserName.text = message.senderName ?? ""
            receiverUserName.font = UIFont.boldSystemFontOfSize(12)
        }
    }
    
    func messageViewForReceiver(message: Message) {
        
        message.timer?.receiverDelegate = self
        timerLabel.hidden = false
        sendersProfileImageView.hidden = false
        receiverMessageView.hidden = false
        receiverMessageView.layer.masksToBounds = true
        receiverMessageView.backgroundColor = UIColor.myLightBlueMessageColor()
        receiverMessageView.layer.cornerRadius = 8.0
        receiverMessageView.layer.borderColor = UIColor.blackColor().CGColor
        receiverMessageView.layer.borderWidth = 0.5
        receiverMessageText.hidden = false
        receiverMessageText.textColor = UIColor.blackColor()
        receiverMessageText.text = message.text
        ImageController.imageForUser(message.senderProfileImage) { (success, image) in
            if success {
                self.sendersProfileImageView.image = image
            } else {
                self.sendersProfileImageView.image = UIImage(named: "defaultProfileImage")
            }
        }
        receiverDate.textColor = UIColor.lightGrayColor()
        receiverDate.text = message.dateString
        receiverDate.font = UIFont.boldSystemFontOfSize(12)
        receiverUserName.font = UIFont.boldSystemFontOfSize(12)
        receiverUserName.text = message.senderName
        receiverUserName.font = UIFont.boldSystemFontOfSize(12)
        lockAndUnlockButton.hidden = true
        
    }
    
    func messageTimerComplete() {
        if let message = self.message {
            MessageController.userViewedMessage(message, completion: { (success, message) in
                self.goBackToLockImageView()
            })
        }
        message?.save()
    }
    
    func updateTimerLabel() {
        
        timerLabel.text = message?.timer?.timeAsString()
    }
}

protocol RecieverTableViewCellDelegate: class {
    func receiverLockImageButtonTapped(sender: ReceiverTableViewCell)
    
}
