

import UIKit

class FilteredBuildAGroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var addUserButton: UIButton!
    
    var user: User?
    
    weak var filteredDelegate: FilteredBuildAGroupTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userProfileImageView.layer.borderWidth = 1
        userProfileImageView.layer.masksToBounds = true
        userProfileImageView.layer.borderColor = UIColor.blackColor().CGColor
        userProfileImageView.contentMode = UIViewContentMode.ScaleAspectFill
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func addUserButtonTapped(sender: AnyObject) {
        
        
        if let filteredDelegate = filteredDelegate {
            filteredDelegate.filteredAddUserButtonTapped(self)
        }
        
    }
    
    func userViewOnCell(user: User) {
        
        if let userImageString = user.imageString {
            ImageController.imageForUser(userImageString) { (success, image) in
                if success {
                    self.userProfileImageView.image = image
                } else if success == false {
                    self.userProfileImageView.image = UIImage(named: "defaultProfileImage")
                }
            }
        }
        self.userLabel.text = user.username
        self.user = user
    }
    
    
    func userSelectedForGroup(user: User) {
        
        self.userLabel.text = user.username
        addUserButton.setBackgroundImage(UIImage(named: "userAdded"), forState: .Normal)
        addUserButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.backgroundColor = UIColor.myMainLightBlueColor()
    }
    
    func userNotSelectedForGroup(user: User) {
        
        self.userLabel.text = user.username
        addUserButton.setBackgroundImage(UIImage(named: "addUser"), forState: .Normal)
        addUserButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
}

protocol FilteredBuildAGroupTableViewCellDelegate: class {
    
    func filteredAddUserButtonTapped(sender: FilteredBuildAGroupTableViewCell)
    
}
