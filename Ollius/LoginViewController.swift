//
//  LoginViewController.swift
//  Ollius
//
//  Created by Henrique Santiago on 10/24/15.
//  Copyright © 2015 Henrique Santiago. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func login() {
        LoginViewController.sendLoginRequestToServer(emailTextField, password: passwordTextField, completion: {(result, message) -> Void in
            if let output = result {
                print(output)
                if(output == "Success"){
                    self.performSegueWithIdentifier("showTabBar", sender: nil)
                }else{
                    self.sendAlert(message: message!)
                    print(message)
                }
            }
        })
    }
    
    func sendAlert(message messageToDisplay: String){
        dispatch_async(dispatch_get_main_queue(),{
        //Display alert message with confirmation
        
            let myAlert = UIAlertController(title:"Alert", message:messageToDisplay, preferredStyle: UIAlertControllerStyle.Alert)
        
            let okAction = UIAlertAction(title:"OK", style: UIAlertActionStyle.Default){ action in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    class func sendLoginRequestToServer(email: UITextField, password:UITextField, completion: ((result:String?, message:String?) -> Void)!){
        let userEmail = email.text!
        let userPassword = password.text!
        
        if (userPassword.isEmpty || userEmail.isEmpty){
            return
        }
        
        let myURL = NSURL(string: "http://ec2-52-88-89-186.us-west-2.compute.amazonaws.com/userlogin.php")
        let request = NSMutableURLRequest(URL: myURL!)
        request.HTTPMethod = "POST"
        
        let postString = "email=\(userEmail)&password=\(userPassword)"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if(error != nil){
                print(error)
                return
            }
            //let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print("******* response: = \(responseString)")
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                
                if let parseJSON = json {
                    let resultValue = parseJSON["status"] as? String
                    //print("result: \(resultValue)")
                    
                    var isUserRegistered = false
                    if(resultValue == "Success"){
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        //self.dismissViewControllerAnimated(true, completion: nil)
                        isUserRegistered = true
                    }
                    
                    var messageToDisplay: String = parseJSON["message"] as! String!
                    if(!isUserRegistered){
                        messageToDisplay = parseJSON["message"] as! String!
                    }
                    
                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                    dispatch_async(dispatch_get_global_queue(priority, 0)) {
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(result: resultValue, message: messageToDisplay)
                        }
                    }
                    //print(messageToDisplay)
                }
            }catch {
                print(error)
            }
        }
        task.resume()
    }
}


