/*-------------------------------------
 
 - Photofeed -
 
 created by cubycode @2017
 All Rights Reserved
 
 -------------------------------------*/


import UIKit
import Parse

class SignUp: UIViewController, UITextFieldDelegate
{
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var fullnameTxt: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func dismissKeyboard()
    {
        usernameTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
        fullnameTxt.resignFirstResponder()
    }
    
    @IBAction func signupButt(_ sender: AnyObject)
    {
        dismissKeyboard()
        showHUD()
        
        if usernameTxt.text == "" || passwordTxt.text == "" || fullnameTxt.text == "" {
            simpleAlert("You must fill all the fields to sign up!")
            self.hideHUD()
            
        } else {
            let userForSignUp = PFUser()
            userForSignUp.username = usernameTxt.text!.lowercased()
            userForSignUp.email = usernameTxt.text!.lowercased()
            userForSignUp.password = passwordTxt.text
            userForSignUp[USER_FULLNAME] = fullnameTxt.text
            userForSignUp[USER_IS_REPORTED] = false
            
            // Save default avatar
            let imageData = UIImageJPEGRepresentation(UIImage(named:"logo")!, 1.0)
            let imageFile = PFFile(name:"avatar.jpg", data:imageData!)
            userForSignUp[USER_AVATAR] = imageFile
            
            userForSignUp.signUpInBackground { (succeeded, error) -> Void in
                // SUCCESSFULL SIGN UP
                if error == nil {
                    self.dismiss(animated: false, completion: nil)
                    self.hideHUD()
                    
                    // ERROR ON SIGN UP
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
                }}
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == usernameTxt {  passwordTxt.becomeFirstResponder()  }
        if textField == passwordTxt {  fullnameTxt.becomeFirstResponder()     }
        if textField == fullnameTxt    {  fullnameTxt.resignFirstResponder()     }
        return true
    }
    
    @IBAction func backButt(_ sender: AnyObject)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touButt(_ sender: AnyObject)
    {
        let touVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfUse") as! TermsOfUse
        present(touVC, animated: true, completion: nil)
    }
}
