

import UIKit

class SenderTableViewCell: UITableViewCell, SenderTimerDelegate {
    
    static let sharedCell = SenderTableViewCell()
    
    @IBOutlet weak var senderDate: UILabel!
    
    @IBOutlet weak var senderUsername: UILabel!
    
    @IBOutlet weak var senderProfileImageView: UIImageView!
    
    @IBOutlet weak var senderMessageStackView: UIStackView!
    
    @IBOutlet weak var senderMessageView: UIView!
    
    @IBOutlet weak var senderMessageText: UILabel!
    
    @IBOutlet weak var senderTimerLabel: UILabel!
    
    @IBOutlet weak var senderLockAndUnlockButton: UIButton!
    
    
    
    weak var delegate: SenderTableViewCellDelegate?
    var message: Message?
    var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        senderProfileImageView.layer.borderWidth = 1
        senderProfileImageView.layer.masksToBounds = false
        senderProfileImageView.layer.borderColor = UIColor.blackColor().CGColor
        senderProfileImageView.layer.cornerRadius = senderProfileImageView.frame.height/2
        senderProfileImageView.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func showMessageButtonTapped(sender: AnyObject) {
        
        if let delegate = delegate {
            delegate.senderMessageButtonTapped(self)
        }
    }
    
    
    func lockImageViewForSender() {
        if let message = self.message {
            senderTimerLabel.hidden = true
            senderProfileImageView.hidden = false
            senderLockAndUnlockButton.hidden = false
            senderLockAndUnlockButton.setBackgroundImage(UIImage(named: "lockedLock"), forState: .Normal)
            ImageController.imageForUser(message.senderProfileImage) { (success, image) in
                if success {
                    self.senderProfileImageView.image = image
                } else {
                    self.senderProfileImageView.image = UIImage(named: "defaultProfileImage")
                }
            }
            senderMessageView.hidden = true
            senderMessageText.hidden = true
            senderUsername.text = message.senderName
            senderDate.textColor = UIColor.myLightBlueMessageColor()
            senderDate.text = message.dateString
            senderDate.font = UIFont.boldSystemFontOfSize(12)
        }
    }
    
    func goBackToLockImageView() {
        if let message = self.message {
            senderTimerLabel.hidden = true
            senderProfileImageView.hidden = false
            senderLockAndUnlockButton.hidden = false
            senderLockAndUnlockButton.setBackgroundImage(UIImage(named: "unlockedLock"), forState: .Normal)
            ImageController.imageForUser(message.senderProfileImage) { (success, image) in
                if success {
                    self.senderProfileImageView.image = image
                } else {
                    self.senderProfileImageView.image = UIImage(named: "defaultProfileImage")
                }
            }
            senderMessageView.hidden = true
            senderMessageText.hidden = true
            senderUsername.text = message.senderName
            senderDate.textColor = UIColor.myLightBlueMessageColor()
            senderDate.text = message.dateString
            senderDate.font = UIFont.boldSystemFontOfSize(12)
            
        }
    }
    
    func messageViewForSender(message: Message) {
        
        message.timer?.senderDelegate = self
        senderProfileImageView.hidden = true
        senderTimerLabel.hidden = false
        senderProfileImageView.hidden = false
        senderMessageView.hidden = false
        senderMessageView.layer.masksToBounds = true
        senderMessageView.backgroundColor = UIColor.myLightestGrayColor()
        senderMessageView.layer.cornerRadius = 8.0
        senderMessageView.layer.borderColor = UIColor.blackColor().CGColor
        senderMessageView.layer.borderWidth = 0.5
        senderMessageView.hidden = false
        senderMessageStackView.hidden = false
        senderMessageText.hidden = false
        senderMessageText.textColor = UIColor.blackColor()
        senderMessageText.text = message.text
        ImageController.imageForUser(message.senderProfileImage) { (success, image) in
            if success {
                self.senderProfileImageView.image = image
            } else {
                self.senderProfileImageView.image = UIImage(named: "defaultProfileImage")
            }
        }
        senderDate.textColor = UIColor.myMainLightBlueColor()
        senderDate.text = message.dateString
        senderDate.font = UIFont.boldSystemFontOfSize(12)
        senderUsername.font = UIFont.boldSystemFontOfSize(12)
        senderUsername.text = message.senderName
        senderUsername.font = UIFont.boldSystemFontOfSize(12)
        senderLockAndUnlockButton.hidden = true
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
        senderTimerLabel.text = message?.timer?.timeAsString()
    }
}

protocol SenderTableViewCellDelegate: class {
    func senderMessageButtonTapped(sender: SenderTableViewCell)
    
}
