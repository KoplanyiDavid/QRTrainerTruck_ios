//
//  AlertDialogBuilder.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 11. 04.
//

import Foundation
import UIKit

struct AlertDialogBuilder {
    
    static func basicAlertDialog(title: String, message: String) -> UIAlertController {
        let alertDialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        return alertDialog
    }
}
