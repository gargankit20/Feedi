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
class SearchVC: UIViewController,
    UISearchBarDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    GADBannerViewDelegate
{
    @IBOutlet weak var postsTableView: UITableView!
    var searchBar: UISearchBar!
    
    //Ad banners properties
    var adMobBannerView = GADBannerView()
    
    /* Variables */
    var postsArray = [PFObject]()
    
    override func viewDidAppear(_ animated: Bool)
    {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Setup views on iPad
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            postsTableView.frame = CGRect(x: 0, y: 0, width: 460, height: view.frame.size.height - 100)
            postsTableView.center = view.center
        }
        
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

        searchBar=UISearchBar()
        searchBar.frame=CGRect(x:searchBar.frame.origin.x, y:searchBar.frame.origin.y, width:searchBar.frame.size.width, height:44)
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder="Search"
        searchBar.delegate=self
        
        navigationItem.titleView=searchBar
        navigationItem.backBarButtonItem=UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        initAdMobBanner()
        queryPosts("")
    }
    
    @objc func myProfile()
    {
        let mpVC=storyboard?.instantiateViewController(withIdentifier:"Me") as! Me
        navigationController?.pushViewController(mpVC, animated:true)
    }

    @IBAction func popularButt(_ sender: AnyObject)
    {
        queryPosts("")
    }
    
    func queryPosts(_ text:String)
    {
        postsArray.removeAll()
        showHUD()
        
        let query = PFQuery(className: POSTS_CLASSE_NAME)
        if text != ""
        {
            let keywords = text.lowercased().components(separatedBy: " ") as [String]
            query.whereKey(POSTS_KEYWORDS, containedIn: keywords)
            query.order(byDescending: "createdAt")
            
        }
        else
        {
            query.limit = 50
            query.order(byDescending: POSTS_LIKES)
        }
        
        query.whereKey(POSTS_IS_REPORTED, equalTo: false)
        
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.postsArray = objects!
                // Reload TableView
                self.postsTableView.reloadData()
                self.hideHUD()
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        queryPosts(searchBar.text!)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.text = ""
        searchBar.resignFirstResponder()
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
            let avatarImage = userPointer[USER_AVATAR] as? PFFile
            avatarImage?.getDataInBackground { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.avatarImage.image = UIImage(data:imageData)
                    }}}
            
            let date = postsClass.createdAt
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM dd yyyy"
            let dateStr = dateFormat.string(from: date!)
            cell.dateLabel.text = dateStr
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var postsClass = PFObject(className: POSTS_CLASSE_NAME)
        postsClass = postsArray[(indexPath as NSIndexPath).section]
        
        let pdVC = storyboard?.instantiateViewController(withIdentifier: "PostDetails") as! PostDetails
        pdVC.postObj = postsClass
        navigationController?.pushViewController(pdVC, animated: true)
    }
    
    // MARK: - USER AVATAR BUTTON
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
        if UIScreen.main.bounds.size.height == 812 { h = 84
        } else { h = 48 }
        
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
