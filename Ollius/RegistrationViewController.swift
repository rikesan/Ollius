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
        let userConfirmationPassword = passwordConfirmation.text!
        
        if (username.isEmpty || userEmail.isEmpty || userPassword.isEmpty || userConfirmationPassword.isEmpty){
            displayMyAlertMessage("All fields are required")
        }
        
        if (userPassword != userConfirmationPassword){
            displayMyAlertMessage("Passwords do not match")
            return
        }
        
        //Send user data to server side
        let myUrl = NSURL(string: "http://ec2-52-88-89-186.us-west-2.compute.amazonaws.com/userRegister.php/")
        let request = NSMutableURLRequest(URL: myUrl!)
        request.HTTPMethod = "POST"
        
        //let postString = "nome=\(username)&email=\(userEmail)&password=\(userPassword)"
        let postString = "email=\(userEmail)&password=\(userPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("******* response: = \(responseString)")
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                
                if let parseJSON = json {
                    let resultValue = parseJSON["status"] as? String
                    print("result: \(resultValue)")
                    
                    var isUserRegistered : Bool = false
                    if(resultValue == "Success"){
                        isUserRegistered = true
                    }
                    
                    var messageToDisplay: String = parseJSON["message"] as! String!
                    if(!isUserRegistered){
                        messageToDisplay = parseJSON["message"] as! String!
                    }
                    
                    print(messageToDisplay)
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
            }catch {
                print(error)
            }
        }
        task.resume()
        
//        let myAlert = UIAlertController(title: "Success!", message: "Registration is sucessful", preferredStyle: UIAlertControllerStyle.Alert)
//        let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.Default){ action in
//            self.dismissViewControllerAnimated(true, completion: nil)
//            
//        }
//        myAlert.addAction(okAction)
//        self.presentViewController(myAlert, animated: true, completion: nil)
        //displayMyAlertMessage("User registered sucessfully. Please log-in")
        //performSegueWithIdentifier("registrationToLogin", sender: self)
    }
    
    func displayMyAlertMessage(userMessage: String) {
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
}
