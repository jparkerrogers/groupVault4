

import Foundation
import UIKit

class Message: FirebaseType, Equatable {
    
    let kSender = "sender"
    let kSenderProfileImage = "senderProfileImage"
    let kText = "text"
    var kImage = "image"
    let kDateString = "dateString"
    let kViewedBy = "viewedBy"
    let kGroupID = "group"
    let kSenderName = "senderName"
    
    
    var sender = ""
    var senderName: String
    var senderProfileImage: String
    var text: String?
    var image: UIImage?
    var dateString: String
    var timer: Timer? = Timer()
    var viewedBy: [String]?
    let groupID: String
    
    var identifier: String?
    var endpoint: String {
        return "messages"
    }
    
    
    var jsonValue: [String: AnyObject] {
        var json: [String: AnyObject] = [kSender: sender,kSenderName: senderName, kSenderProfileImage: senderProfileImage, kDateString: dateString, kGroupID: groupID]
        
        if let text = text {
            json.updateValue(text, forKey: kText)
            
            if let image = image?.base64String {
                json.updateValue(image, forKey: kImage)
                
                if let viewedBy = viewedBy {
                    json.updateValue(viewedBy, forKey: kViewedBy)
                }
            }
        }
        return json
    }
    
    required init?(json: [String: AnyObject], identifier: String) {
        
        guard let sender = json[kSender] as? String,
            let senderProfileImage = json[kSenderProfileImage] as? String,
            let text = json[kText] as? String,
            let dateString = json[kDateString] as? String,
            let groupID = json[kGroupID] as? String,
            let senderName = json[kSenderName] as? String else { return nil }
        
        self.sender = sender
        self.senderProfileImage = senderProfileImage
        self.text = text
        if let image = json[kImage] as? String {
            self.image = UIImage(base64: image)
        } else {
            self.image = nil
        }
        self.dateString = dateString
        self.viewedBy = json[kViewedBy] as? [String] ?? []
        self.groupID = groupID
        self.senderName = senderName
        self.identifier = identifier
    }
    
    init(sender: String, senderName: String, senderProfileImage: String,text: String?, image: UIImage?, dateString: String, timer: Timer?, viewedBy: [String], isLocked: Bool = false, identifier: String, groupID: String) {
        self.sender = sender
        self.senderName = senderName
        self.senderProfileImage = senderProfileImage
        self.text = text
        self.image = image
        self.dateString = dateString
        self.timer = timer
        self.viewedBy = viewedBy
        self.identifier = identifier
        self.groupID = groupID
        
    }
}

func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.identifier == rhs.identifier
}