import Foundation
import Firebase

class User: Equatable, FirebaseType {
    
    let kUsername = "username"
    let kGroups = "groups"
    let kImageString = "image"
    let kSelectedForGroup = "selectedForGroup"
    
    var username: String
    var imageString: String?
    var groupIDs: [String] = []
    var selectedForGroup: Bool = false
    
    var identifier: String?
    var endpoint: String {
        return "users"
    }
    
    var jsonValue: [String: AnyObject] {
        if let imageString = imageString {
            return [kUsername: username, kImageString: imageString, kGroups: groupIDs]
        }
        return [kUsername: username, kGroups: groupIDs]
    }
    
    required init?(json: [String: AnyObject], identifier: String) {
        
        guard let username = json[kUsername] as? String else { return nil }
        
        self.username = username
        
        //FIREBASE - Dictionary
        if let groupIDs = json[kGroups] as? [String: AnyObject] {
            for key in groupIDs.keys {
                self.groupIDs.append(key)
            }
        } else {
            // NSUserDefaults - Array
            if let groupIDs = json[kGroups] as? [String] {
                self.groupIDs = groupIDs
            }
        }
        if let imageString = json[kImageString] as? String {
            self.imageString = imageString
        }
        self.identifier = identifier
    }
    
    //    init?(dictionary: [String: AnyObject]) {
    //        guard let selectedForGroup = dictionary[kSelectedForGroup] as? Bool else { return nil }
    //        self.selectedForGroup = selectedForGroup
    //    }
    
    init(username: String, groups: [String], identifier: String) {
        self.username = username
        self.groupIDs = []
        self.selectedForGroup = false
        self.identifier = identifier
    }
    
}

func == (lhs: User, rhs: User)-> Bool {
    
    return (lhs.username == rhs.username) && (lhs.identifier == rhs.identifier)
}