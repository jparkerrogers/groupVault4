

import UIKit

class WelcomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var groupImageView: UIImageView!
    
    @IBOutlet weak var groupNameLabel: UILabel!
    
    var group: Group?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func groupViewOnCell(group: Group) {
        if let groupID = group.identifier {
            ImageController.groupImageForIdentifier(groupID, completion: { (image) in
                if let groupImage = image {
                    self.groupImageView.image = groupImage
                } else {
                    self.groupImageView.image = UIImage(named: "defaultProfileImage")
                }
            })
        }
        groupImageView.layer.masksToBounds = true
        groupImageView.contentMode = UIViewContentMode.ScaleAspectFill
        groupImageView.layer.borderColor = UIColor.myDarkGrayColor().CGColor
        groupImageView.layer.borderWidth = 0.5
        groupImageView.alpha = 1.0
        
        self.groupNameLabel.text = group.groupName
        self.group = group
    }
    
}

