/*-------------------------------------
 
 - Photofeed -
 
 created by cubycode @2017
 All Rights Reserved
 
 -------------------------------------*/

import UIKit
import Parse


// MARK: - CUSTOM ACTIVITY CELL
class ActivityCell: UITableViewCell {
    
    /* Views */
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var txtLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}

// MARK: - ACTIVITY CONTROLLER
@available(iOS 8.2, *)
class ActivityVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    /* Views */
    @IBOutlet weak var activityTableView: UITableView!
    
    
    
    /* Variables */
    var activityArray = [PFObject]()
    
    override func viewWillAppear(_ animated: Bool)
    {
        queryActivity()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Notifications"
        navigationItem.backBarButtonItem=UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        self.edgesForExtendedLayout = UIRectEdge()
    }
    
    func queryActivity()
    {
        activityArray.removeAll()
        showHUD()
        
        let query = PFQuery(className: ACTIVITY_CLASS_NAME)
        query.whereKey(ACTIVITY_CURRENT_USER, equalTo: PFUser.current()!)
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.activityArray = objects!
                
                // Reload TableView
                self.activityTableView.reloadData()
                self.hideHUD()
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return activityArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        
        var activityClass = PFObject(className: ACTIVITY_CLASS_NAME)
        activityClass = activityArray[(indexPath as NSIndexPath).row]
        // Get userPointer
        let userPointer = activityClass[ACTIVITY_OTHER_USER] as! PFUser
        userPointer.fetchIfNeededInBackground { (user, error) in
            if error == nil {
                // Get text
                cell.txtLabel.text = "\(activityClass[ACTIVITY_TEXT]!)"
                
                // Get Date
                let date = activityClass.createdAt
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "MMM dd yyyy"
                cell.dateLabel.text = dateFormat.string(from: date!)
                
                
                // Get image
                cell.avatarImage.image = UIImage(named: "logo")
                let imageFile = userPointer[USER_AVATAR] as? PFFile
                imageFile?.getDataInBackground { (imageData, error) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.avatarImage.image = UIImage(data:imageData)
                        } } }
                cell.avatarImage.layer.cornerRadius = cell.avatarImage.bounds.size.width/2
                
                // error
            } else { self.simpleAlert("\(error!.localizedDescription)")
            }}
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var activityClass = PFObject(className: ACTIVITY_CLASS_NAME)
        activityClass = activityArray[indexPath.row]
        
        // Get userPointer
        let userPointer = activityClass[ACTIVITY_OTHER_USER] as! PFUser
        
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        
        // DELETE CELL ACTION
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            var activityClass = PFObject(className: ACTIVITY_CLASS_NAME)
            activityClass = self.activityArray[indexPath.row]
            activityClass.deleteInBackground(block: { (succ, error) in
                if error == nil {
                    self.activityArray.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }})
        }
        
        // Set colors of the actions
        deleteAction.backgroundColor = UIColor.red
        
        return [deleteAction]
    }
}
