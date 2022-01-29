//
//  TrainingsViewController.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 11. 06..
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class TrainingsViewController: UITableViewController {

    private var sortedTrainings = [Training]()

    override func viewDidLoad() {
        super.viewDidLoad()

        getData()
    }
    
    func getData() {
        
        MyFirebase.db.collection("trainings").addSnapshotListener { querySnapshot, error in
            
        guard let documents = querySnapshot?.documents else {
            print("NO documents")
            return
        }
            
            let trainings = documents.compactMap({ queryDocumentSnapshot -> Training? in
                return try? queryDocumentSnapshot.data(as: Training.self)
            })
            self.sortedTrainings = trainings.sorted { lTraining, rTraining in
                return lTraining.sorter < rTraining.sorter
            }
            self.tableView.reloadData()
             
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedTrainings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainingCell", for: indexPath) as! TrainingCell
        
        let training = sortedTrainings[indexPath.row]
        
        cell.trainingTitle.text = training.title
        cell.trainingTrainer.text = training.trainer
        cell.trainingDate.text = training.date
        cell.trainingLocation.text = training.location
        
        if training.trainees.contains(MyFirebase.user!.uid) {
            cell.backgroundColor = .green
        }
        else {
            cell.backgroundColor = .darkGray
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedTraining = sortedTrainings[indexPath.row]
        
        let data: NSDictionary = [
            "date" : selectedTraining.date,
            "location" : selectedTraining.location,
            "sorter" : selectedTraining.sorter
        ]
        
        if selectedTraining.trainees.contains(MyFirebase.user!.uid) {
            MyFirebase.removeDataFromArray(collection: "users", document: MyFirebase.user!.uid, field: "trainings", dataToRemove: data)
            
            MyFirebase.removeDataFromArray(collection: "trainings", document: String(selectedTraining.sorter), field: "trainees", dataToRemove: MyFirebase.user!.uid)
            
        }
        
        else if selectedTraining.trainees.contains(MyFirebase.user!.uid) == false {
            MyFirebase.addDataToArray(collection: "users", document: MyFirebase.user!.uid, field: "trainings", data: data)
            
            MyFirebase.addDataToArray(collection: "trainings", document: String(selectedTraining.sorter), field: "trainees", data: MyFirebase.user!.uid)
        }
    }
}
