//
//  FlickrPhoto.swift
//  FlickrAlbum
//
//  Created by Vineet Singh on 23/07/18.
//  Copyright © 2018 Vineet Singh. All rights reserved.
//

import Foundation
import UIKit

class FlickrPhoto{
    
    var thumbnail: UIImage?
    //var largeImage: UIImage?
    
    var photoID: String?
    var farm: Int?
    var server: String?
    var secret: String?
    
    
    
    init(dictionary: [String:AnyObject]) {
        
        photoID = dictionary["id"] as? String
        secret = dictionary["secret"] as? String
        server = dictionary["server"] as? String
        farm = dictionary["farm"] as? Int
        
        DispatchQueue.global(qos: .userInteractive).async {
        
            let imageUrl = "https://farm\(self.farm!).staticflickr.com/\(self.server!)/\(self.photoID!)_\(self.secret!)_m.jpg"
            let url = URL(string: imageUrl)
            //print("FlickrPhoto init\n\(imageUrl)")
            
            if let cachedImage = AlbumVC.imageCache.object(forKey: url?.absoluteString as! NSString) {
                self.thumbnail = cachedImage
            }else{
                do{
                    let imageData: Data = try Data(contentsOf: URL(string: imageUrl)!, options: [])
                    //print("This is image data in init :\n\(imageData)")
                    let image: UIImage = UIImage(data: imageData)!
                    
                    self.thumbnail = image
                }catch{
                    print(error)
                }
            }
        }
    }
    
    static func photoFromResults(_ results: [[String:AnyObject]]) -> [FlickrPhoto] {
        var photos = [FlickrPhoto]()
        
        // iterate through array of dictionaries, each photo is a dictionary
        for photo in results {
            photos.append(FlickrPhoto(dictionary: photo))
        }
        return photos
    }
    
    
}
