/*-------------------------------------
 
 - Photofeed -
 
 created by cubycode @2017
 All Rights Reserved
 
 -------------------------------------*/

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


@available(iOS 8.2, *)
class OtherUserProfile: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate
{
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var followOutlet: UIButton!
    @IBOutlet weak var blockUserButton: UIButton!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var aboutMeTxt: UITextView!
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var followersOutlet: UIButton!
    @IBOutlet weak var followingOutlet: UIButton!
    @IBOutlet weak var userPostsTableView: UITableView!
    
    //Ad banners properties
    var adMobBannerView = GADBannerView()
    
    fileprivate var blockResult: PFObject?
    
    
    /* Variables */
    var userObj = PFUser()
    var postsArray = [PFObject]()
    var followArray = [PFObject]()
    var followersArray = [PFObject]()
    var followingArray = [PFObject]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        followOutlet.layer.borderColor=UIColor(red:255.0/255.0, green:87.0/255.0, blue:34.0/255.0, alpha:1.0).cgColor
        checkIfUserIsBlocked()
        
        //self.edgesForExtendedLayout = UIRectEdge()
        self.title="\(userObj[USER_FULLNAME]!)"
        navigationItem.backBarButtonItem=UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        // Setup views on iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            userPostsTableView.frame = CGRect(x: 0, y: 234, width: 460, height: view.frame.size.height-234 - 50)
            userPostsTableView.center.x = view.center.x
        }
        
        // Initialize a REPORT USER BarButton Item
        let butt = UIButton(type: .custom)
        butt.adjustsImageWhenHighlighted = false
        butt.frame = CGRect(x:0, y:0, width:20, height:20)
        butt.setBackgroundImage(UIImage(named:"block"), for: .normal)
        butt.addTarget(self, action: #selector(reportButton), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: butt)
        
        // Show users details
        fullnameLabel.text = "\(userObj[USER_FULLNAME]!)"
        if userObj[USER_ABOUT_ME] != nil
        {
            aboutMeTxt.text = "\(userObj[USER_ABOUT_ME]!)"
        }
        else
        {
            aboutMeTxt.text=""
        }
        
        avatarImage.layer.borderColor=UIColor.white.cgColor
        
        // Get avatar image
        avatarImage.image = UIImage(named: "logo")
        let imageFile = userObj[USER_AVATAR] as? PFFile
        imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.avatarImage.image = UIImage(data:imageData)
                } } })
        
        // Get avatar image
        let coverFile = userObj[USER_COVER_IMAGE] as? PFFile
        coverFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.coverImage.image = UIImage(data:imageData)
                } } })
        
        
        // Init ad banners
        initAdMobBanner()
        
        
        // Call queries
        queryUserPosts()
        queryFollow()
        queryFollowers()
    }
    
    func queryUserPosts()
    {
        postsArray.removeAll()
        
        let query = PFQuery(className: POSTS_CLASSE_NAME)
        query.whereKey(POSTS_USER_POINTER, equalTo: userObj)
        
        query.whereKey(POSTS_IS_REPORTED, equalTo: false)
        
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil
            {
                self.postsArray = objects!
                // Reload TableView
                self.userPostsTableView.reloadData()
                let attributedString=NSMutableAttributedString(string:"Posts (\(self.postsArray.count))", attributes:[.font:UIFont.systemFont(ofSize:13.0, weight:.semibold), .foregroundColor:UIColor(red:71.0/255.0, green:75.0/255.0, blue:78.0/255.0, alpha:1.0), .kern:0.25])
                attributedString.addAttribute(.foregroundColor, value:UIColor(red:146.0/255.0, green:148.0/255.0, blue:150.0/255.0, alpha:1.0), range:NSRange(location:6, length:"\(self.postsArray.count)".count+2))
                
                self.postsCountLabel.attributedText=attributedString
            }
            else
            {
                self.simpleAlert("\(error!.localizedDescription)")
            }}
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return postsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        var postsClass = PFObject(className: POSTS_CLASSE_NAME)
        postsClass = postsArray[(indexPath as NSIndexPath).section]
        
        // Get userPointer
        let userPointer = postsClass[POSTS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground { (user, error) in
            
        let city="\(postsClass[POSTS_CITY]!)"=="n/d" ? "" : "\(postsClass[POSTS_CITY]!)"
        
        let string=city=="" ? "\(userPointer[USER_FULLNAME]!) added a new photo" : "\(userPointer[USER_FULLNAME]!) added a new photo at \(city)"
        
        let attributedString1=NSMutableAttributedString(string:string, attributes:[.font:UIFont.systemFont(ofSize:13.0, weight:.medium), .foregroundColor:UIColor(red:146.0/255.0, green:148.0/255.0, blue:150.0/255.0, alpha:1.0), .kern:0.25])
        attributedString1.addAttributes([.foregroundColor:UIColor(red:71.0/255.0, green:75.0/255.0, blue:78.0/255.0, alpha:1.0), .kern:0.27], range:NSRange(location:0, length:"\(userPointer[USER_FULLNAME]!)".count))
        attributedString1.addAttribute(.foregroundColor, value:UIColor(red:1.0, green:87.0/255.0, blue:34.0/255.0, alpha:1.0), range:NSRange(location:string.count-city.count, length:city.count))
        
        cell.fullnameLabel.attributedText=attributedString1

        let date = postsClass.createdAt
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMM dd yyyy"
        let dateStr = dateFormat.string(from: date!)
        cell.dateLabel.text = dateStr
        
        cell.avatarImage.image = UIImage(named: "logo")
        let avatarFile = userPointer[USER_AVATAR] as? PFFile
        avatarFile?.getDataInBackground { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.avatarImage.image = UIImage(data:imageData)
                }}}
        
        cell.postLabel.text = "\(postsClass[POSTS_TEXT]!)"
        
        let likes=postsClass[POSTS_LIKES] != nil ? "\(postsClass[POSTS_LIKES]!)" : "0"
        
        let attributedString=NSMutableAttributedString(string:"\(likes) Likes", attributes:[.font:UIFont.systemFont(ofSize:13.0, weight:.regular), .foregroundColor:UIColor(white:153.0/255.0, alpha:1.0), .kern:0.25])
        attributedString.addAttributes([.font:UIFont.systemFont(ofSize:13.0, weight:.bold), .foregroundColor:UIColor(red:71.0/255.0, green:75.0/255.0, blue:78.0/255.0, alpha:1.0), .kern:0.27], range:NSRange(location:0, length:likes.count))
        
        cell.likesLabel.attributedText=attributedString

        let imageFile = postsClass[POSTS_IMAGE] as? PFFile
        imageFile?.getDataInBackground { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.postImage.image = UIImage(data:imageData)
                }}}
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 444
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var postsClass = PFObject(className: POSTS_CLASSE_NAME)
        postsClass = postsArray[(indexPath as NSIndexPath).section]
        
        let pdVC = storyboard?.instantiateViewController(withIdentifier: "PostDetails") as! PostDetails
        pdVC.postObj = postsClass
        navigationController?.pushViewController(pdVC, animated: true)
    }
    
    func queryFollowers()
    {
        followersArray.removeAll()
        
        let query = PFQuery(className: FOLLOW_CLASS_NAME)
        query.whereKey(FOLLOW_IS_FOLLOWING, equalTo: userObj)
        query.countObjectsInBackground { (amount, error) -> Void in
            if error == nil {
                let attributedString=NSMutableAttributedString(string:"Followers (\(amount))", attributes:[.font:UIFont.systemFont(ofSize:13.0, weight:.semibold), .foregroundColor:UIColor(red:71.0/255.0, green:75.0/255.0, blue:78.0/255.0, alpha:1.0), .kern:0.25])
                attributedString.addAttribute(.foregroundColor, value:UIColor(red:146.0/255.0, green:148.0/255.0, blue:150.0/255.0, alpha:1.0), range:NSRange(location:10, length:"\(amount)".count+2))
                
                self.followersOutlet.setAttributedTitle(attributedString, for:.normal)
                self.queryFollowing()
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
            }}
    }
    
    func queryFollowing()
    {
        followingArray.removeAll()
        
        let query = PFQuery(className: FOLLOW_CLASS_NAME)
        query.whereKey(FOLLOW_A_USER, equalTo: userObj)
        query.countObjectsInBackground { (amount, error) -> Void in
            if error == nil
            {
                let attributedString=NSMutableAttributedString(string:"Following (\(amount))", attributes:[.font:UIFont.systemFont(ofSize:13.0, weight:.semibold), .foregroundColor:UIColor(red:71.0/255.0, green:75.0/255.0, blue:78.0/255.0, alpha:1.0), .kern:0.25])
                attributedString.addAttribute(.foregroundColor, value:UIColor(red:146.0/255.0, green:148.0/255.0, blue:150.0/255.0, alpha:1.0), range:NSRange(location:10, length:"\(amount)".count+2))
                
                self.followingOutlet.setAttributedTitle(attributedString, for:.normal)
            }
            else
            {
                self.simpleAlert("\(error!.localizedDescription)")
            }
        }
    }
    
    func checkIfUserIsBlocked()
    {
        guard let currentUser = PFUser.current() else {
            return
        }
        let query = PFQuery(className: BLOCK_USER_CLASS_NAME)
        query.whereKey("aUser", equalTo: currentUser)
        query.whereKey("isBlocked", equalTo: userObj)
        
        query.findObjectsInBackground { (result, error) in
            if error != nil {
                self.simpleAlert("\(error!.localizedDescription)")
            } else {
                self.blockResult = result?.first
                
                let isBlocked = !(result ?? []).isEmpty
                let title = isBlocked ? "Unblock" : "Block"
                self.blockUserButton.setTitle(title, for: .normal)
                
                self.blockUserButton.layer.borderColor=UIColor(red:255.0/255.0, green:87.0/255.0, blue:34.0/255.0, alpha:1.0).cgColor
                
                self.blockUserButton.isHidden=false
            }
        }
    }
    
    @IBAction func blockAction(_ sender: UIButton)
    {
        let blockClass = PFObject(className: "BlockUser")
        let currentUser = PFUser.current()
        
        // UNFOLLOW THIS USER
        if blockUserButton.titleLabel!.text == "Block"
        {
            
            // Save follower and followed
            blockClass["aUser"] = currentUser
            blockClass["isBlocked"] = userObj
            
            // Saving block
            blockClass.saveInBackground(block: { (success, error) -> Void in
                if error == nil {
                    var followClass = PFObject(className: FOLLOW_CLASS_NAME)
                    
                    // UNFOLLOW THIS USER
                    followClass = self.followArray[0]
                    followClass.deleteInBackground {(success, error) -> Void in
                        if error == nil {
                            self.blockUserButton.setTitle("Unblock", for: .normal)
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                }})
            
            // FOLLOW THIS USER
        }
        else if blockUserButton.titleLabel!.text == "Unblock"
        {
            blockResult?.deleteInBackground()
            blockUserButton.setTitle("Block", for: .normal)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func queryFollow()
    {
        followArray.removeAll()
        let query = PFQuery(className: FOLLOW_CLASS_NAME)
        query.whereKey(FOLLOW_A_USER, equalTo: PFUser.current()!)
        query.whereKey(FOLLOW_IS_FOLLOWING, equalTo: userObj)
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil
            {
                self.followArray = objects!
                
                if self.followArray.count > 0
                {
                    self.followOutlet.setTitle("Unfollow", for:.normal)
                }
                else if self.followArray.count == 0
                {
                    self.followOutlet.setTitle("Follow", for:.normal)
                }
            }
            else
            {
                self.simpleAlert("\(error!.localizedDescription)")
            }
        }
    }
    
    @IBAction func followButt(_ sender: AnyObject)
    {
        let butt = sender as! UIButton
        
        var followClass = PFObject(className: FOLLOW_CLASS_NAME)
        let currentUser = PFUser.current()
        
        if butt.titleLabel!.text == "Unfollow"
        {
            followClass = followArray[0]
            followClass.deleteInBackground {(success, error) -> Void in
                if error == nil {
                    butt.setTitle("Follow", for: .normal)
                } }
        }
        else if butt.titleLabel!.text == "Follow"
        {
            // Save follower and followed
            followClass[FOLLOW_A_USER] = currentUser
            followClass[FOLLOW_IS_FOLLOWING] = userObj
            
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
                        "someKey" : self.userObj.objectId!,
                        "data" : data
                        ] as [String : Any]
                    PFCloud.callFunction(inBackground: "push", withParameters: request as [String : Any], block: { (results, error) in
                        if error == nil {
                            print ("\nPUSH SENT TO: \(self.userObj[USER_USERNAME]!)\nMESSAGE: \(pushStr)\n")
                        } else {
                            print ("\(error!.localizedDescription)")
                        }})
                    
                    // Save Activity
                    let activityClass = PFObject(className: ACTIVITY_CLASS_NAME)
                    activityClass[ACTIVITY_CURRENT_USER] = self.userObj
                    activityClass[ACTIVITY_OTHER_USER] = PFUser.current()!
                    activityClass[ACTIVITY_TEXT] = "\(PFUser.current()![USER_FULLNAME]!) started following you"
                    activityClass.saveInBackground()
                }})
        }
    }
    
    @IBAction func showFollowersButt(_ sender: AnyObject)
    {
        let butt = sender as! UIButton
        
        let fVC = storyboard?.instantiateViewController(withIdentifier: "Follow") as! Follow
        if butt.tag == 0 { fVC.checkFollowers = true
        } else { fVC.checkFollowers = false }
        fVC.fUser = userObj
        
        navigationController?.pushViewController(fVC, animated: true)
    }
    
    @objc func reportButton()
    {
        let alert = UIAlertController(title: "Reporting a User",
                                      message: "Tell us a bit about the reason you're reporting this User:",
                                      preferredStyle: .alert)
        
        // REPORT ACTION
        let ok = UIAlertAction(title: "Report", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields!.first
            self.showHUD()
            
            
            let request = [
                "userId" : self.userObj.objectId!,
                "reportMessage" : textField!.text!
                ] as [String : Any]
            
            PFCloud.callFunction(inBackground: "reportUser", withParameters: request as [String : Any], block: { (results, error) in
                if error == nil {
                    print ("\(self.userObj[USER_FULLNAME]!) has been reported!")
                    
                    self.simpleAlert("Thanks for reporting this User, we'll check it out withint 24 hours!")
                    self.hideHUD()
                    
                    // Automatically Report all posts of this User
                    var postsArr = [PFObject]()
                    let query = PFQuery(className: POSTS_CLASSE_NAME)
                    query.whereKey(POSTS_USER_POINTER, equalTo: self.userObj)
                    query.findObjectsInBackground { (objects, error)-> Void in
                        if error == nil {
                            postsArr = objects!
                            
                            for i in 0..<postsArr.count {
                                var pObj = PFObject(className: POSTS_CLASSE_NAME)
                                pObj = postsArr[i]
                                
                                pObj[POSTS_IS_REPORTED] = true
                                pObj[POSTS_REPORT_MESSAGE] = "*Reported automatically after User reporting"
                                pObj.saveInBackground()
                            }
                        }}
                    
                    
                    // error in Cloud Code
                } else {
                    print ("\(error!.localizedDescription)")
                    self.hideHUD()
                }})
            
            
        })// end REPORT ACTION
        
        
        // Cancel action
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        
        // Add textField
        alert.addTextField { (textField: UITextField) -> Void in }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
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
