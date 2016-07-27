import Foundation
import Firebase

class UserController {
    
    private let kUser = "userKey"
    
    static let sharedController = UserController()
    
    var groups: [Group] = []
    
    var kSelectedForGroup = "selectedForGroup"
    
    var users: [User] = []
    
    var currentUser: User! {
        get {
            guard let userID = FirebaseController.base.authData?.uid,
                let userDictionary = NSUserDefaults.standardUserDefaults().valueForKey(kUser) as? [String: AnyObject] else {
                    
                    return nil
            }
            
            return User(json: userDictionary, identifier: userID)
        }
        
        set {
            
            if let newValue = newValue {
                NSUserDefaults.standardUserDefaults().setValue(newValue.jsonValue, forKey: kUser)
                NSUserDefaults.standardUserDefaults().synchronize()
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kUser)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    static func userForIdentifier(identifier: String, completion: (user: User?) -> Void) {
        
        FirebaseController.dataAtEndpoint("users/\(identifier)") { (data) -> Void in
            
            if let json = data as? [String: AnyObject] {
                let user = User(json: json, identifier: identifier)
                completion(user: user)
            } else {
                completion(user: nil)
            }
        }
    }
    
    static func observeGroupsForUser(identifier: String, completion: (group: [Group]) -> Void) {
        FirebaseController.observeDataAtEndpoint("users/\(identifier)/groups") { (data) -> Void in
            
            if let groupIdentifierDictionary = data as? [String: AnyObject] {
                var groups: [Group] = []
                let tunnel = dispatch_group_create()
                for identifier in groupIdentifierDictionary.keys {
                    dispatch_group_enter(tunnel)
                    GroupController.groupForIdentifier(identifier, completion: { (group) in
                        if let group = group {
                            groups.append(group)
                        }
                        dispatch_group_leave(tunnel)
                    })
                }
                dispatch_group_notify(tunnel, dispatch_get_main_queue(), { () -> Void in
                    completion(group: groups)
                })
            } else {
                completion(group: [])
            }
        }
    }
    
    //    static func fetchImagesForGroup(group: Group, completion: (success: Bool, groupImage: String?) -> Void) {
    //        guard let groupImageString = group.identifier else { completion(success: false, groupImage: nil); return}
    //
    //        FirebaseController.base.childByAppendingPath("users").queryOrderedByChild("group").queryEqualToValue(groupImageString).observeEventType(.Value, withBlock: { snapshot in
    //            if let userDictionaries = snapshot.value as? [String: AnyObject] {
    //                let user = userDictionaries.flatMap({User(json: $0.1 as! [String: AnyObject], identifier: $0.0)})
    //                completion(success: true, groupImage: )
    //            } else {
    //                completion(success: false, messages: [])
    //            }
    //        })
    //
    
    
    
    
    static func fetchAllUsers(completion: (success: Bool, users: [User]) -> Void) {
        FirebaseController.dataAtEndpoint("users") { (data) in
            if let json = data as? [String: AnyObject] {
                
                let users = json.flatMap({User(json: $0.1 as! [String: AnyObject], identifier: $0.0)})
                
                completion(success: true, users: users)
            } else {
                completion(success: false, users: [])
            }
        }
    }
    
    static func fetchGroupsForUser(user: User, completion: (groups: [Group]) -> Void) {
        var groups: [Group] = []
        let tunnel = dispatch_group_create()
        for groupID in user.groupIDs {
            dispatch_group_enter(tunnel)
            GroupController.groupForIdentifier(groupID, completion: { (group) in
                if let group = group {
                    groups.append(group)
                }
                dispatch_group_leave(tunnel)
            })
        }
        dispatch_group_notify(tunnel, dispatch_get_main_queue()) {
            completion(groups: groups)
        }
    }
    
    
    
    static func authenticateUser(email: String, password: String, completion: (success: Bool, user: User?) -> Void) {
        
        FirebaseController.base.authUser(email, password: password) { (error, response) -> Void in
            
            if error != nil {
                print("Unsuccessful login attempt.")
                completion(success: false, user: nil)
            } else {
                print("User ID: \(response.uid) was successfully authenticated")
                UserController.userForIdentifier(response.uid, completion: { (user) -> Void in
                    
                    FirebaseController.base.childByAppendingPath("users").childByAppendingPath(response.uid)
                    
                    
                    if let user = user {
                        self.sharedController.currentUser = user
                    }
                    
                    completion(success: true, user: user)
                })
            }
        }
    }
    
    static func createUser(email: String, password: String, username: String, completion: (success: Bool, user: User?) -> Void) {
        
        FirebaseController.base.createUser(email, password: password) { (error, response) -> Void in
            
            if error != nil {
                completion(success: false, user: nil)
                return
            }
            
            if let userID = response["uid"] as? String {
                var user = User(username: username, groups: [], identifier: userID)
                
                user.save()
                
                authenticateUser(email, password: password, completion: { (success, user) -> Void in
                    completion(success: success, user: user)
                    
                })
            } else {
                completion(success: false, user: nil)
            }
        }
    }
    
    static func userAddsUserToGroup(user: User, addsUser: User, completion: (success: Bool) -> Void) {
        
        _ = FirebaseController.base.childByAppendingPath("users")
        
        
    }
    
    static func searchForUserWith(name: String) -> [User] {
        var resultsArray: [User] = []
        for user in resultsArray {
            if user.username.containsString(name) {
                resultsArray.append(user)
            }
        }
        return resultsArray
    }
}
