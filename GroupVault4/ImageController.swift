

import Foundation
import UIKit
import Firebase

class ImageController {
    
    static var image: Message?
    
    static let sharedController = ImageController()
    
    
    static func uploadProfileImage(user: User, image: UIImage, completion: (identifier: String?) -> Void) {
        if let userID = user.identifier {
            let user = user
            if let base64Image = image.base64String {
                FirebaseController.base.childByAppendingPath("users/\(userID)/image").setValue(base64Image)
                user.imageString = base64Image
                UserController.sharedController.currentUser = user
                completion(identifier: base64Image)
            } else {
                completion(identifier: nil)
            }
        }
    }
    
    static func uploadGroupImage(group: Group, image: UIImage, completion: (identifier: String?) -> Void) {
        
        if let identifier = group.identifier {
            if let base64String = image.base64String {
                FirebaseController.base.childByAppendingPath("groups/\(identifier)/image").setValue(base64String)
                group.groupImageString = base64String
                completion(identifier: base64String)
                
            } else {
                completion(identifier: nil)
            }
        }
    }
    
    static func groupImageForIdentifier(identifier: String, completion: (image: UIImage?) -> Void) {
        
        FirebaseController.dataAtEndpoint("groups/\(identifier)/image") { (data) -> Void in
            
            if let data = data as? String {
                let image = UIImage(base64: data)
                completion(image: image)
            } else {
                completion(image: nil)
            }
        }
    }
    
    static func imageForUser(imageString: String, completion: (success: Bool, image: UIImage?) -> Void) {
        
        
        if let image = UIImage(base64: imageString) {
            completion(success: true, image: image)
        } else {
            completion(success: false, image: nil)
        }
        
    }
}