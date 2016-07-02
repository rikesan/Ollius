//
//  OtherResellersTableViewController.swift
//  Ollius
//
//  Created by Henrique Santiago on 11/24/15.
//  Copyright © 2015 Henrique Santiago. All rights reserved.
//

import UIKit

class OtherResellersTableViewController: UITableViewController {
    var resellers = [Reseller]()
    var productID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*for index in 0...resellers.count{
            print(resellers[index].name)
        }*/
        
        OtherResellersTableViewController.getOtherResellers(productID, completion: {(result, resellers) -> Void in
            if let output = result {
                print(output)
                self.resellers = resellers!
                self.tableView.reloadData()
                if(output == "Success"){
                }else{
                    //print(message)
                }
            }
        })
        
        tableView.reloadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resellers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        let resellerPhoto = cell.viewWithTag(1) as! UIImageView //image
        resellerPhoto.image = UIImage(named: "p\(self.resellers[indexPath.row].id)")
        resellerPhoto.layer.cornerRadius = 70/2;
        resellerPhoto.clipsToBounds = true;
        
        let resellerName = cell.viewWithTag(2) as! UILabel
        resellerName.text = self.resellers[indexPath.row].name
        
        let resellerPhoneNumber = cell.viewWithTag(3) as! UILabel
        resellerPhoneNumber.text = self.resellers[indexPath.row].phoneNumber
        
        let price = cell.viewWithTag(4) as! UILabel
        let amount = Float(self.resellers[indexPath.row].price)!
        price.text = amount.asLocaleCurrency;

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    class func getOtherResellers(queryText: String, completion: ((result:String?, resellers:[Reseller]?) -> Void)!){
        let myURL = NSURL(string: "http://ec2-52-88-89-186.us-west-2.compute.amazonaws.com/getOtherResellers.php")
        let request = NSMutableURLRequest(URL: myURL!)
        request.HTTPMethod = "POST"
        let postString = "query=\(queryText)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if(error != nil){
                print(error)
                return
            }
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("******* response: = \(responseString)")
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                
                if let parseJSON = json {
                    let resultValue = parseJSON["status"] as? String
                    print("result: \(resultValue)")
                    var resellers = [Reseller]()
                    
                    if(resultValue == "Success"){
                        let resellersFromDatabase: NSArray = parseJSON["message"] as! NSArray
                        
                        for index in 0...resellersFromDatabase.count-1 {
                            let id = resellersFromDatabase[index]["id_revendedor"] as? String
                            let name = resellersFromDatabase[index]["name"] as? String
                            let phoneNumber = resellersFromDatabase[index]["phone"] as? String
                            let price = resellersFromDatabase[index]["preco"] as? String
                            //print (description)
                            let reseller = Reseller(id: id!, name: name!, phoneNumber: phoneNumber!, price: price!)
                            resellers.append(reseller)
                        }
                    }
                    //print(amountOfRecords)
                    
                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                    dispatch_async(dispatch_get_global_queue(priority, 0)) {
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(result: resultValue, resellers: resellers)
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
