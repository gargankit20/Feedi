/*-------------------------------------
 
 - Photofeed -
 
 created by cubycode @2017
 All Rights Reserved
 
 -------------------------------------*/

import UIKit
import Parse

// MARK: - FOLLOW CUSTOM CELL
class FollowCell: UITableViewCell
{
    @IBOutlet weak var fAvatarImage: UIImageView!
    @IBOutlet weak var fNameLabel: UILabel!
}

@available(iOS 8.2, *)
class Follow: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var followTableView: UITableView!
    
    var checkFollowers = Bool()
    var followArray = [PFObject]()
    var fUser = PFUser()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        followArray.removeAll()
        showHUD()
        
        // QUERY FOLLOWERS
        if checkFollowers
        {
            self.title = "Followers"
            
            let query = PFQuery(className: FOLLOW_CLASS_NAME)
            query.whereKey(FOLLOW_IS_FOLLOWING, equalTo: fUser)
            query.findObjectsInBackground { (objects, error)-> Void in
                if error == nil {
                    self.followArray = objects!
                    // Reload TableView
                    self.followTableView.reloadData()
                    self.hideHUD()
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
                } }
        }
        else
        {
            self.title = "Following"
            
            let query = PFQuery(className: FOLLOW_CLASS_NAME)
            query.whereKey(FOLLOW_A_USER, equalTo: fUser)
            query.findObjectsInBackground { (objects, error)-> Void in
                if error == nil {
                    self.followArray = objects!
                    // Reload TableView
                    self.followTableView.reloadData()
                    self.hideHUD()
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
                }}
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return followArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowCell
        
        var followClass = PFObject(className: FOLLOW_CLASS_NAME)
        followClass = followArray[(indexPath as NSIndexPath).row]
        
        // Show followers
        if checkFollowers
        {
            let userPointer = followClass[FOLLOW_A_USER] as! PFUser
            userPointer.fetchIfNeededInBackground(block: { (user, error) in
                // Get user Pointer
                cell.fNameLabel.text = "\(userPointer[USER_FULLNAME]!)"
                
                // Get image
                let imageFile = userPointer[USER_AVATAR] as? PFFile
                imageFile?.getDataInBackground { (imageData, error) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.fAvatarImage.image = UIImage(data:imageData)
                        }}}
            })
        }
        else
        {
            let userPointer = followClass[FOLLOW_IS_FOLLOWING] as! PFUser
            userPointer.fetchIfNeededInBackground(block: { (user, error) in
                
                // Get user Pointer
                cell.fNameLabel.text = "\(userPointer[USER_FULLNAME]!)"
                
                // Get image
                let imageFile = userPointer[USER_AVATAR] as? PFFile
                imageFile?.getDataInBackground { (imageData, error) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.fAvatarImage.image = UIImage(data:imageData)
                        }}}
            })
            
        }
        
        // Cell layout
        cell.fAvatarImage.layer.cornerRadius = cell.fAvatarImage.bounds.size.width/2
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var followClass = PFObject(className: FOLLOW_CLASS_NAME)
        followClass = followArray[(indexPath as NSIndexPath).row]
        var aUser = PFUser()
        
        if checkFollowers
        {
            aUser = followClass[FOLLOW_A_USER] as! PFUser
            do { aUser = try  aUser.fetchIfNeeded() } catch {}
        }
        else
        {
            aUser = followClass[FOLLOW_IS_FOLLOWING] as! PFUser
            do { aUser = try  aUser.fetchIfNeeded() } catch {}
        }
        
        if PFUser.current()?.objectId==aUser.objectId
        {
            let mpVC=self.storyboard?.instantiateViewController(withIdentifier:"Me") as! Me
            self.navigationController?.pushViewController(mpVC, animated:true)
        }
        else
        {
            let oupVC = storyboard?.instantiateViewController(withIdentifier: "OtherUserProfile") as! OtherUserProfile
            oupVC.userObj = aUser
            navigationController?.pushViewController(oupVC, animated: true)
        }
    }
}
