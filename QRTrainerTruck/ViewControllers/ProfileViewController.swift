//
//  ProfileViewController.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 10. 28..
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    let user = Auth.auth().currentUser

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    
    @IBOutlet weak var labelFullName: UILabel!
    @IBOutlet weak var labelFullEmail: UILabel!
    @IBOutlet weak var labelMobile: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initProfPicImageView()
        initLabels()
    }
    
    func initProfPicImageView() {
        
        ImageViewHelper.roundImageView(imageView: profilePicture)
        
        MyFirebase.getImageUrl(imagePath: "profile_pictures/\(user!.uid)") { [weak self] url in
            switch url {
            case .success(let url):
                ImageViewHelper.insertImageViaUrl(to: self!.profilePicture, url: url)
            case .failure(let error):
                print("DOWNLOAD FAILED \(error)")
                
            }
        }
        
        let profPicGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profilePicImageTapped(sender: )))
        
        ImageViewHelper.attachGestureRecognizer(imageView: profilePicture, gestureRecognizer: profPicGestureRecognizer)
    }
    
    @objc func profilePicImageTapped(sender: UITapGestureRecognizer) {
        presentPhotoActionSheet()
    }
    
    func initLabels() {
        MyFirebase.getUserFieldInfo(uid: user!.uid, field: "name", completion: { [weak self] result in
            switch result {
            case .success(let data):
                self!.labelName.text = (data as! String)
                self!.labelFullName.text = (data as! String)
            case .failure(let error):
                print("ERROR setting label text: \(error)")
            }
        })
        
        MyFirebase.getUserFieldInfo(uid: user!.uid, field: "email", completion: { [weak self] result in
            switch result {
            case .success(let data):
                self!.labelEmail.text = (data as! String)
                self!.labelFullEmail.text = (data as! String)
            case .failure(let error):
                print("ERROR setting label text: \(error)")
            }
        })
        
        MyFirebase.getUserFieldInfo(uid: user!.uid, field: "mobile", completion: { [weak self] result in
            switch result {
            case .success(let data):
                self!.labelMobile.text = (data as! String)
            case .failure(let error):
                print("ERROR setting label text: \(error)")
            }
        })
    }

    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.dismiss(animated: true) {
                self.showLoginPage()
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    }
    
    func showLoginPage() {
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.loginViewController) as? LoginViewController
        
        self.view.window?.rootViewController = loginViewController
        self.view.window?.makeKeyAndVisible()
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        self.profilePicture.image = img
        MyFirebase.uploadImage(imgData: (img.pngData()!), path: "profile_pictures/\(user!.uid)")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
