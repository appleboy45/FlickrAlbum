//
//  DetailImageVC.swift
//  FlickrAlbum
//
//  Created by Vineet Singh on 23/07/18.
//  Copyright © 2018 Vineet Singh. All rights reserved.
//

import UIKit

class DetailImageVC: UIViewController {
    
    @IBOutlet weak var detailImage: UIImageView!
    
    var thumbnail: UIImage?
    
    var photoID: String?
    var farm: Int?
    var server: String?
    var secret: String?
    let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1.0, green: 51/255, blue: 101/255, alpha: 1.0)
        self.view.addSubview(navBar)
        let navItem = UINavigationItem(title: "Image")
        let doneItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(handleDismiss));
        navItem.rightBarButtonItem = doneItem
        navBar.setItems([navItem], animated: false)

        //statusbarSetup
        let statusBarBackgroundView = UIView()
        statusBarBackgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20)
        statusBarBackgroundView.backgroundColor = UIColor(red: 1.0, green: 51/255, blue: 101/255, alpha: 1.0)
        self.view.addSubview(statusBarBackgroundView)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.largeImageSetup()
    }
    
    @objc func handleDismiss(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func largeImageSetup(){
        
        let imageUrl = "https://farm\(self.farm!).staticflickr.com/\(self.server!)/\(self.photoID!)_\(self.secret!)_b.jpg"
        
        guard let url = URL(string: imageUrl)else{return}
        
        DispatchQueue.global(qos: .background).async {
            if let cachedImage = AlbumVC.imageCache.object(forKey: url.absoluteString as NSString){
                print("Large Image in CacheFound")
                DispatchQueue.main.async {
                    self.detailImage.image = cachedImage
                }
            }else{
                do{
                    let imageData: Data = try Data(contentsOf: url,options: [])
                    guard let image: UIImage = UIImage(data: imageData)else{return}
                    AlbumVC.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    DispatchQueue.main.async {
                        self.detailImage.image = image
                    }
                }catch{
                    print(error)
                }
            }
        }
        
        if self.detailImage.image == nil{
            self.detailImage.image = thumbnail
        }
    }
}



