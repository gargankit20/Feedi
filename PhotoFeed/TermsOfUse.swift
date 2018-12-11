/*-------------------------------------
 
 - Photofeed -
 
 created by cubycode @2017
 All Rights Reserved
 
 -------------------------------------*/


import UIKit

class TermsOfUse: UIViewController {

    /* Views */
    @IBOutlet var webView: UIWebView!
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    let url = Bundle.main.url(forResource: "tou", withExtension: "html")
    webView.loadRequest(URLRequest(url: url!))
}

// DISMISS BUTTON
@IBAction func dismissButt(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
}
}
