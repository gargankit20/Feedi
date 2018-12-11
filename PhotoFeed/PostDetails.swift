/*-------------------------------------
 
 - Photofeed -
 
 created by cubycode @2017
 All Rights Reserved
 
 -------------------------------------*/


import UIKit
import Parse
import MessageUI
import GoogleMobileAds
import AudioToolbox

@available(iOS 8.2, *)
class PostDetails: UIViewController, MFMailComposeViewControllerDelegate, UIScrollViewDelegate, GADBannerViewDelegate
{
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var followOutlet: UIButton!
    
    @IBOutlet weak var postTxt: UITextView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeOutlet: UIButton!
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet var imgScrollView: UIScrollView!
    @IBOutlet var imgPrev: UIImageView!
    
    //Ad banners properties
    var adMobBannerView = GADBannerView()
    
    var postObj = PFObject(className: POSTS_CLASSE_NAME)
    var followArray = [PFObject]()
    var likesArray = [PFObject]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Post"
        self.edgesForExtendedLayout = UIRectEdge()
        followOutlet.layer.borderColor=UIColor(red:255.0/255.0, green:87.0/255.0, blue:34.0/255.0, alpha:1.0).cgColor
        navigationItem.backBarButtonItem=UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        // Setup views on iPad
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            containerScrollView.frame = CGRect(x: 0, y: 0, width: 460, height: view.frame.size.height)
            containerScrollView.center = view.center
        }
        
        // Hide previewView
        previewView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        imgScrollView.delegate = self
        imgPrev.frame = imgScrollView.frame
        
        initAdMobBanner()
        
        showPostDetails()
        queryFollow()
        queryLikeStatus()
        
        let userPointer = postObj[POSTS_USER_POINTER] as! PFUser
        
        if PFUser.current()?.objectId==userPointer.objectId
        {
            followOutlet.isHidden=true
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return imgPrev
    }

    func showPostDetails()
    {
        // Get userPointer
        let userPointer = postObj[POSTS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground { (user, error) in
            
            let city="\(self.postObj[POSTS_CITY]!)"=="n/d" ? "" : "\(self.postObj[POSTS_CITY]!)"
            
            let string=city=="" ? "\(userPointer[USER_FULLNAME]!) added a new photo" : "\(userPointer[USER_FULLNAME]!) added a new photo at \(city)"
            
            let attributedString1=NSMutableAttributedString(string:string, attributes:[.font:UIFont.systemFont(ofSize:13.0, weight:.medium), .foregroundColor:UIColor(red:146.0/255.0, green:148.0/255.0, blue:150.0/255.0, alpha:1.0), .kern:0.25])
            attributedString1.addAttributes([.foregroundColor:UIColor(red:71.0/255.0, green:75.0/255.0, blue:78.0/255.0, alpha:1.0), .kern:0.27], range:NSRange(location:0, length:"\(userPointer[USER_FULLNAME]!)".count))
            attributedString1.addAttribute(.foregroundColor, value:UIColor(red:1.0, green:87.0/255.0, blue:34.0/255.0, alpha:1.0), range:NSRange(location:string.count-city.count, length:city.count))
            
            self.fullnameLabel.attributedText=attributedString1
            
            // Get avatar image
            self.avatarImage.image = UIImage(named: "logo")
            let avatarFile = userPointer[USER_AVATAR] as? PFFile
            avatarFile?.getDataInBackground { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        self.avatarImage.image = UIImage(data:imageData)
                    }}}

            
            
            // Get Post date
            let date = self.postObj.createdAt
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM dd yyyy"
            self.dateLabel.text = dateFormat.string(from: date!)
            
            // Get post image
            let imageFile = self.postObj[POSTS_IMAGE] as? PFFile
            imageFile?.getDataInBackground { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        self.postImage.image = UIImage(data:imageData)
                    }}}
            
            self.postTxt.text = "\(self.postObj[POSTS_TEXT]!)"
            self.postTxt.sizeToFit()
            if self.postObj[POSTS_LIKES] != nil { self.likesLabel.text = "\(self.postObj[POSTS_LIKES]!)"
            } else { self.likesLabel.text = "0" }
            
            
            // Reposition views
            //self.buttonsView.frame.origin.y = self.postTxt.frame.size.height + self.postTxt.frame.origin.y + 10
            //self.containerScrollView.contentSize = CGSize(width: self.containerScrollView.frame.size.width, height: self.buttonsView.frame.origin.y + self.buttonsView.frame.size.height + 70)
        }
    }
    
    func queryFollow()
    {
        let userFollowed = postObj[POSTS_USER_POINTER] as! PFUser
        
        followArray.removeAll()
        let query = PFQuery(className: FOLLOW_CLASS_NAME)
        query.whereKey(FOLLOW_A_USER, equalTo: PFUser.current()!)
        query.whereKey(FOLLOW_IS_FOLLOWING, equalTo: userFollowed)
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.followArray = objects!
                
                // YOU'RE ALREADY FOLLOWING THIS USER
                if self.followArray.count > 0 {
                    self.followOutlet.setTitle("Unfollow", for: .normal)
                    
                    
                    // YOU'RE NOT FOLLOWING THIS USER
                } else if self.followArray.count == 0 {
                    self.followOutlet.setTitle("Follow", for: .normal)  }
                
            } else {
                let alert = UIAlertView(title: APP_NAME,
                                        message: "\(error!.localizedDescription)",
                    delegate: nil, cancelButtonTitle: "OK" )
                alert.show()
            }
            
            self.followOutlet.setBackgroundImage(UIImage(named: "\(self.followOutlet.titleLabel!.text!)"), for: .normal)
        }
    }
    
    @IBAction func followButt(_ sender: AnyObject)
    {
        let butt = sender as! UIButton
        
        var followClass = PFObject(className: FOLLOW_CLASS_NAME)
        let currentUser = PFUser.current()
        let userFollowed = postObj[POSTS_USER_POINTER] as! PFUser
        
        
        // UNFOLLOW THIS USER
        if butt.titleLabel!.text == "Unfollow"
        {
            followClass = followArray[0]
            followClass.deleteInBackground {(success, error) -> Void in
                if error == nil {
                    butt.setTitle("Follow", for: .normal)
                } }
            
            
            // FOLLOW THIS USER
        }
        else if butt.titleLabel!.text == "Follow"
        {
            // Save follower and followed
            followClass[FOLLOW_A_USER] = currentUser
            followClass[FOLLOW_IS_FOLLOWING] = userFollowed
            
            // Saving block
            followClass.saveInBackground(block: { (success, error) -> Void in
                if error == nil {
                    butt.setTitle("Unfollow", for: .normal)
                    
                    
                    // Send Push notification
                    let pushStr = "\(PFUser.current()![USER_FULLNAME]!) started following you"
                    let data = [ "badge" : "Increment",
                                 "alert" : pushStr,
                                 "sound" : "bingbong.aiff"
                    ]
                    let request = [
                        "someKey" : userFollowed.objectId!,
                        "data" : data
                        ] as [String : Any]
                    PFCloud.callFunction(inBackground: "push", withParameters: request as [String : Any], block: { (results, error) in
                        if error == nil {
                            print ("\nPUSH SENT TO: \(userFollowed[USER_USERNAME]!)\nMESSAGE: \(pushStr)\n")
                        } else {
                            print ("\(error!.localizedDescription)")
                        }
                    })
                    
                    // Save Activity
                    let activityClass = PFObject(className: ACTIVITY_CLASS_NAME)
                    activityClass[ACTIVITY_CURRENT_USER] = userFollowed
                    activityClass[ACTIVITY_OTHER_USER] = PFUser.current()!
                    activityClass[ACTIVITY_TEXT] = "\(PFUser.current()![USER_FULLNAME]!) started following you"
                    activityClass.saveInBackground()
                } })
        }
    }
    
    func queryLikeStatus()
    {
        likesArray.removeAll()
        
        let query = PFQuery(className: LIKES_CLASS_NAME)
        query.whereKey(LIKES_LIKED_BY, equalTo: PFUser.current()!)
        query.whereKey(LIKES_POST_LIKED, equalTo: postObj)
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil
            {
                self.likesArray = objects!
                
                if self.likesArray.count == 0
                {
                    self.likeOutlet.setBackgroundImage(UIImage(named: "unlikedButt"), for: .normal)
                }
                else if self.likesArray.count > 0
                {
                    self.likeOutlet.setBackgroundImage(UIImage(named: "likedButt"), for: .normal)
                }
            }}
    }
    
    @IBAction func likeButt(_ sender: AnyObject)
    {
        // Query Likes
        likesArray.removeAll()
        
        let query = PFQuery(className: LIKES_CLASS_NAME)
        query.whereKey(LIKES_LIKED_BY, equalTo: PFUser.current()!)
        query.whereKey(LIKES_POST_LIKED, equalTo: postObj)
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil
            {
                self.likesArray = objects!
                
                var likesClass = PFObject(className: LIKES_CLASS_NAME)
                
                if self.likesArray.count == 0
                {
                    // LIKE POST
                    self.postObj.incrementKey(POSTS_LIKES, byAmount: 1)
                    let likeInt = Int(self.likesLabel.text!)! + 1
                    self.likesLabel.text = "\(likeInt)"
                    self.postObj.saveInBackground()
                    
                    likesClass[LIKES_LIKED_BY] = PFUser.current()
                    likesClass[LIKES_POST_LIKED] = self.postObj
                    likesClass.saveInBackground(block: { (success, error) in
                        
                        if error == nil
                        {
                            self.simpleAlert("You've liked this post!")
                            
                            self.likeOutlet.setBackgroundImage(UIImage(named: "likedButt"), for: .normal)
                            
                            
                            // Send Push notification
                            let userPointer = self.postObj[POSTS_USER_POINTER] as! PFUser
                            userPointer.fetchIfNeededInBackground(block: { (user, error) in
                                
                                let pushStr = "\(PFUser.current()![USER_FULLNAME]!) liked your post: \(self.postObj[POSTS_TEXT]!)"
                                
                                let data = [ "badge" : "Increment",
                                             "alert" : pushStr,
                                             "sound" : "bingbong.aiff"
                                ]
                                let request = [
                                    "someKey" : userPointer.objectId!,
                                    "data" : data
                                    ] as [String : Any]
                                PFCloud.callFunction(inBackground: "push", withParameters: request as [String : Any], block: { (results, error) in
                                    if error == nil {
                                        print ("\nPUSH SENT TO: \(userPointer[USER_USERNAME]!)\nMESSAGE: \(pushStr)\n")
                                    }
                                    else
                                    {
                                        print ("\(error!.localizedDescription)")
                                    }
                                })
                            })
                            
                            // Save Activity
                            let activityClass = PFObject(className: ACTIVITY_CLASS_NAME)
                            activityClass[ACTIVITY_CURRENT_USER] = userPointer
                            activityClass[ACTIVITY_OTHER_USER] = PFUser.current()!
                            activityClass[ACTIVITY_TEXT] = "\(PFUser.current()![USER_FULLNAME]!) liked your post: \(self.postObj[POSTS_TEXT]!)"
                            activityClass.saveInBackground()
                            
                        }})
                    
                    // UNLIKE POST
                }
                else if self.likesArray.count > 0
                {
                    self.postObj.incrementKey(POSTS_LIKES, byAmount: -1)
                    let likeInt = Int(self.likesLabel.text!)! - 1
                    self.likesLabel.text = "\(likeInt)"
                    self.postObj.saveInBackground()
                    
                    likesClass = self.likesArray[0]
                    likesClass.deleteInBackground {(success, error) -> Void in
                        if error == nil {
                            self.simpleAlert("You've unliked this post")
                            self.likeOutlet.setBackgroundImage(UIImage(named: "unlikedButt"), for: .normal)
                        } }
                }
            }
            else
            {
                self.simpleAlert("\(error!.localizedDescription)")
            }
        }
    }
    
    @IBAction func commentButt(_ sender: AnyObject)
    {
        let commVC = storyboard?.instantiateViewController(withIdentifier: "Comments") as! Comments
        commVC.postObj2 = postObj
        navigationController?.pushViewController(commVC, animated: true)
    }
    
    @IBAction func shareButt(_ sender: AnyObject)
    {
        let messageStr  = "Check out \(postObj[POSTS_TEXT]!) on #\(APP_NAME)"
        let img = postImage.image!
        
        let shareItems = [messageStr, img] as [Any]
        
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            let popOver = UIPopoverController(contentViewController: activityViewController)
            popOver.present(from: CGRect.zero, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
        else
        {
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func reportButt(_ sender: AnyObject)
    {
        let alert = UIAlertController(title: "Reporting a post",
                                      message: "Tell us a bit about the reason you're reporting this post.",
                                      preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Report", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields!.first
            
            self.postObj[POSTS_IS_REPORTED] = true
            self.postObj[POSTS_REPORT_MESSAGE] = textField!.text!
            self.postObj.saveInBackground(block: { (succ, error) in
                if error == nil
                {
                    self.simpleAlert("Thanks for reporting this post!\nWe'll check it out within 24 hours.")
                    _ = self.navigationController?.popViewController(animated: true)
                }
            })
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        
        // Add textField
        alert.addTextField { (textField: UITextField) -> Void in }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func userAvatarButt(_ sender: AnyObject)
    {
        let userPointer = postObj[POSTS_USER_POINTER] as! PFUser
        
        if PFUser.current()?.objectId==userPointer.objectId
        {
            let mpVC=storyboard?.instantiateViewController(withIdentifier:"Me") as! Me
            navigationController?.pushViewController(mpVC, animated:true)
        }
        else
        {
            userPointer.fetchIfNeededInBackground { (user, error) in
                let oupVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfile") as! OtherUserProfile
                oupVC.userObj = userPointer
                self.navigationController?.pushViewController(oupVC, animated: true)
            }
        }
    }
    
    @IBAction func imagePrevButt(_ sender: AnyObject)
    {
        imgPrev.image = postImage.image
        showImagePrevView()
    }
    
    func showImagePrevView()
    {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.previewView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.imgPrev.frame = self.previewView.frame
        }, completion: { (finished: Bool) in  })
    }
    func hideImagePrevView()
    {
        imgPrev.image = nil
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.previewView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.imgPrev.frame = self.previewView.frame
        }, completion: { (finished: Bool) in  })
    }
    
    @IBAction func dismissButt(_ sender: AnyObject)
    {
        hideImagePrevView()
    }
    
    func initAdMobBanner()
    {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
        adMobBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 320, height: 50)
        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        let request = GADRequest()
        adMobBannerView.load(request)
    }
    
    func hideBanner(_ banner: UIView)
    {
        UIView.beginAnimations("hideBanner", context: nil)
        
        banner.frame = CGRect(x: 0, y: self.view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }
    
    func showBanner(_ banner: UIView)
    {
        var h: CGFloat = 0
        // iPhone X
        if UIScreen.main.bounds.size.height == 812 { h = 20
        } else { h = 0 }
        
        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2,
                              y: view.frame.size.height - banner.frame.size.height - h,
                              width: banner.frame.size.width, height: banner.frame.size.height);
        UIView.commitAnimations()
        banner.isHidden = false
    }
    
    func adViewDidReceiveAd(_ view: GADBannerView)
    {
        print("AdMob loaded!")
        showBanner(adMobBannerView)
    }
    
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError)
    {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
    }
}
