//
//  FlickrHelper.swift
//  FlickrAlbum
//
//  Created by Vineet Singh on 23/07/18.
//  Copyright © 2018 Vineet Singh. All rights reserved.
//

import Foundation
import UIKit

class FlickrHelper: NSObject {
    
    class func URLForSearchString(searchString: String) -> String{
        
        let apiKey: String = "831d4b91cf42478740312437f49e7b6d"
        let search: String = searchString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(search)&per_page=20&page=\(AlbumVC.page)&format=json&nojsoncallback=1"
        
    }
    
    class func getImageURL(photo: FlickrPhoto, size: String) -> String{
        var _size: String = size
        
        if _size.isEmpty{
            _size = "m"
        }
        return "https://farm\(photo.farm!).staticflickr.com/\(photo.server!)/\(photo.photoID!)_\(photo.secret!)_\(_size).jpg"
        //https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
    }
    
    //class func getImage
    
    func photoData(searchStr: String, completion:@escaping(_ photos:[FlickrPhoto]?, _ error: Error?) -> Void){
        
        let searchURL: String = FlickrHelper.URLForSearchString(searchString: searchStr)
        
        guard let url = URL(string: searchURL) else{return}
        
        URLSession.shared.dataTask(with:url) { (data, response, error) in
            if error != nil {
                print(error)
                
                completion(nil,error)
            } else {
                do {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    
                    //print("URLSession Data Response:\n\(parsedData)")
                    if let photos = self.parsePhotos(JSONData: parsedData){
                        self.downloadImage(photoData: photos)
                        completion(photos,nil)
                    }
                } catch let error as NSError {
                    print(error)
                    completion(nil,error)
                }
            }
        }.resume()
        
    }
    
    func parsePhotos(JSONData: Any) -> [FlickrPhoto]? {
        if let dictionary = JSONData as? [String: AnyObject] {
            //print("*** This id dictionary parsed *** :\n\(dictionary)")
            if dictionary["stat"] as? String == "ok" {
                if let photos = dictionary["photos"]{
                    //print("These are photo :\n\(photos)")
                    if let photo = photos["photo"]{
                        //print("These are photo :\n\(photo)")
                        return FlickrPhoto.photoFromResults(photo as! [[String : AnyObject]])
                    }
                }
            }
        }
        return nil
    }
    
    func downloadLargeImage(farm: Int, server: String, photoId: String,secret: String){
        
        let imageUrl = "https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret)_b.jpg"
        
        guard let url = URL(string: imageUrl)else{return}
        DispatchQueue.global(qos: .background).async {
            if let cachedImage = AlbumVC.imageCache.object(forKey: imageUrl as NSString){
                print("Large Image in CacheFound")
                return
            }else{
                self.downloadImageFrom(urlString: imageUrl, completion: { (data) in
                    if let data = data {
                        guard let image: UIImage = UIImage(data: data)else{return}
                        AlbumVC.imageCache.setObject(image, forKey: imageUrl as NSString)
                    }
                })
            }
        }
    }
    
    func downloadImage(photoData: [FlickrPhoto]){
        
        DispatchQueue.global(qos: .background).async {
            
            for photo in photoData{
                
                let imageUrl = "https://farm\(photo.farm!).staticflickr.com/\(photo.server!)/\(photo.photoID!)_\(photo.secret!)_m.jpg"
                guard let url = URL(string: imageUrl)else{return}
                //print("FlickrPhoto init\n\(imageUrl)")
                
                if let cachedImage = AlbumVC.imageCache.object(forKey: imageUrl as NSString) {
                    return
                } else {
                    
                    self.downloadImageFrom(urlString: imageUrl, completion: { (data) in
                        if let data = data {
                            guard let image: UIImage = UIImage(data: data)else{return}
                            AlbumVC.imageCache.setObject(image, forKey: imageUrl as NSString)
                        }
                    })
                }
            }
        }
    }
    
    func downloadImageFrom(urlString:String, completion:@escaping(Data?)->()) {
        guard let url = URL(string:urlString) else { return }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, _, err) in
            if err != nil {
                // handle error if any
            }
            // you should check the reponse status
            // if data is a json object/dictionary so decode it
            // if data is regular data then pass it to your callback
            completion(data)
            }.resume()
    }
    
    class func sharedInstance() -> FlickrHelper {
        struct Singleton {
            static var sharedInstance = FlickrHelper()
        }
        return Singleton.sharedInstance
    }
}




