/*-------------------------------------
 
 - Photofeed -
 
 created by cubycode @2017
 All Rights Reserved
 
 -------------------------------------*/


import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox

class PostCell: UITableViewCell
{
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var showUserOutlet: UIButton!
}

@available(iOS 8.2, *)
class Home: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,
    GADBannerViewDelegate
{
    /* Views */
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var noPostsView: UIView!
    
    //Ad banners properties
    var adMobBannerView = GADBannerView()
    
    /* Variables */
    var postsArray = [PFObject]()
    var followArray = [PFObject]()
    var refreshControl=UIRefreshControl()
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let meProfilePic=UIImageView(frame:CGRect(x:0, y:0, width:30, height:30))
        meProfilePic.image=UIImage(named:"logo")
        
        let meProfileBtn=UIButton(frame:CGRect(x:0, y:0, width:30, height:30))
        meProfileBtn.addTarget(self, action:#selector(myProfile), for:.touchUpInside)
        
        let meProfileView=UIView(frame:CGRect(x:0, y:0, width:30, height:30))
        meProfileView.addSubview(meProfilePic)
        meProfileView.addSubview(meProfileBtn)
        meProfileView.layer.cornerRadius=15
        meProfileView.clipsToBounds=true
        
        navigationItem.leftBarButtonItem=UIBarButtonItem(customView:meProfileView)
        
        if PFUser.current() != nil
        {
            let currentUser=PFUser.current()!
            let imageFile=currentUser[USER_AVATAR] as? PFFile
            imageFile?.getDataInBackground(block:{(imageData, error)->Void in
                if error==nil
                {
                    if let imageData=imageData
                    {
                        meProfilePic.image=UIImage(data:imageData)
                    }
                }})
        }
        
        refreshControl.addTarget(self, action:#selector(refreshButt), for:.valueChanged)
        refreshControl.tintColor=UIColor(red:1.0, green:87.0/255.0, blue:34.0/255.0, alpha:1.0)
        postsTableView.addSubview(refreshControl)
        
        queryPostsOfFollowing()
    }
    
    @objc func myProfile()
    {
        let mpVC=storyboard?.instantiateViewController(withIdentifier:"Me") as! Me
        navigationController?.pushViewController(mpVC, animated:true)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if PFUser.current() == nil
        {
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
            present(loginVC, animated: true, completion: nil)
            
        }
        else
        {
            // Associate the device with a user for Push Notifications
            let installation = PFInstallation.current()
            installation?["username"] = PFUser.current()!.username
            installation?["userID"] = PFUser.current()!.objectId!
            installation?.saveInBackground(block: { (succ, error) in
                if error == nil {
                    print("PUSH REGISTERED FOR: \(PFUser.current()!.username!)")
                }})
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationItem.titleView=UIImageView(image: UIImage(named: "logoNavBar"))
        navigationItem.backBarButtonItem=UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        // Setup views on iPad
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            postsTableView.frame = CGRect(x: 0, y: 0, width: 460, height: view.frame.size.height - 100)
            postsTableView.center = view.center
        }
        
        if PFUser.current() != nil
        {
            queryPostsOfFollowing()
        }
        
        initAdMobBanner()
    }
    
    @IBAction func refreshButt(_ sender: AnyObject)
    {
        queryPostsOfFollowing()
        refreshControl.endRefreshing()
    }
    
    func queryPostsOfFollowing()
    {
        postsArray.removeAll()
        followArray.removeAll()
        noPostsView.isHidden = true
        showHUD()
        
        
        let query = PFQuery(className: FOLLOW_CLASS_NAME)
        
        guard PFUser.current() != nil else {
            return
        }
        
        query.whereKey(FOLLOW_A_USER, equalTo: PFUser.current()!)
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.followArray = objects!
                
                // You're following someone:
                if self.followArray.count > 0 {
                    
                    for i in 0..<self.followArray.count {
                        
                        DispatchQueue.main.async(execute: {
                            
                            var followClass = PFObject(className: FOLLOW_CLASS_NAME)
                            followClass = self.followArray[i]
                            
                            // Get userPointer
                            let userPointer = followClass[FOLLOW_IS_FOLLOWING] as! PFUser
                            userPointer.fetchIfNeededInBackground(block: { (user, error) in
                                
                                if userPointer[USER_IS_REPORTED] as! Bool == false {
                                    let query = PFQuery(className: POSTS_CLASSE_NAME)
                                    query.whereKey(POSTS_USER_POINTER, equalTo: userPointer)
                                    query.whereKey(POSTS_IS_REPORTED, equalTo: false)
                                    query.order(byDescending: "createdAt")
                                    query.findObjectsInBackground { (objects, error)-> Void in
                                        if error == nil {
                                            if let objects = objects  {
                                                for post in objects {
                                                    self.postsArray.append(post)
                                                }}
                                            
                                            // Reload TableView (if there are some posts)
                                            self.postsTableView.reloadData()
                                            self.hideHUD()
                                        }}
                                }
                            })
                        })// end DISPATCH_ASYNC
                    }// end FOR LOOP
                    
                    
                    // No following: Show noPostsView
                } else if self.followArray.count == 0 {
                    self.noPostsView.isHidden = false
                    self.postsTableView.reloadData()
                    self.hideHUD()
                }
                
                
                // Error
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
                self.postsTableView.reloadData()
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
                
            cell.avatarImage.image = UIImage(named: "logo")
            let avatarFile = userPointer[USER_AVATAR] as? PFFile
            avatarFile?.getDataInBackground { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.avatarImage.image = UIImage(data:imageData)
                    }}}
            
            cell.postLabel.text = "\(postsClass[POSTS_TEXT]!)"
            
            
            // Get Post's data
            let postDate = postsClass.createdAt
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM dd yyyy"
            cell.dateLabel.text = dateFormat.string(from: postDate!)
            
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
            
            // Assign tags to buttons
            cell.showUserOutlet.tag = (indexPath as NSIndexPath).section
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
    
    @IBAction func userAvatarButt(_ sender: AnyObject)
    {
        let butt = sender as! UIButton
        
        var postsClass = PFObject(className: POSTS_CLASSE_NAME)
        postsClass = postsArray[butt.tag]
        
        let userPointer = postsClass[POSTS_USER_POINTER] as! PFUser
        
        if PFUser.current()?.objectId==userPointer.objectId
        {
            myProfile()
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
    
    
    // Hide the banner
    func hideBanner(_ banner: UIView)
    {
        UIView.beginAnimations("hideBanner", context: nil)
        
        banner.frame = CGRect(x: 0, y: self.view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
        
    }
    
    // Show the banner
    func showBanner(_ banner: UIView)
    {
        var h: CGFloat = 0
        // iPhone X
        if UIScreen.main.bounds.size.height == 812 { h = 84
        } else { h = 48 }
        
        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2,
                              y: view.frame.size.height - banner.frame.size.height - h,
                              width: banner.frame.size.width, height: banner.frame.size.height);
        UIView.commitAnimations()
        banner.isHidden = false
    }
    
    
    
    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView)
    {
        print("AdMob loaded!")
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError)
    {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
    }
}
