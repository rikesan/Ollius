//
//  ProductViewController.swift
//  Ollius
//
//  Created by Henrique Santiago on 11/24/15.
//  Copyright © 2015 Henrique Santiago. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController {
    var product: Product!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var nameOfResellerWithBestPrice: UILabel!
    @IBOutlet weak var priceOfResellerWithBestPrice: UILabel!
    @IBOutlet weak var phoneNumberOfResellerWithBestPrice: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = product.name
                // Do any additional setup after loading the view.
        productImage.image = UIImage(named: product.id)
        productImage.contentMode = UIViewContentMode.ScaleAspectFit
        print(product.description)
        productDescription.text = product.description
        priceOfResellerWithBestPrice.text = Float(product.bestPrice)?.asLocaleCurrency
        phoneNumberOfResellerWithBestPrice.text = product.phoneNumberOfResellerWithBestPrice
        nameOfResellerWithBestPrice.text = product.nameOfResellerWithBestPrice
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAllResellers" {
            if let destination = segue.destinationViewController as? OtherResellersTableViewController {
                destination.productID = self.product.id
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


