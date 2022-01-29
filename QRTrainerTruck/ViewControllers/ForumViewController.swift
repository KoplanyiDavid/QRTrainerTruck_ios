//
//  TableViewController.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 11. 06.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class ForumViewController: UITableViewController {
    
    private var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()

        getData()
    }
    
    func getData() {
        MyFirebase.db.collection("posts").addSnapshotListener { querySnapshot, error in
        guard let documents = querySnapshot?.documents else {
            print("NO documents")
            return
        }
            
            let tempPosts = documents.compactMap({ queryDocumentSnapshot -> Post? in
                return try? queryDocumentSnapshot.data(as: Post.self)
            })
            self.posts = tempPosts.sorted(by: { lPost, rPost in
                return lPost.sorter > rPost.sorter
            })
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(posts.count)
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
        
        let post = posts[indexPath.row]
        
        ImageViewHelper.roundImageView(imageView: cell.profileImageView)
        
        cell.posterName.text = post.authorName
        cell.posterTitle.text = post.title
        cell.posterDescription.text = post.description
        ImageViewHelper.insertImageViaUrl(to: cell.posterImage, url: post.imageUrl)
        MyFirebase.getImageUrl(imagePath: "profile_pictures/\(post.authorId)") { result in
            switch result {
            case .success(let url):
                ImageViewHelper.insertImageViaUrl(to: cell.profileImageView, url: url)
            case .failure(let error):
                print("ERROR getting profpic url Forum: \(error.localizedDescription)")
            }
        }
        return cell
    }
}
