/*-------------------------------------
 
 - Photofeed -
 
 created by cubycode @2017
 All Rights Reserved
 
 -------------------------------------*/


import UIKit
import Parse


class EditProfile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate
{
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var aboutMeTxt: UITextView!
    @IBOutlet weak var avatarimage: UIImageView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    
    let currentUser = PFUser.current()!
    var avatarPic = Bool()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Edit profile"
        
        let saveBtn=UIBarButtonItem(barButtonSystemItem:.save, target:self, action:#selector(updateProfileButt))
        navigationItem.rightBarButtonItem=saveBtn
        
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 800)
        
        avatarimage.layer.borderColor=UIColor.white.cgColor
        
        createKeyboardToolbar()
        showUserDetails()
    }
    
    func createKeyboardToolbar()
    {
        let keyboardToolbar = UIView()
        keyboardToolbar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44)
        keyboardToolbar.backgroundColor = UIColor.clear
        keyboardToolbar.autoresizingMask = .flexibleWidth
        fullnameTxt.inputAccessoryView = keyboardToolbar
        aboutMeTxt.inputAccessoryView = keyboardToolbar
        
        // Dismiss keyboard button
        let dismissButt = UIButton(type: .custom)
        dismissButt.frame = CGRect(x: keyboardToolbar.frame.size.width-44, y: 0, width: 44, height: 44)
        dismissButt.setBackgroundImage(UIImage(named: "close"), for: .normal)
        dismissButt.addTarget(self, action: #selector(dismissKeyboard(_:)), for: .touchUpInside)
        keyboardToolbar.addSubview(dismissButt)
    }
    
    @objc func dismissKeyboard(_ sender:UIButton)
    {
        fullnameTxt.resignFirstResponder()
        aboutMeTxt.resignFirstResponder()
    }
    
    func showUserDetails()
    {
        fullnameTxt.text = "\(currentUser[USER_FULLNAME]!)"
        if currentUser[USER_ABOUT_ME] != nil { aboutMeTxt.text = "\(currentUser[USER_ABOUT_ME]!)"
        } else { aboutMeTxt.text = nil }
        emailLabel.text = "\(currentUser[USER_EMAIL]!)"
        
        // Get avatar image
        avatarimage.image = UIImage(named: "logo")
        let imageFile = currentUser[USER_AVATAR] as? PFFile
        imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.avatarimage.image = UIImage(data:imageData)
                } } })
        
        // Get cover image
        let coverFile = currentUser[USER_COVER_IMAGE] as? PFFile
        coverFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.coverImage.image = UIImage(data:imageData)
                }}})
    }
    
    @IBAction func uploadPicButt(_ sender: AnyObject)
    {
        let butt = sender as! UIButton
        if butt.tag == 0 { avatarPic = true
        } else { avatarPic = false }
        
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Select source",
                                      preferredStyle: .alert)
        let camera = UIAlertAction(title: "Take a picture", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera)
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        let library = UIAlertAction(title: "Pick from Library", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in })
        
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if avatarPic { avatarimage.image = resizeImage(image: pickedImage, newWidth: 240)
            } else { coverImage.image = resizeImage(image: pickedImage, newWidth: 350) }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateProfileButt(_ sender: AnyObject)
    {
        showHUD()
        
        currentUser[USER_FULLNAME] = fullnameTxt.text
        
        if aboutMeTxt.text != "" { currentUser[USER_ABOUT_ME] = aboutMeTxt.text
        } else { currentUser[USER_ABOUT_ME] = "" }
        
        // Save Image (if exists)
        if avatarimage.image != nil {
            let imageData = UIImageJPEGRepresentation(avatarimage.image!, 0.5)
            let imageFile = PFFile(name:"avatar.jpg", data:imageData!)
            currentUser[USER_AVATAR] = imageFile
        }
        // Save Cover Image (if exists)
        if coverImage.image != nil {
            let imageData = UIImageJPEGRepresentation(coverImage.image!, 0.5)
            let imageFile = PFFile(name:"cover.jpg", data:imageData!)
            currentUser[USER_COVER_IMAGE] = imageFile
        }
        
        
        // Saving block
        currentUser.saveInBackground { (success, error) -> Void in
            if error == nil {
                self.simpleAlert("Your Profile has been updated!")
                self.hideHUD()
                _ = self.navigationController?.popViewController(animated: true)
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
    }
}
