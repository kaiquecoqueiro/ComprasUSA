//
//  UIViewController+CoreData.swift
//  Kaique
//
//  Created by Kaique Coqueiro on 25/11/18.
//  Copyright © 2018 Kaique Coqueiro. All rights reserved.
//

import UIKit
import CoreData


extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
}
