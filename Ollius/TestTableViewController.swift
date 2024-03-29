//
//  TestTableViewController.swift
//  Ollius
//
//  Created by Henrique Santiago on 11/17/15.
//  Copyright © 2015 Henrique Santiago. All rights reserved.
//

import UIKit

extension Float {
    var asLocaleCurrency:String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = NSLocale.currentLocale()
        return formatter.stringFromNumber(self)!
    }
}

class TestTableViewController: UITableViewController, UISearchResultsUpdating {
    var candies = [Product]()
    var filteredCandies = [Product]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
        // Reload the table
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showProduct" {
            if let destination = segue.destinationViewController as? ProductViewController {
                if let index = self.tableView.indexPathForSelectedRow?.row {
                    destination.product = candies[index]
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.active{
            return self.filteredCandies.count
        }else{
            return self.candies.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
    
        if self.resultSearchController.active{
            //cell.textLabel?.text = self.filteredCandies[indexPath.row]
            let productImage = cell.viewWithTag(1) as! UIImageView //image
            let productTitle = cell.viewWithTag(2) as! UILabel
            let productBestPrice = cell.viewWithTag(3) as! UILabel
            let productNumberOfResellers = cell.viewWithTag(4) as! UILabel
            let productBrand = cell.viewWithTag(5) as! UILabel
            productImage.image = UIImage(named: self.filteredCandies[indexPath.row].id)
            productImage.layer.cornerRadius = 71/2;
            productImage.clipsToBounds = true;
            productTitle.text = self.filteredCandies[indexPath.row].name
            
            let amount = Float(self.filteredCandies[indexPath.row].bestPrice)!
            
            productBestPrice.text = amount.asLocaleCurrency;
            productNumberOfResellers.text = String(self.filteredCandies[indexPath.row].numberOfResellers)
            productBrand.text = String(self.filteredCandies[indexPath.row].brand)
        }else{
            let textLabel = cell.viewWithTag(2) as! UILabel
            textLabel.text = self.candies[indexPath.row].name
            //cell.textLabel?.text = self.candies[indexPath.row]
        }
        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filteredCandies.removeAll(keepCapacity: false)
        //let searchPredicate = NSPredicate(format: "SELF CONTAINS [c] %@", searchController.searchBar.text!)
        
        TestTableViewController.fetchFromNetwork(searchController.searchBar.text!, completion: {(result, products) -> Void in
            if let output = result {
                //print(output)
                if(output == "Success"){
                    //self.performSegueWithIdentifier("showTabBar", sender: nil)
                    self.candies.removeAll(keepCapacity: false)
                    for index in 0...products!.count-1{
                        self.candies.append(products![index])
                    }
                    self.filteredCandies = self.candies
                    
                    self.tableView.reloadData()
                }else{
                    //self.sendAlert(message: message!)
                    //print(message)
                }
            }
        })
        
        //print("\(products[0])")
        
        //let array = (self.candies as NSArray).filteredArrayUsingPredicate(searchPredicate)
        //self.filteredCandies = candies
        
        //self.tableView.reloadData()
    }
    
    class func fetchFromNetwork(queryText: String, completion: ((result:String?, products:[Product]?) -> Void)!){
        let myURL = NSURL(string: "http://ec2-52-88-89-186.us-west-2.compute.amazonaws.com/getProducts.php")
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
                    var products = [Product]()
                    
                    if(resultValue == "Success"){
                        let productsFromDatabase: NSArray = parseJSON["message"] as! NSArray
        
                        for index in 0...productsFromDatabase.count-1 {
                            let productName = productsFromDatabase[index]["nome"] as! String
                            //print(productName)
                            let productID = productsFromDatabase[index]["codigo_produto"] as? String
                            let brandName = productsFromDatabase[index]["brandName"] as? String
                            let bestPrice = productsFromDatabase[index]["bestPrice"] as? String
                            let numberOfResellers = productsFromDatabase[index]["numberOfResellers"] as? String
                            let description = productsFromDatabase[index]["descricao"] as? String
                            let phoneNumberOfResellerWithBestPrice = productsFromDatabase[index]["resellerPhoneNumberWithBestPrice"] as? String
                            let nameOfResellerWithBestPrice = productsFromDatabase[index]["resellerNameWithBestPrice"] as? String
                            //print (description)
                            let product = Product(id: productID!, name: productName, brand: brandName!, bestPrice: bestPrice!, numberOfResellers: Int(numberOfResellers!)!, description: description!, phoneNumberOfResellerWithBestPrice: phoneNumberOfResellerWithBestPrice!, nameOfResellerWithBestPrice: nameOfResellerWithBestPrice!)
                            products.append(product)
                        }
                    }
                    //print(amountOfRecords)
        
                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                    dispatch_async(dispatch_get_global_queue(priority, 0)) {
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(result: resultValue, products: products)
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

}
