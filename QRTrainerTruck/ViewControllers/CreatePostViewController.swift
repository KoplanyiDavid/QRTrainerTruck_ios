//
//  CreatePostViewController.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 11. 04..
//

import UIKit
import Firebase

class CreatePostViewController: UIViewController {
    
    var isImageTaken: Bool = false
    let user = Auth.auth().currentUser

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var btnSendPost: UIButton!
    @IBAction func sendPost(_ sender: Any) {
        uploadPost()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initImageView()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func initImageView() {
        let gr = UITapGestureRecognizer(target: self, action: #selector(self.postImageTapped(sender: )))
        
        postImageView.isUserInteractionEnabled = true
        postImageView.addGestureRecognizer(gr)
    }
    
    @objc func postImageTapped(sender: UITapGestureRecognizer) {
        presentPhotoActionSheet()
    }
    
    func uploadPost() {
        btnSendPost.isEnabled = false
        let imageRef:String = "postimages/\(user!.uid)_\(String(Int(Date().timeIntervalSince1970))).jpg"
        
        MyFirebase.uploadPost(user: user!, imageRef: imageRef, imageData: (postImageView.image!.jpegData(compressionQuality: 80))!, time: titleTextField.text!, description: descriptionTextField.text!)
        
        let dialog = AlertDialogBuilder.basicAlertDialog(title: "Figyelem!", message: "A poszt feltoltese sikeresen megtortent.")
        
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            dialog.dismiss(animated: true, completion: nil)
        }))
        self.present(dialog, animated: true)
        btnSendPost.isEnabled = true
    }
    
}

extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        self.postImageView.image = img
        isImageTaken = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
