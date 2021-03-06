

import Foundation
import Firebase
import UIKit

class GroupController {
    
    static let sharedController = GroupController()
    
    static func groupForIdentifier(identifier: String, completion: (group: Group?) -> Void) {
        
        FirebaseController.dataAtEndpoint("groups/\(identifier)", completion: { (data) in
            if let data = data as? [String: AnyObject] {
                let group = Group(json: data, identifier: identifier)
                completion(group: group)
            } else {
                completion(group: nil)
            }
        })
    }
    
    static func createGroup(groupName: String, users: [String], completion: (success: String?, group : Group) -> Void) {
        let groupID = FirebaseController.base.childByAppendingPath("groups").childByAutoId()
        let identifier = groupID.key
        var group = Group(groupName: groupName, users: users, identifier: identifier)
        group.save()
        completion(success: identifier, group: group)
    }
    
    
    static func passGroupIDsToUsers(userIDs: [String], group: Group, key : String) {
        let allUserIdentifiers = FirebaseController.base.childByAppendingPath("users")
        for userID in userIDs {
            let specificUserID = allUserIdentifiers.childByAppendingPath(userID)
            let usersGroups = specificUserID.childByAppendingPath("groups")
            let specificGroup = usersGroups.childByAppendingPath(key)
            specificGroup.setValue(group.groupName)
        }
    }
    
    static func removeUserFromGroup(user: User, groupID: String, completion: (group: Group)-> Void) {
        UserController.sharedController.currentUser = user
        let currentUser = user.identifier
        let allGroups = FirebaseController.base.childByAppendingPath("groups")
        let specificGroup = allGroups.childByAppendingPath(groupID)
        let usersInGroup = specificGroup.childByAppendingPath("users")
        print(usersInGroup)
        usersInGroup.delete(currentUser)
        
//        let currentUser = UserController.sharedController.currentUser.identifier
//        let usersInGroupArray = group.users
//        for user in usersInGroupArray {
//            
//        }
//    }
    }
}