//
//  ImageViewInit.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 11. 02..
//

import UIKit

struct ImageViewHelper {
    
    static func roundImageView(imageView: UIImageView) {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
    }
    
    static func attachGestureRecognizer(imageView: UIImageView, gestureRecognizer: UITapGestureRecognizer) {
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    static func insertImageViaUrl(to imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
    }
}
