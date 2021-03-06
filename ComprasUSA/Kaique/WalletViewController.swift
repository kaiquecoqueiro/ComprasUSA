//
//  WalletViewController.swift
//  Kaique
//
//  Created by Kaique Coqueiro on 25/11/18.
//  Copyright © 2018 Kaique Coqueiro. All rights reserved.
//

import UIKit
import CoreData

class WalletViewController: UIViewController {
    
    @IBOutlet weak var tfAmerican: UILabel!
    @IBOutlet weak var tfBrazilian: UILabel!
    
    var fetchedProductsController: NSFetchedResultsController<Product>!
    var dataSource: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadProducts()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedProductsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedProductsController.delegate = self
        do {
            try fetchedProductsController.performFetch()
            self.dataSource = fetchedProductsController.fetchedObjects!
            calculate()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func calculate(){
        let exchangeTax = Double(UserDefaults.standard.string(forKey: "exchange") ?? "0")!
        
        let iofTax = Double(UserDefaults.standard.string(forKey: "iof") ?? "0")!
        
        var dolars: Double = 0.0
        var reais: Double = 0.0
        
        
        for product in dataSource {
            
            dolars += product.value
            reais += product.value * exchangeTax
            
            if product.card {
                reais += (product.value * iofTax) / 100
            }
            
            reais += (product.value * (product.states?.tax)!) / 100
            
        }
        
        
        tfAmerican.text = String(format: "%.2f", dolars)
        tfBrazilian.text = String(format: "%.2f", reais)
    }
}

extension WalletViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataSource = fetchedProductsController.fetchedObjects!
        calculate()
    }
}
