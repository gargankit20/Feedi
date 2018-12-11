/*-------------------------------------
 
 - Photofeed -
 
 created by cubycode @2017
 All Rights Reserved
 
 -------------------------------------*/

import UIKit
import Parse

class CommentCell: UITableViewCell
{
    @IBOutlet weak var cAvatarImage: UIImageView!
    @IBOutlet weak var cFullnameLabel: UILabel!
    @IBOutlet weak var cTxtView: UITextView!
    @IBOutlet weak var cDateLabel: UILabel!
}

// MARK: - COMMENTS CONTROLLER
@available(iOS 8.2, *)
class Comments: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate
{
    @IBOutlet weak var commentsTableView: UITableView!
    let commentTxt = UITextView()
    @IBOutlet weak var fakeTxt: UITextField!
    
    var postObj2 = PFObject(className: POSTS_CLASSE_NAME)
    var commentsArray = [PFObject]()
    var cellHeight = CGFloat()
    
    override func viewDidAppear(_ animated: Bool)
    {
        queryComments()
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(refreshButt), userInfo: nil, repeats: false)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Comments"
        
        // Initialize a REFRESH BarButton Item
        let butt = UIButton(type: .custom)
        butt.adjustsImageWhenHighlighted = false
        butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        butt.setBackgroundImage(UIImage(named: "refreshButt"), for: .normal)
        butt.addTarget(self, action: #selector(refreshButt), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: butt)
        
        // Init a keyboard toolbar to send Comments
        let toolbar = UIView(frame: CGRect(x: 0, y: view.frame.size.height+44, width: view.frame.size.width, height: 60))
        toolbar.backgroundColor = UIColor.darkGray
        
        let sendButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 100, y: 0, width: 44, height: 44))
        sendButt.setBackgroundImage(UIImage(named: "sendCommentButt"), for: .normal)
        sendButt.addTarget(self, action: #selector(sendCommentButt(_:)), for: .touchUpInside)
        toolbar.addSubview(sendButt)
        
        let dismissButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 60, y: 0, width: 44, height: 44))
        dismissButt.setBackgroundImage(UIImage(named: "dismissButt2"), for: .normal)
        dismissButt.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        toolbar.addSubview(dismissButt)
        
        commentTxt.frame = CGRect(x: 8, y: 4, width: toolbar.frame.size.width - 120, height: 48)
        commentTxt.backgroundColor = UIColor.white
        commentTxt.textColor = UIColor(red:146.0/255.0,  green:148.0/255.0,  blue:150.0/255.0,  alpha:1.0)
        commentTxt.font=UIFont.systemFont(ofSize:13.0,  weight:.medium)
        commentTxt.clipsToBounds = true
        commentTxt.layer.cornerRadius = 5
        commentTxt.keyboardAppearance = .dark
        commentTxt.autocapitalizationType = .none
        commentTxt.autocorrectionType = .no
        toolbar.addSubview(commentTxt)
        
        fakeTxt.inputAccessoryView = toolbar
    }
    
    func queryComments()
    {
        showHUD()
        
        let query = PFQuery(className: COMMENTS_CLASS_NAME)
        query.whereKey(COMMENTS_POST_POINTER, equalTo: postObj2)
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.commentsArray = objects!
                self.commentsTableView.reloadData()
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
        return commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        
        var commClass = PFObject(className: COMMENTS_CLASS_NAME)
        commClass = commentsArray[(indexPath as NSIndexPath).row]
        
        // Get userPointer
        let userPointer = commClass[COMMENTS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground { (user, error) in
            
            // Get Full Name
            cell.cFullnameLabel.text = "\(userPointer[USER_FULLNAME]!)"
            
            // Get image
            cell.cAvatarImage.image = UIImage(named: "logo")
            let imageFile = userPointer[USER_AVATAR] as? PFFile
            imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.cAvatarImage.image = UIImage(data:imageData)
                    }}})
            cell.cAvatarImage.layer.cornerRadius = cell.cAvatarImage.bounds.size.width/2
            
            
            // Get comment
            cell.cTxtView.text = "\(commClass[COMMENTS_COMMENT]!)"
            cell.cTxtView.sizeToFit()
            cell.cTxtView.frame.size.width = cell.frame.size.width - 72
            self.cellHeight = cell.cTxtView.frame.origin.y + cell.cTxtView.frame.size.height + 10
            
            // Get Date
            let date = commClass.createdAt
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM dd yyyy, hh:mm"
            cell.cDateLabel.text = dateFormat.string(from: date!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var commClass = PFObject(className: COMMENTS_CLASS_NAME)
        commClass = commentsArray[(indexPath as NSIndexPath).row]
        
        let userPointer = commClass[COMMENTS_USER_POINTER] as! PFUser
        
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
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        commentTxt.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        commentTxt.becomeFirstResponder()
        return true
    }
    
    @objc func sendCommentButt(_ sender:UIButton)
    {
        if commentTxt.text == ""
        {
            simpleAlert("You must type something!")
        }
        else
        {
            dismissKeyboard()
            
            let commClass = PFObject(className: COMMENTS_CLASS_NAME)
            let currentUser = PFUser.current()
            
            commClass[COMMENTS_USER_POINTER] = currentUser
            commClass[COMMENTS_POST_POINTER] = postObj2
            commClass[COMMENTS_COMMENT] = commentTxt.text
            
            // Saving block
            commClass.saveInBackground { (success, error) -> Void in
                if error == nil {
                    
                    // alert
                    let alert = UIAlertController(title: APP_NAME,
                                                  message: "Your comment has been sent!",
                                                  preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                        self.queryComments()
                    })
                    
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    
                    // Send Push notification
                    let userPointer = self.postObj2[POSTS_USER_POINTER] as! PFUser
                    let pushStr = "\(PFUser.current()![USER_FULLNAME]!) commented your post: \(self.postObj2[POSTS_TEXT]!)"
                    
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
                        } else { print ("\(error!.localizedDescription)")
                        }})
                    
                    // Save comment in Activity
                    let activityClass = PFObject(className: ACTIVITY_CLASS_NAME)
                    activityClass[ACTIVITY_CURRENT_USER] = userPointer
                    activityClass[ACTIVITY_OTHER_USER] = PFUser.current()!
                    activityClass[ACTIVITY_TEXT] = "\(PFUser.current()![USER_FULLNAME]!) commented your post: \(self.postObj2[POSTS_TEXT]!))"
                    activityClass.saveInBackground()
                    
                    
                    // Lastly refresh commentsTableView
                    self.queryComments()
                }
                else
                {
                    self.simpleAlert("\(error!.localizedDescription)")
                }
            }
        }
    }
    
    @objc func dismissKeyboard()
    {
        fakeTxt.resignFirstResponder()
        commentTxt.resignFirstResponder()
    }
    
    @objc func refreshButt()
    {
        queryComments()
    }
}
