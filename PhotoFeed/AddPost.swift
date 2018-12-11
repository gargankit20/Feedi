/*-------------------------------------
 
 - Photofeed -
 
 created by cubycode @2017
 All Rights Reserved
 
 -------------------------------------*/

import UIKit
import Parse

class AddPost: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate
{
    @IBOutlet weak var postTxt: UITextView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    /* Variables */
    var locationManager: CLLocationManager!

    // You can change this placeholder text anytime
    let placeholderString = "What do you want to show?"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initializeKeyboardToolbar()
        
        
        // Get user's vatar image
        let imageFile = PFUser.current()![USER_AVATAR] as? PFFile
        imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.avatarImage.image = UIImage(data:imageData)
                } } })
        avatarImage.layer.cornerRadius = avatarImage.bounds.size.width/2
    }
    
    func initializeKeyboardToolbar()
    {
        // Init a keyboard toolbar
        let toolbar = UIView(frame: CGRect(x: 0, y: view.frame.size.height, width: view.frame.size.width, height: 44))
        toolbar.backgroundColor = UIColor.white
        
        // Camera button
        let camImg=UIImageView(frame:CGRect(x:20, y:12.5, width:20, height:19))
        camImg.image=UIImage(named:"photo")
        toolbar.addSubview(camImg)
        
        let camButt = UIButton(frame: CGRect(x:10, y:2, width:40, height:40))
        camButt.addTarget(self, action: #selector(uploadPicButt(_:)), for: .touchUpInside)
        toolbar.addSubview(camButt)
        
        // Location button
        let locImg=UIImageView(frame:CGRect(x:71.5, y:12, width:17, height:20))
        locImg.image=UIImage(named:"location")
        toolbar.addSubview(locImg)
        
        let locButt = UIButton(frame: CGRect(x:60, y:2, width:40, height:40))
        locButt.addTarget(self, action: #selector(setCityButt(_:)), for: .touchUpInside)
        toolbar.addSubview(locButt)
        
        postTxt.inputAccessoryView = toolbar
        postTxt.delegate = self
        postTxt.text = placeholderString
    }

    func textViewDidBeginEditing(_ textView:UITextView)
    {
        if textView.text==placeholderString
        {
            textView.text=""
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView:UITextView)
    {
        if textView.text==""
        {
            textView.text=placeholderString
        }
        textView.resignFirstResponder()
    }
    
    @objc func uploadPicButt(_ sender: UIButton)
    {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Select source",
                                      preferredStyle: UIAlertControllerStyle.alert)
        let camera = UIAlertAction(title: "Take a picture", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera)
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
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
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
        })
        alert.addAction(camera); alert.addAction(library); alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            postImage.image = resizeImage(image: image, newWidth: 600)
            postTxt.becomeFirstResponder()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func setCityButt(_ sender:UIButton)
    {
        // Init LocationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        simpleAlert("Failed to Get Your Location")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        locationManager.stopUpdatingLocation()
        
        let location = locations.last
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location!, completionHandler: { (placemarks, error) -> Void in
            
            let placeArray:[CLPlacemark] = placemarks!
            var placemark: CLPlacemark!
            placemark = placeArray[0]
            
            // City & State strings
            let city = placemark.addressDictionary?["City"] as? String ?? ""
            let country = placemark.addressDictionary?["Country"] as? String ?? ""
            
            // CONSOLE LOGS:
            print("CITY: \(city), \(country)")
            self.locationLabel.text = "\(city), \(country)"
        })
    }

    @IBAction func postButton(_ sender:UIButton)
    {
        let postsClass = PFObject(className: POSTS_CLASSE_NAME)
        let currentUser = PFUser.current()!
        showHUD()
        postTxt.resignFirstResponder()
        
        // Save PFUser as a Pointer
        postsClass[POSTS_USER_POINTER] = currentUser
        
        // Save data
        postsClass[POSTS_TEXT] = postTxt.text
        
        
        // Add keywords
        let keywords = postTxt.text.lowercased().components(separatedBy: " ") +
            "\(currentUser[USER_FULLNAME]!)".lowercased().components(separatedBy: " ")
        postsClass[POSTS_KEYWORDS] = keywords
        
        if locationLabel.text != "" { postsClass[POSTS_CITY] = locationLabel!.text!
        } else { postsClass[POSTS_CITY] = "n/d" }
        
        postsClass[POSTS_IS_REPORTED] = false
        
        // Save Image
        if postImage.image != nil {
            let imageData = UIImageJPEGRepresentation(postImage.image!, 0.8)
            let imageFile = PFFile(name:"image.jpg", data:imageData!)
            postsClass[POSTS_IMAGE] = imageFile
        }
        
        
        if postImage.image == nil || postTxt.text == "" {
            simpleAlert("You must type something and add an image!")
            hideHUD()
            
        } else {
            // Saving block
            postsClass.saveInBackground { (success, error) -> Void in
                if error == nil {
                    self.hideHUD()
                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
                }}
        }
        
    }
    
    @IBAction func cancelButt(_ sender: AnyObject)
    {
        postTxt.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}
