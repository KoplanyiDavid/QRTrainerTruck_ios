//
//  OnlineTrainingViewController.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 10. 27.
//

import UIKit

class OnlineTrainingViewController: UIViewController {

    @IBOutlet weak var reggeli: UIImageView!
    @IBOutlet weak var sajattestsulyos: UIImageView!
    @IBOutlet weak var eszkozos: UIImageView!
    @IBOutlet weak var mobilizacio: UIImageView!
    @IBOutlet weak var esti: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initImageViews()
    }
    
    func initImageViews() {
        initReggeli()
        initSajattestsulyos()
        initEszkozos()
        initMobilizacio()
        initEsti()
    }
    
    func initReggeli() {
        let reggeliGR = UITapGestureRecognizer(target: self, action: #selector(self.reggelitornaImageTapped(sender:)))
        reggeli.addGestureRecognizer(reggeliGR)
        reggeli.isUserInteractionEnabled = true
        reggeli.layer.masksToBounds = true
        reggeli.layer.cornerRadius = reggeli.frame.width / 5
    }
    
    func initSajattestsulyos() {
        let sajattestsulyosGR = UITapGestureRecognizer(target: self, action: #selector(self.sajattestsulyosImageTapped(sender:)))
        sajattestsulyos.addGestureRecognizer(sajattestsulyosGR)
        sajattestsulyos.isUserInteractionEnabled = true
        sajattestsulyos.layer.masksToBounds = true
        sajattestsulyos.layer.cornerRadius = sajattestsulyos.frame.width / 5
    }
    
    func initEszkozos() {
        let eszkozosGR = UITapGestureRecognizer(target: self, action: #selector(self.eszkozosImageTapped(sender:)))
        eszkozos.addGestureRecognizer(eszkozosGR)
        eszkozos.isUserInteractionEnabled = true
        eszkozos.layer.masksToBounds = true
        eszkozos.layer.cornerRadius = eszkozos.frame.width / 5
    }
    
    func initMobilizacio() {
        let mobilizacioGR = UITapGestureRecognizer(target: self, action: #selector(self.mobilizacioImageTapped(sender:)))
        mobilizacio.addGestureRecognizer(mobilizacioGR)
        mobilizacio.isUserInteractionEnabled = true
        mobilizacio.layer.masksToBounds = true
        mobilizacio.layer.cornerRadius = mobilizacio.frame.width / 5
    }
    
    func initEsti() {
        let estiGR = UITapGestureRecognizer(target: self, action: #selector(self.estitornaImageTapped(sender:)))
        esti.addGestureRecognizer(estiGR)
        esti.isUserInteractionEnabled = true
        esti.layer.masksToBounds = true
        esti.layer.cornerRadius = esti.frame.width / 5
    }
    
    @objc func reggelitornaImageTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            playInYoutube(youtubeURL: Constants.ytcLinks.morningTrainingYTC)
        }
    }
    
    @objc func sajattestsulyosImageTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            playInYoutube(youtubeURL: Constants.ytcLinks.bodyweightOnlyTrainingYTC)
        }
    }
    
    @objc func eszkozosImageTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            playInYoutube( youtubeURL: Constants.ytcLinks.trainingWithEquipmentYTC)
        }
    }
    
    @objc func mobilizacioImageTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            playInYoutube(youtubeURL: Constants.ytcLinks.mobilizationTrainingYTC)
        }
    }
    
    @objc func estitornaImageTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            playInYoutube(youtubeURL: Constants.ytcLinks.beforeBedTrainingYTC)
        }
    }
    
    func playInYoutube(youtubeURL: String) {
        if let youtubeURL = URL(string: youtubeURL),
            UIApplication.shared.canOpenURL(youtubeURL) {
            // redirect to app
            UIApplication.shared.open(youtubeURL, options: [:], completionHandler: nil)
        } else if let youtubeURL = URL(string: youtubeURL) {
            // redirect through safari
            UIApplication.shared.open(youtubeURL, options: [:], completionHandler: nil)
        }
    }
}
