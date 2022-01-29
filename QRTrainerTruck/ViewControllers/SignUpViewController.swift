//
//  SignUpViewController.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 10. 25..
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var btnASZF: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var labelError: UILabel!
    @IBOutlet weak var ivProfilePicture: UIImageView!
    
    let user = Auth.auth().currentUser
    let storage = Storage.storage().reference()
    var profileImgData: Data? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }
    
    //dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func initUI() {
        labelError.alpha = 0
        let ivGR = UITapGestureRecognizer(target: self, action: #selector(self.profilePicImageTapped(sender:)))
        
        ImageViewHelper.roundImageView(imageView: ivProfilePicture)
        ImageViewHelper.attachGestureRecognizer(imageView: ivProfilePicture, gestureRecognizer: ivGR)
    }
    
    @objc func profilePicImageTapped(sender: UITapGestureRecognizer) {
        presentPhotoActionSheet()
    }
    
    @IBAction func signUp(_ sender: Any) {
        let error = validateFields()
        
        if error != nil {
            showError(message: error!)
        }
        else {
            createFirebaseUser()
        }
    }
    
    @IBAction func openASZF() {
        UIApplication.shared.open(URL(string:"https://docs.google.com/document/d/1jmm1wLmqKIgFZMPiUWM2nMmfHlh4yq1HrLc_-bT-EAo/edit?usp=sharing")!, options: [:], completionHandler: nil)
    }
    
    
    private func validateFields() -> String? {
        if ((tfName.text?.isEmpty) == true) {
            return "Nem adtad meg a neved :("
        }
        if ((tfEmail.text?.isEmpty) == true) {
            return "Nem adtad meg az emailedet :("
        }
        if (tfPassword.text != tfConfirmPassword.text) {
            return "A jelszó megerősítése sikertelen."
        }
        return nil
    }
    
    private func showError(message: String) {
        labelError.text = message
        labelError.alpha = 1
    }
    
    private func createFirebaseUser() {
        Auth.auth().createUser(withEmail: tfEmail.text!, password: tfPassword.text!) { result, err in
            if err != nil {
                self.showError(message: "Hiba történt a regisztráció során." + err.debugDescription)
            }
            else {
                let profileImageData = self.ivProfilePicture.image!.pngData()
                //upload image and update database field
                MyFirebase.uploadImage(imgData: profileImageData!, path: "profile_pictures/\(result!.user.uid)")
                
                MyFirebase.uploadImageWithDownloadUrl(imgData: profileImageData!, path: "profile_pictures/\(result!.user.uid)") { res in
                    switch res {
                    case .success(let url):
                        let trainings: Array<NSDictionary> = []
                        let db = Firestore.firestore()
                        db.collection("users").document((result?.user.uid)!).setData([
                            "id": result!.user.uid,
                            "name": self.tfName.text!,
                            "email": self.tfEmail.text!,
                            "mobile": "null",
                            "acceptedtermsandcons": true,
                            "profilePictureUrl": url.absoluteString,
                            "rank": "Újonc",
                            "score": 0,
                            "trainings": trainings
                            
                        ]) { (error) in
                            
                            if error != nil {
                                self.showError(message: "Az adatok feltöltése az adatbázisba sikertelen (de a regisztráció megtörtént)")
                            }
                        }
                        
                        self.sendVerificationEmail()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func sendVerificationEmail() {
        Auth.auth().currentUser?.sendEmailVerification(completion: { Error in
            if Error == nil {
                self.buildAlertDialog()
            }
            else {
                self.showError(message: "A megerősítő email elküldése során hiba történt, kérlek próbáld meg újra.")
            }
        })
    }
    
    func buildAlertDialog() {
        let alert = UIAlertController(title: "Figyelem!", message: "A regisztrációt megerősítő email-t elküldtem a megadott email-címre.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true)
    }
}


extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profilkép választás", message: "Honnan szeretnél képet választani?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Mégse", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Fénykép készítése", style: .default, handler: { [weak self]_ in
            self?.takePhoto()
        }))
        actionSheet.addAction(UIAlertAction(title: "Kép választása galériából", style: .default, handler: { [weak self] _ in
            self?.getPhoto()
        }))
        
        present(actionSheet, animated: true)
    }
    
    func takePhoto() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func getPhoto() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        self.ivProfilePicture.image = img
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
