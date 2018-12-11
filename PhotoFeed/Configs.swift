/*-------------------------------------
 
 - Photofeed -
 
 created by cubycode @2017
 All Rights Reserved
 
 -------------------------------------*/


import Foundation
import UIKit




// IMPORTANT: CHANGE THE RED NAME BELOW ACCORDINGLY TO THE NEW NAME YOU'LL GIVE TO THIS APP
let APP_NAME = "Feedi"



// IMPORTANT: REPLACE THE RED STRING BELOW WITH THE UNIT ID YOU'VE GOT BY REGISTERING YOUR APP IN http://www.apps.admob.com
let ADMOB_BANNER_UNIT_ID = "ca-app-pub-7666000398456991/8497308090"




// IMPORTANT: Replace the 2 red keys below with the Application ID and Client Key of your own app on back4app.com
let PARSE_APP_KEY = "yT4pRFaS3kzp5knylNGvcwuiPExr68duXZzRHSty"
let PARSE_CLIENT_KEY = "gP5AuhDzbQvYKw2P6ToOxA8Tku8DYePjAQMBQb51"




// YOU CAN EDIT THESE RGB VALUES AS YOU WISH:
let postColorsArray = [
    UIColor(red: 255.0/255.0, green: 87.0/255.0, blue: 34.0/255.0, alpha: 1.0),  // THIS IS THE ORANGE MAIN APP'S COLOR
    
    UIColor(red: 255.0/255.0, green: 207.0/255.0, blue: 85.0/255.0, alpha: 1.0),
    UIColor(red: 160.0/255.0, green: 212.0/255.0, blue: 104.0/255.0, alpha: 1.0),
    UIColor(red: 250.0/255.0, green: 110.0/255.0, blue: 82.0/255.0, alpha: 1.0),
    UIColor(red: 72.0/255.0, green: 207.0/255.0, blue: 174.0/255.0, alpha: 1.0),
    UIColor(red: 236.0/255.0, green: 136.0/255.0, blue: 192.0/255.0, alpha: 1.0),
    UIColor(red: 237.0/255.0, green: 85.0/255.0, blue: 100.0/255.0, alpha: 1.0),
    UIColor(red: 250.0/255.0, green: 110.0/255.0, blue: 82.0/255.0, alpha: 1.0),
    UIColor(red: 130.0/255.0, green: 202.0/255.0, blue: 156.0/255.0, alpha: 1.0),
]




// HUD View
let hudView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
let indicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
extension UIViewController {
    func showHUD() {
        hudView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        hudView.backgroundColor = postColorsArray[0]
        hudView.alpha = 0.9
        hudView.layer.cornerRadius = hudView.bounds.size.width/2
        hudView.layer.borderColor = UIColor.white.cgColor
        hudView.layer.borderWidth = 2
        
        indicatorView.center = CGPoint(x: hudView.frame.size.width/2, y: hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        indicatorView.color = UIColor.white
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
    }
    
    func hideHUD() { hudView.removeFromSuperview() }
    
    func simpleAlert(_ mess:String) {
        let alert = UIAlertController(title: APP_NAME, message: mess, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

/************ DO NOT EDIT THE CODE BELOW ************/

let USER_CLASS_NAME = "_User"
let USER_AVATAR = "avatar"
let USER_COVER_IMAGE = "coverImage"
let USER_USERNAME = "username"
let USER_FULLNAME = "fullName"
let USER_EMAIL = "email"
let USER_ABOUT_ME = "aboutMe"
let USER_IS_REPORTED = "isReported"
let USER_REPORT_MESSAGE = "reportMessage"


let POSTS_CLASSE_NAME = "Posts"
let POSTS_TEXT = "postText"
let POSTS_USER_POINTER = "postUser"
let POSTS_IMAGE = "postImageFile"
let POSTS_CITY = "city"
let POSTS_LIKES = "likes"
let POSTS_DATE = "createdAt"
let POSTS_IS_REPORTED = "isReported"
let POSTS_REPORT_MESSAGE = "reportMessage"
let POSTS_KEYWORDS = "keywords"


let LIKES_CLASS_NAME = "Likes"
let LIKES_LIKED_BY = "likedBy"
let LIKES_POST_LIKED = "postLiked"

let BLOCK_USER_CLASS_NAME = "BlockUser"

let FOLLOW_CLASS_NAME = "Follow"
let FOLLOW_A_USER = "aUser"
let FOLLOW_IS_FOLLOWING = "isFollowing"

let ACTIVITY_CLASS_NAME = "Activity"
let ACTIVITY_CURRENT_USER = "currentUser"
let ACTIVITY_OTHER_USER = "otherUser"
let ACTIVITY_TEXT = "text"

let COMMENTS_CLASS_NAME = "Comments"
let COMMENTS_POST_POINTER = "postPointer"
let COMMENTS_USER_POINTER = "userPointer"
let COMMENTS_COMMENT = "comment"

// MARK: - EXTENSION TO RESIZE A UIIMAGE
extension UIViewController {
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
