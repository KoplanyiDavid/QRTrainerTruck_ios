//
//  ModifyDataViewController.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 11. 03..
//

import UIKit
import Firebase
import FirebaseFirestore

class ModifyDataViewController: UIViewController {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfMobile: UITextField!
   
    @IBAction func tfNameEditingDidEnd(_ sender: Any) {
        MyFirebase.updateCollectionDocumentField(collection: "users", document: MyFirebase.user!.uid, field: "name", newData: tfName.text!)
    }
    
    @IBAction func tfEmailEditingDidEnd(_ sender: Any) {
        MyFirebase.updateCollectionDocumentField(collection: "users", document: MyFirebase.user!.uid, field: "email", newData: tfEmail.text!)
        
        MyFirebase.user!.updateEmail(to: tfEmail.text!) { error in
            let alert = AlertDialogBuilder.basicAlertDialog(title: "Figyelem", message: "Nem sikerult frissiteni az email cimet.")
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true)
        }
        
        MyFirebase.user!.sendEmailVerification { error in
            let alert = AlertDialogBuilder.basicAlertDialog(title: "Figyelem", message: "Nem sikerult kikuldeni a megerosito emailt.")
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func tfMobileEditingDidEnd(_ sender: Any) {
        MyFirebase.updateCollectionDocumentField(collection: "users", document: MyFirebase.user!.uid, field: "mobile", newData: tfMobile.text!)
    }
    
    @IBAction func saveData(_ sender: Any) {
        var name: String? = nil
        var email: String? = nil
        var mobile: String? = nil
        
        self.view.endEditing(true)
        
        let docRef = Firestore.firestore().collection("users").document(MyFirebase.user!.uid)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                name = (document.get("name") as! String)
                email = (document.get("email") as! String)
                mobile = (document.get("mobile") as! String)
                
                if ((name == self.tfName.text || name == self.tfName.placeholder) && (email == self.tfEmail.text || email == self.tfEmail.placeholder) && (mobile == self.tfMobile.text || mobile == self.tfMobile.placeholder)) {
                    print("MODIFY DATA OK")
                    let alert = AlertDialogBuilder.basicAlertDialog(title: "Figyelem!", message: "Az adatok mentese sikeresen megtortent.")
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true)
                    
                }
                else {
                    print("ERROR in modify data")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func changePassword(_ sender: Any) {
        MyFirebase.sendPasswordResetEmail(viewController: self, email: MyFirebase.user!.email!)
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        
        var email: String? = nil
        var password: String? = nil
        
        let relogDialog = AlertDialogBuilder.basicAlertDialog(title: "Figyelem!", message: "A fiók törléséhez jelentkezz be újra!")
                relogDialog.addTextField { textField in
                    textField.placeholder = "Email"
                }

                relogDialog.addTextField { textField in
                    textField.placeholder = "Jelszó"
                }

                relogDialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak relogDialog] _ in
                    
                    if let textField = relogDialog?.textFields?[0], let emailText = textField.text {
                        email = emailText
                    }

                    if let textField = relogDialog?.textFields?[1], let passwordText = textField.text {
                        password = passwordText
                    }
                    
                    if email != nil && password != nil {
                        MyFirebase.deleteUser(presenter: self, email: email!, password: password!)
                    }
                    else {
                        //hiba
                    }
                    
                }))

        self.present(relogDialog, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTextFields()
    }
    
    //dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func initTextFields() {
        MyFirebase.getUserFieldInfo(uid: MyFirebase.user!.uid, field: "name") { [weak self] result in
            switch result {
            case .success(let data):
                self!.tfName.placeholder = (data as! String)
            case .failure(let error):
                print("ERROR getting user name: \(error)")
            }
        }
        
        MyFirebase.getUserFieldInfo(uid: MyFirebase.user!.uid, field: "email") { [weak self] result in
            switch result {
            case .success(let data):
                self!.tfEmail.placeholder = (data as! String)
            case .failure(let error):
                print("ERROR getting user name: \(error)")
            }
        }
        
        MyFirebase.getUserFieldInfo(uid: MyFirebase.user!.uid, field: "mobile") { [weak self] result in
            switch result {
            case .success(let data):
                self!.tfMobile.placeholder = (data as! String)
            case .failure(let error):
                print("ERROR getting user name: \(error)")
            }
        }
    }

}
