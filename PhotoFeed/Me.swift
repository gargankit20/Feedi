/*-------------------------------------
 
 - Photofeed -
 
 created by cubycode @2017
 All Rights Reserved
 
 -------------------------------------*/


import UIKit
import Parse


@available(iOS 8.2, *)
class Me: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    /* Views */
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var aboutMeTxt: UITextView!
    @IBOutlet weak var editProfileOutlet: UIButton!
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var followersOutlet: UIButton!
    @IBOutlet weak var followingOutlet: UIButton!
    @IBOutlet weak var logoutOutlet: UIButton!
    @IBOutlet weak var postsCountBtn:UIButton!
    @IBOutlet weak var likesCountBtn:UIButton!
    
    /* Variables */
    var postsArray = [PFObject]()
    var selected=0
    var likesArray = [PFObject]()
    var followersArray = [PFObject]()
    var followingArray = [PFObject]()
    
    override func viewDidAppear(_ animated: Bool)
    {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let currentUser = PFUser.current()!
        fullNameLabel.text = "\(currentUser[USER_FULLNAME]!)"
        navigationItem.backBarButtonItem=UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        logoutOutlet.layer.borderColor=UIColor(red:255.0/255.0, green:87.0/255.0, blue:34.0/255.0, alpha:1.0).cgColor
        editProfileOutlet.layer.borderColor=UIColor(red:255.0/255.0, green:87.0/255.0, blue:34.0/255.0, alpha:1.0).cgColor
        
        avatarImage.layer.borderColor=UIColor.white.cgColor
        
        avatarImage.image = UIImage(named: "logo")
        let imageFile = currentUser[USER_AVATAR] as? PFFile
        imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.avatarImage.image = UIImage(data:imageData)
                } } })
        
        let coverFile = currentUser[USER_COVER_IMAGE] as? PFFile
        coverFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.coverImage.image = UIImage(data:imageData)
                } } })
        
        if currentUser[USER_ABOUT_ME] != nil { aboutMeTxt.text = "\(currentUser[USER_ABOUT_ME]!)"
        } else { aboutMeTxt.text = "" }
        
        // Call queries
        queryMyPosts()
        postLikes()
        queryFollowers()
        queryFollowing()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Setup views on iPad
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            postsTableView.frame = CGRect(x: 0, y: 314, width: 460, height: view.frame.size.height-314 - 50)
            postsTableView.center.x = view.center.x
        }
    }
    
    @IBAction func buttonTapped(_ sender:UIButton)
    {
        if sender.tag==0
        {
            selected=0
            queryMyPosts()
        }
        else
        {
            selected=1
            queryMyLikes()
        }
    }
    
    func queryMyPosts()
    {
        postsArray.removeAll()
        likesArray.removeAll()
        postsTableView.reloadData()
        showHUD()
        
        let query = PFQuery(className: POSTS_CLASSE_NAME)
        query.whereKey(POSTS_USER_POINTER, equalTo: PFUser.current()!)
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.postsArray = objects!
                // Reload TableView
                self.postsTableView.reloadData()
                self.hideHUD()
                
                let attributedString=NSMutableAttributedString(string:"Posts (\(self.postsArray.count))", attributes:[.font:UIFont.systemFont(ofSize:13.0, weight:.semibold), .foregroundColor:UIColor(red:71.0/255.0, green:75.0/255.0, blue:78.0/255.0, alpha:1.0), .kern:0.25])
                attributedString.addAttribute(.foregroundColor, value:UIColor(red:146.0/255.0, green:148.0/255.0, blue:150.0/255.0, alpha:1.0), range:NSRange(location:6, length:"\(self.postsArray.count)".count+2))
                
                self.postsCountBtn.setAttributedTitle(attributedString, for:.normal)
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            } }
    }
    
    func postLikes()
    {
        let query = PFQuery(className: LIKES_CLASS_NAME)
        query.whereKey(LIKES_LIKED_BY, equalTo: PFUser.current()!)
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.likesArray = objects!
                let attributedString=NSMutableAttributedString(string:"Likes (\(self.likesArray.count))", attributes:[.font:UIFont.systemFont(ofSize:13.0, weight:.semibold), .foregroundColor:UIColor(red:71.0/255.0, green:75.0/255.0, blue:78.0/255.0, alpha:1.0), .kern:0.25])
                attributedString.addAttribute(.foregroundColor, value:UIColor(red:146.0/255.0, green:148.0/255.0, blue:150.0/255.0, alpha:1.0), range:NSRange(location:6, length:"\(self.likesArray.count)".count+2))
                
                self.likesCountBtn.setAttributedTitle(attributedString, for:.normal)
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
            }}
    }
    
    func queryMyLikes()
    {
        postsArray.removeAll()
        likesArray.removeAll()
        postsTableView.reloadData()
        showHUD()
        
        let query = PFQuery(className: LIKES_CLASS_NAME)
        query.whereKey(LIKES_LIKED_BY, equalTo: PFUser.current()!)
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.likesArray = objects!
                self.postsTableView.reloadData()
                self.hideHUD()
                let attributedString=NSMutableAttributedString(string:"Likes (\(self.likesArray.count))", attributes:[.font:UIFont.systemFont(ofSize:13.0, weight:.semibold), .foregroundColor:UIColor(red:71.0/255.0, green:75.0/255.0, blue:78.0/255.0, alpha:1.0), .kern:0.25])
                attributedString.addAttribute(.foregroundColor, value:UIColor(red:146.0/255.0, green:148.0/255.0, blue:150.0/255.0, alpha:1.0), range:NSRange(location:6, length:"\(self.likesArray.count)".count+2))
                
                self.likesCountBtn.setAttributedTitle(attributedString, for:.normal)
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
    }
    
    func queryFollowers()
    {
        followersArray.removeAll()
        
        let query = PFQuery(className: FOLLOW_CLASS_NAME)
        query.whereKey(FOLLOW_IS_FOLLOWING, equalTo: PFUser.current()!)
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
        query.whereKey(FOLLOW_A_USER, equalTo: PFUser.current()!)
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
            }}
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        var sections = 0
        if selected==0
        {
            sections=postsArray.count
        }
        else
        {
            sections=likesArray.count
        }
        
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        // SHOW MY POSTS
        if selected==0
        {
            var postsClass = PFObject(className: POSTS_CLASSE_NAME)
            postsClass = postsArray[(indexPath as NSIndexPath).section]
            
            // Get userPointer
            let userPointer = postsClass[POSTS_USER_POINTER] as! PFUser
            userPointer.fetchIfNeededInBackground(block: { (user, error) in
                
                let city="\(postsClass[POSTS_CITY]!)"=="n/d" ? "" : "\(postsClass[POSTS_CITY]!)"
                
                let string=city=="" ? "\(userPointer[USER_FULLNAME]!) added a new photo" : "\(userPointer[USER_FULLNAME]!) added a new photo at \(city)"
                
                let attributedString1=NSMutableAttributedString(string:string, attributes:[.font:UIFont.systemFont(ofSize:13.0, weight:.medium), .foregroundColor:UIColor(red:146.0/255.0, green:148.0/255.0, blue:150.0/255.0, alpha:1.0), .kern:0.25])
                attributedString1.addAttributes([.foregroundColor:UIColor(red:71.0/255.0, green:75.0/255.0, blue:78.0/255.0, alpha:1.0), .kern:0.27], range:NSRange(location:0, length:"\(userPointer[USER_FULLNAME]!)".count))
                attributedString1.addAttribute(.foregroundColor, value:UIColor(red:1.0, green:87.0/255.0, blue:34.0/255.0, alpha:1.0), range:NSRange(location:string.count-city.count, length:city.count))
                
                cell.fullnameLabel.attributedText=attributedString1

                // Gest post data
                let date = postsClass.createdAt
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "MMM dd yyyy"
                let dateStr = dateFormat.string(from: date!)
                cell.dateLabel.text = dateStr
                
                cell.postLabel.text = "\(postsClass[POSTS_TEXT]!)"
                
                cell.avatarImage.image = UIImage(named: "logo")
                let avatarFile = userPointer[USER_AVATAR] as? PFFile
                avatarFile?.getDataInBackground { (imageData, error) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.avatarImage.image = UIImage(data:imageData)
                        }}}
                
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
                
                cell.showUserOutlet.isEnabled = false
            })
        }
        else
        {
            var likesClass = PFObject(className: LIKES_CLASS_NAME)
            likesClass = likesArray[(indexPath as NSIndexPath).section]
            
            // Get postPointer
            let postPointer = likesClass[LIKES_POST_LIKED] as! PFObject
            postPointer.fetchIfNeededInBackground(block: { (post, error) in
                
                // Get userPointer
                let userPointer = postPointer[POSTS_USER_POINTER] as! PFUser
                userPointer.fetchIfNeededInBackground(block: { (user, error) in
                    
                    if postPointer[POSTS_IS_REPORTED] as! Bool == false {
                        
                        let city="\(postPointer[POSTS_CITY]!)"=="n/d" ? "" : "\(postPointer[POSTS_CITY]!)"
                        
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
                        
                        // Gest post data
                        let date = postPointer.createdAt
                        let dateFormat = DateFormatter()
                        dateFormat.dateFormat = "MMM dd yyyy"
                        let dateStr = dateFormat.string(from: date!)
                        cell.dateLabel.text = dateStr
                        
                        cell.postLabel.text = "\(postPointer[POSTS_TEXT]!)"
                        
                        let likes=postPointer[POSTS_LIKES] != nil ? "\(postPointer[POSTS_LIKES]!)" : "0"
                        
                        let attributedString=NSMutableAttributedString(string:"\(likes) Likes", attributes:[.font:UIFont.systemFont(ofSize:13.0, weight:.regular), .foregroundColor:UIColor(white:153.0/255.0, alpha:1.0), .kern:0.25])
                        attributedString.addAttributes([.font:UIFont.systemFont(ofSize:13.0, weight:.bold), .foregroundColor:UIColor(red:71.0/255.0, green:75.0/255.0, blue:78.0/255.0, alpha:1.0), .kern:0.27], range:NSRange(location:0, length:likes.count))
                        
                        cell.likesLabel.attributedText=attributedString
                        
                        let imageFile = postPointer[POSTS_IMAGE] as? PFFile
                        imageFile?.getDataInBackground { (imageData, error) -> Void in
                            if error == nil {
                                if let imageData = imageData {
                                    cell.postImage.image = UIImage(data:imageData)
                                }}}
                        
                        
                        // Assign tags to buttons
                        cell.showUserOutlet.tag = (indexPath as NSIndexPath).section
                        cell.showUserOutlet.isEnabled = true
                        
                        // THIS POST IS REPORTED
                    } else {
                        cell.fullnameLabel.text = "THIS POST IS REPORTED"
                        cell.avatarImage.image = UIImage(named: "logo")
                        cell.dateLabel.text = ""
                        cell.postLabel.text = ""
                        cell.likesLabel.text = ""
                        cell.postImage.image = UIImage(named: "logo")
                    }
                })
                
            })
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
        
        // MY POSTS
        if selected==0
        {
            postsClass = PFObject(className: POSTS_CLASSE_NAME)
            postsClass = postsArray[(indexPath as NSIndexPath).section]
            
            let pdVC = self.storyboard?.instantiateViewController(withIdentifier: "PostDetails") as! PostDetails
            pdVC.postObj = postsClass
            self.navigationController?.pushViewController(pdVC, animated: true)
        }
        else
        {
            var likesClass = PFObject(className: LIKES_CLASS_NAME)
            likesClass = likesArray[(indexPath as NSIndexPath).section]
            postsClass = likesClass[LIKES_POST_LIKED] as! PFObject
            postsClass.fetchInBackground(block: { (object, error) in
                if error == nil {
                    if postsClass[POSTS_IS_REPORTED] as! Bool == false {
                        let pdVC = self.storyboard?.instantiateViewController(withIdentifier: "PostDetails") as! PostDetails
                        pdVC.postObj = postsClass
                        self.navigationController?.pushViewController(pdVC, animated: true)
                        
                        // POST HAS BEEN REPORTED, NO ACCESS!
                    } else { self.simpleAlert("This Post has been reported, you can't access its details.") }
                }})
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        var canEdit = Bool()
        if selected==0
        {
            canEdit = true
        }
        else
        {
            canEdit = false
        }
        
        return canEdit
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            var postsClass = PFObject(className: POSTS_CLASSE_NAME)
            postsClass = postsArray[(indexPath as NSIndexPath).section]
            
            // DELETE ALL LIKES OF THIS RECIPE (if any)
            likesArray.removeAll()
            let query = PFQuery(className: LIKES_CLASS_NAME)
            query.whereKey(LIKES_POST_LIKED, equalTo: postsClass)
            query.findObjectsInBackground { (objects, error)-> Void in
                if error == nil {
                    self.likesArray = objects!
                    
                    DispatchQueue.main.async(execute: {
                        if self.likesArray.count > 0 {
                            for i in 0..<self.likesArray.count {
                                var likesClass = PFObject(className: LIKES_CLASS_NAME)
                                likesClass = self.likesArray[i]
                                likesClass.deleteInBackground()
                            }
                        }
                    })
                    
                    // THEN DELETE THE POST
                    postsClass.deleteInBackground {(success, error) -> Void in
                        if error == nil {
                            self.postsArray.remove(at: (indexPath as NSIndexPath).section)
                            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                            
                        } else {
                            self.simpleAlert("\(error!.localizedDescription)")
                        }}
                }}}
    }
    
    @IBAction func userAvatarButt(_ sender: AnyObject)
    {
        let butt = sender as! UIButton
        
        var likesClass = PFObject(className: LIKES_CLASS_NAME)
        likesClass = likesArray[butt.tag]
        
        // Get postPointer
        let postsPointer = likesClass[LIKES_POST_LIKED] as! PFObject
        postsPointer.fetchIfNeededInBackground { (post, error) in
            
            // Get userPointer
            let userPointer = postsPointer[POSTS_USER_POINTER] as! PFUser
            
            if PFUser.current()?.objectId==userPointer.objectId
            {
                let mpVC=self.storyboard?.instantiateViewController(withIdentifier:"Me") as! Me
                self.navigationController?.pushViewController(mpVC, animated:true)
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
    }
    
    @IBAction func editProfileButt(_ sender: AnyObject)
    {
        let epVC = storyboard?.instantiateViewController(withIdentifier: "EditProfile") as! EditProfile
        navigationController?.pushViewController(epVC, animated: true)
    }
    
    @IBAction func showFollowersButt(_ sender: AnyObject)
    {
        let butt = sender as! UIButton
        
        let fVC = storyboard?.instantiateViewController(withIdentifier: "Follow") as! Follow
        if butt.tag == 0 { fVC.checkFollowers = true
        } else { fVC.checkFollowers = false }
        fVC.fUser = PFUser.current()!
        
        navigationController?.pushViewController(fVC, animated: true)
    }
    
    @IBAction func logoutButt(_ sender: AnyObject)
    {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Are you sure you want to logout?",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let ok = UIAlertAction(title: "Logout", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.showHUD()
            
            PFUser.logOutInBackground { (error) -> Void in
                if error == nil {
                    // Show the Login screen
                    let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
                    self.present(loginVC, animated: true, completion: nil)
                }
                self.hideHUD()
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in })
        alert.addAction(ok); alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
