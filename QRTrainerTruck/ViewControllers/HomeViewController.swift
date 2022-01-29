//
//  HomeViewController.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 11. 01.
//

import UIKit
import Firebase
import FirebaseFirestore
import MapKit
import CodableFirebase

class HomeViewController: UIViewController {
    
    private let user = Auth.auth().currentUser

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelRank: UILabel!
    @IBOutlet weak var labelScore: UILabel!
    @IBOutlet weak var labelNextTrainingDate: UILabel!
    @IBOutlet weak var labelNextTrainingLocation: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initProfPicImageView()
        //initLabels()
        MyFirebase.getTruckLocation(map: mapView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initProfPicImageView()
        initLabels()
        //FirebaseHelper.getTruckLocation(map: mapView)
    }
    
    func initProfPicImageView() {
        
        ImageViewHelper.roundImageView(imageView: profileImageView)
        
        MyFirebase.getImageUrl(imagePath: "profile_pictures/\(user!.uid)") { [weak self] url in
            switch url {
            case .success(let url):
                ImageViewHelper.insertImageViaUrl(to: self!.profileImageView, url: url)
            case .failure(let error):
                print("DOWNLOAD FAILED \(error)")
                
            }
        }
        
        let profPicGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profilePicImageTapped(sender: )))
        
        ImageViewHelper.attachGestureRecognizer(imageView: profileImageView, gestureRecognizer: profPicGestureRecognizer)
    }
    
    @objc func profilePicImageTapped(sender: UITapGestureRecognizer) {
        presentPhotoActionSheet()
    }
    
    func initLabels() {
        //Name
        MyFirebase.getUserFieldInfo(uid: user!.uid, field: "name", completion: { [weak self] result in
            switch result {
            case .success(let data):
                self!.labelName.text = (data as! String)
            case .failure(let error):
                print("ERROR setting label text: \(error)")
            }
        })
        
        //Rank
        MyFirebase.getUserFieldInfo(uid: user!.uid, field: "rank", completion: { result in
            switch result {
            case .success(let data):
                self.labelRank.text = (data as! String)
            case .failure(let error):
                print("ERROR setting label text: \(error)")
            }
        })
        //Score
        MyFirebase.getUserFieldInfo(uid: user!.uid, field: "score", completion: { result in
            switch result {
            case .success(let data):
                self.labelScore.text = String(data as! Int)
            case .failure(let error):
                print("ERROR setting label text: \(error)")
            }
        })
        //Next training date, location
        MyFirebase.getUserFieldInfo(uid: user!.uid, field: "trainings") { result in
            switch result {
            case .success(let result):
                //print(result!)
                guard var trainings = result as? Array<NSDictionary> else {
                    guard let trainings = result as? NSDictionary else {
                        self.labelNextTrainingDate.text = "Nincs kovetkezo edzes"
                        self.labelNextTrainingLocation.text = "Nincs kovetkezo edzes"
                        return
                    }
                    self.labelNextTrainingDate.text = (trainings.value(forKey: "date") as! String)
                    self.labelNextTrainingLocation.text = (trainings.value(forKey: "location") as! String)
                    return
                }
                
                if trainings.isEmpty {
                    self.labelNextTrainingDate.text = "Nincs kovetkezo edzes"
                    self.labelNextTrainingLocation.text = "Nincs kovetkezo edzes"
                    
                }
                
                else if trainings.count == 1 {
                    self.labelNextTrainingDate.text = trainings[0].value(forKey: "date") as? String
                    self.labelNextTrainingLocation.text = trainings[0].value(forKey: "location") as? String
                }
                
                else {
                    trainings = trainings.sorted { lTraining, rTraining in
                        return (lTraining.value(forKey: "sorter") as! UInt64) < (rTraining.value(forKey: "sorter") as! UInt64)
                    }
                        
                        self.labelNextTrainingDate.text = (trainings[0].value(forKey: "date") as! String)
                        self.labelNextTrainingLocation.text = (trainings[0].value(forKey: "location") as! String)
                }
                
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        self.profileImageView.image = img
        MyFirebase.uploadImage(imgData: (img.pngData()!), path: "profile_pictures/\(user!.uid)")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
