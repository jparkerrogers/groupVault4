

import UIKit


class ReceiverImageViewController: UIViewController {
    
    static let sharedController = ReceiverImageViewController()
    
    @IBOutlet weak var recieverImageView: UIImageView!
    
    var message: Message?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateImage(message: Message) {
        self.navigationItem.title = message.senderName
        self.message = message
        self.recieverImageView.image = message.image
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
