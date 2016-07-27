

import Foundation
import UIKit

class Group: Equatable, FirebaseType {
    
    let kGroupName = "groupName"
    let kUsers = "users"
    let kMessages = "messages"
    let kGroupImageString = "groupImage"
    
    var groupName: String
    var users: [String]
    var groupImageString: String?
    
    var identifier: String?
    var endpoint: String {
        return "groups"
    }
    
    
    var jsonValue: [String: AnyObject] {
        
        if let groupImageString = groupImageString {
            return [kGroupName: groupName, kUsers: users, kGroupImageString: groupImageString]
        }
        return [kGroupName: groupName, kUsers: users]
    }
    
    required init?(json: [String : AnyObject], identifier: String) {
        
        guard let groupName = json[kGroupName] as? String,
            let users = json[kUsers] as? [String] else { return nil }
        
        if let groupImageString = json[kGroupImageString] as? String {
            self.groupImageString = groupImageString
        }
        
        self.groupName = groupName
        self.users = users
        self.identifier = identifier
    }
    
    init(groupName: String, users:[String], identifier: String) {
        
        self.groupName = groupName
        self.users = users
        self.identifier = identifier
    }
    
}

func == (lhs: Group, rhs: Group) -> Bool {
    
    return (lhs.identifier == rhs.identifier)
}