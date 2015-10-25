//
//  RegistrationViewController.swift
//  Ollius
//
//  Created by Henrique Santiago on 10/24/15.
//  Copyright © 2015 Henrique Santiago. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var passwordConfirmation: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func register(sender: UIButton) {
        let username = name.text!
        let userEmail = email.text!
        let userPassword = password.text!
        //let userConfirmationPassword = passwordConfirmation.text!
        
        //Send user data to server side
        let myUrl = NSURL(string: "http://ec2-52-88-89-186.us-west-2.compute.amazonaws.com/userRegister.php")
        let request = NSMutableURLRequest(URL: myUrl!)
        request.HTTPMethod = "POST"
        
        let postString = "nome=\(username)&email=\(userEmail)&password=\(userPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? NSDictionary
            
            if let parseJSON = json {
                var resultValue = parseJSON["status"] as? String
                println("result: \(resultValue)")
                
                var isUserRegistered : Bool = false
                if(resultValue == "Success"){
                    isUserRegistered = true
                }
                
                var messageToDisplay: String = parseJSON["message"] as String!
                if(!isUserRegistered){
                    messageToDisplay = parseJSON["message"] as String!
                }
                
                dispatch_async(dispatch_get_main_queue(),{
                    //Display alert message with confirmation
                    
                    var myAlert = UIAlertController(title:"Alert", message:messageToDisplay, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okAction = UIAlertAction(title:"OK", style: UIAlertActionStyle.Default){ action in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    myAlert.addAction(okAction)
                    self.presentViewController(myAlert, animated: true, completion: nil)
                })
            }
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
