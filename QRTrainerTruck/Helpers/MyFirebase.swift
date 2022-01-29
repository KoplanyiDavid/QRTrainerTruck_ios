//
//  FirebaseHelpers.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 11. 01.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import MapKit

struct MyFirebase {
    
    static var user: User? = Auth.auth().currentUser
    static let db = Firestore.firestore()
    static let realtimeDB = Database.database().reference().child("TrainerTruckLocation")
    static let storage = Storage.storage()
    
    static func createCollectionDocument(collection: String, document: String, data: [String : Any]) {
        
        db.collection(collection).document(document).setData(data) {
            error in
            guard error == nil else {
                print("ERROR CREATING DOCUMENT")
                return
            }
        }
    }
    
    static func updateCollectionDocumentField(collection:String, document: String, field: String, newData: Any) {
        
        let documentRef = db.collection(collection).document(document)

        documentRef.updateData([field: newData]) { err in
            if let err = err {
                print("Error updating document: \(err)")
                let alert = AlertDialogBuilder.basicAlertDialog(title: "Figyelem", message: "Hiba történt az adatok frissitése közben. A hiba: \(err.localizedDescription)")
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    alert.dismiss(animated: true, completion: nil)
                }))
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    static func setCollectionDocumentField(collection:String, document: String, field: String, newData: Any, merge: Bool) {
        
        let documentRef = db.collection(collection).document(document)

        documentRef.setData([field : newData], merge: merge)
    }
    
    static func addDataToArray(collection: String, document: String, field: String, data: Any) {
        let ref = db.collection(collection).document(document)
        
        ref.updateData([field : FieldValue.arrayUnion([data])])
    }
    
    static func removeDataFromArray(collection: String, document: String, field: String, dataToRemove: Any) {
        let ref = db.collection(collection).document(document)
        
        ref.updateData([field : FieldValue.arrayRemove([dataToRemove])])
    }
    
    static func uploadImage(imgData: Data, path: String) {
        let ref = storage.reference().child(path)
        ref.putData(imgData, metadata: nil) { success, error in
            guard error == nil else {
                print("Error uploading image")
                return
            }
        }
    }
    // upload images to Firebase Storage
    static func uploadImageWithDownloadUrl(imgData: Data, path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = storage.reference().child(path)
        ref.putData(imgData, metadata: nil) { success, error in
            guard error == nil else {
                print("Error uploading image")
                completion(.failure(error!))
                return
            }
            ref.downloadURL { url, error in
                guard error == nil else {
                    print("ERROR get download url")
                    return
                }
                completion(.success(url!))
            }
        }
    }
    
    static func getImageUrl(imagePath: String, completion: @escaping (Result<URL, Error>) -> Void) {
        
        let imageRef = storage.reference().child(imagePath)
        
        imageRef.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                print("Profpic URL not get")
                completion(.failure(error!))
                return
            }
            completion(.success(url))
        })
    }
    
    static func getUserFieldInfo(uid: String, field: String, completion: @escaping (Result<Any?, Error>) -> Void) {
        
        let docRef = db.collection("users").document(uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let data = document.get(field), error == nil else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(data))
            }
        }
    }
    
    static func deleteDocument(collection: String, document: String) {
        db.collection(collection).document(document).delete()
    }
    
    static func deleteDataFromStorage(path: String) {
        storage.reference().child(path).delete(completion: nil)
    }
    
    static func deleteField(collection: String, document: String, field: String) {
        let ref = db.collection(collection).document(document)
        ref.updateData([field : FieldValue.delete()])
    }
    
    static func getTruckLocation(map: MKMapView) {
        realtimeDB.observe(DataEventType.value, with: { snapshot in

            print(snapshot.childSnapshot(forPath: "latitude").value as! Double)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: snapshot.childSnapshot(forPath: "latitude").value as! Double, longitude: snapshot.childSnapshot(forPath: "longitude").value as! Double)
            annotation.title = "Trainer Truck"
            map.addAnnotation(annotation)
            
            let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            map.setRegion(region, animated: true)
        })
    }
    
    static func sendPasswordResetEmail(viewController: UIViewController, email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            guard error == nil else {
                let alert = AlertDialogBuilder.basicAlertDialog(title: "Figyelem!", message: "A jelszó módosítására szolgáló email-t nem sikerült elküldeni.")
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                viewController.present(alert, animated: true)
                return
            }
            let alert = AlertDialogBuilder.basicAlertDialog(title: "Figyelem!", message: "A jelszó módositására szolgáló emailt elküldtem az email cimedre.")
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            viewController.present(alert, animated: true)
            
        }
    }
    
    static func deleteUser(presenter: UIViewController, email: String, password: String) {

        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user?.reauthenticate(with: credential) { _, error in
            if error != nil {
                //error
            }
            else {
                user?.delete { error in
                  if let error = error {
                      let alert = AlertDialogBuilder.basicAlertDialog(title: "HIBA", message: "Hiba történt a fiók törlése során. A hiba: \(error.localizedDescription)")
                      
                      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                          alert.dismiss(animated: true, completion: nil)
                      }))
                      
                      presenter.present(alert, animated: true)
                      
                  } else {
                      let alert = AlertDialogBuilder.basicAlertDialog(title: "Sikeres művelet", message: "A fiók törlése sikeresen megtörtént!")
                      
                      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                          alert.dismiss(animated: true, completion: nil)
                          presenter.dismiss(animated: true, completion: nil)
                      }))
                      
                      presenter.present(alert, animated: true)
                      
                  }
                }
            }
        }
    }
    
    //MARK: Post helpers
    static func uploadPost(user: User, imageRef: String, imageData: Data, time: String, description: String) {
        
        uploadImageWithDownloadUrl(imgData: imageData, path: imageRef) { result in
            switch result {
            case .success(let url):
                let sorter = Int(Date().timeIntervalSince1970)
                
                getUserFieldInfo(uid: user.uid, field: "name") { res in
                    switch res {
                    case .success(let name):
                        let data = [
                            "authorId" : user.uid,
                            "authorName" : name as! String,
                            "imageUrl" : url.absoluteString,
                            "title" : time,
                            "description" : description,
                            "sorter" : sorter
                        ] as [String : Any]
                        createCollectionDocument(collection: "posts", document: String(sorter), data: data)
                    case .failure(let err):
                        print(err.localizedDescription)
                    }
                }
                
                
                
            case(.failure(let error)):
                print("ERROR uploading post: \(error)")
            }
        }
        
    }
    
}
