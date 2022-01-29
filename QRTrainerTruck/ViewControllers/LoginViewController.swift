//
//  LoginViewController.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 10. 25.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var labelError: UILabel!
    @IBAction func btnForgotPassword(_ sender: Any) {
        
        let dialog = AlertDialogBuilder.basicAlertDialog(title: "Figyelem!", message: "Add meg az email címed!")
        
        dialog.addTextField { textField in
            textField.placeholder = "email"
        }
        
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak dialog] _ in
            guard let textField = dialog?.textFields?[0], let emailText = textField.text else { return }
            MyFirebase.sendPasswordResetEmail(viewController: self, email: emailText)
        }))
        
        dialog.addAction(UIAlertAction(title: "Mégse", style: .default, handler: { [weak dialog] _ in
            dialog?.dismiss(animated: true, completion: nil)
        }))
        
        self.present(dialog, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }
    
    private func initUI() {
        labelError.alpha = 0
    }
    
    //dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkCurrentUser()
    }
    
    private func checkCurrentUser() {
        MyFirebase.user = Auth.auth().currentUser
        if MyFirebase.user == nil {
            return
        }
        else {
            if MyFirebase.user!.isEmailVerified {
                openHomeView()
            }
        }
    }
    
    func buildAlertDialog() {
        let alert = UIAlertController(title: "Figyelem!", message: "A regisztrációt még nem erősitetted meg.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true)
    }

    @IBAction func login(_ sender: Any) {
        let error = validateFields()
        
        if error != nil {
            showError(message: error!)
        }
        
        else {
            firebaseLogin()
        }
    }
    
    private func showError(message: String) {
        labelError.text = message
        labelError.alpha = 1
    }
    
    private func validateFields() -> String? {
        if ((tfEmail.text?.isEmpty) == true) {
            return "Nem adtad meg az emailedet :("
        }
        if ((tfPassword.text?.isEmpty) == true) {
            return "Nem adtad meg a jelszavadat :("
        }
        return nil
    }
    
    private func firebaseLogin() {
        Auth.auth().signIn(withEmail: tfEmail.text!, password: tfPassword.text!) { result, error in
            if error != nil {
                self.showError(message: error!.localizedDescription)
            }
            else {
                if result?.user.isEmailVerified == true {
                    MyFirebase.user = result?.user
                    self.openHomeView()
                }
                else {
                    self.buildAlertDialog()
                }
            }
        }
    }
    
    private func openHomeView() {
        let tabBarViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarViewController) as? TabBarViewController
        
        self.view.window?.rootViewController = tabBarViewController
        self.view.window?.makeKeyAndVisible()
    }
}
