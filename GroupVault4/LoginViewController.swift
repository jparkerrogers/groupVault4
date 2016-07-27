

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var user: User?
    
    var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var fetchingDataIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var createAccountOutlet: UIButton!
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    
    
    @IBOutlet weak var blurryView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.blurryView.hidden = true
        fetchingDataIndicator.hidesWhenStopped = true
        fetchingDataIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        
        emailTextField.text = ""
        passwordTextField.text = ""
        
        downSwipeGesture()
        upSwipeGesture()
        tapGestureToDismissKeyBoard()
        
        ///UserInterface
        
        emailTextField.layer.borderColor = UIColor.myLightestGrayColor().CGColor
        emailTextField.layer.borderWidth = 2.5
        emailTextField.layer.cornerRadius = 6.0
        emailTextField.backgroundColor = UIColor.whiteColor()
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter your email address here", attributes: [NSForegroundColorAttributeName: UIColor.myLightestGrayColor()])
        emailTextField.textColor = UIColor.twitterDarkBlueColor()
        
        passwordTextField.layer.borderColor = UIColor.myLightestGrayColor().CGColor
        passwordTextField.layer.borderWidth = 2.5
        passwordTextField.layer.cornerRadius = 6.0
        passwordTextField.backgroundColor = UIColor.whiteColor()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "enter password with 6+ characters", attributes: [NSForegroundColorAttributeName: UIColor.myLightestGrayColor()])
        passwordTextField.textColor = UIColor.twitterDarkBlueColor()
        
        loginButtonOutlet.layer.borderColor = UIColor.whiteColor().CGColor
        loginButtonOutlet.layer.borderWidth = 4.0
        loginButtonOutlet.layer.cornerRadius = 6.0
        
        createAccountOutlet.layer.borderColor = UIColor.whiteColor().CGColor
        createAccountOutlet.layer.borderWidth = 4.0
        createAccountOutlet.layer.cornerRadius = 6.0
    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        self.hideKeyboard()
        
        //        self.disableUserInteraction(true)
        
        if let email = emailTextField.text,
            password = passwordTextField.text {
            
            self.startFetchingDataIndicator()
            UserController.authenticateUser(email, password: password, completion: { (success, user) in
                
                if success {
                    self.stopFetchingDataIndicator()
                    self.performSegueWithIdentifier("toWelcomView", sender: nil)
                    
                } else {
                    self.stopFetchingDataIndicator()
                    self.showLoginAlert("Invalid information", message: "Provide:\n-jemail\n-password (6 or more characters)")
                }
            })
        }
        
    }
    
    
    @IBAction func CreateAccount(sender: AnyObject) {
        emailTextField.text = ""
        passwordTextField.text = ""
        
    }
    
    
    func downSwipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.swiped)
        )
        swipeDown.direction = .Down
        self.view.addGestureRecognizer(swipeDown)
    }
    func upSwipeGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.swiped)
        )
        swipeUp.direction = .Up
        self.view.addGestureRecognizer(swipeUp)
    }
    
    
    func swiped(gesture: UISwipeGestureRecognizer) {
        
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.Down:
            emailTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
        case UISwipeGestureRecognizerDirection.Up:
            emailTextField.becomeFirstResponder()
            passwordTextField.becomeFirstResponder()
        default:
            break
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    //    func textFieldDidBeginEditing(textField: UITextField) {
    //        if passwordTextField.text != "" {
    //            self.createAccountOutlet.hidden = true
    //            self.buttonStackView.frame = CGRect(x: buttonStackView.frame.origin.x, y: buttonStackView.frame.origin.y, width: 50, height: 20)
    //        }
    //    }
    
    func tapGestureToDismissKeyBoard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture)
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    func showLoginAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func startFetchingDataIndicator() {
        self.blurryView.hidden = false
        fetchingDataIndicator.startAnimating()
        
        
    }
    
    func stopFetchingDataIndicator() {
        self.blurryView.hidden = true
        fetchingDataIndicator.stopAnimating()
    }
    
    //        func addBackGroundBlurEffect() {
    //            view.backgroundColor = UIColor.clearColor()
    //
    //            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
    //            visualEffectView = UIVisualEffectView(effect: blurEffect)
    //
    //            visualEffectView.frame = self.blurryView.bounds
    //            visualEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    //            self.view.addSubview(visualEffectView)
    //        }
    //
    //        func removeBackgroundBlurEffect() {
    //            visualEffectView.removeFromSuperview()
    //            self.view.backgroundColor = UIColor.whiteColor()
    //
    //        }
}

