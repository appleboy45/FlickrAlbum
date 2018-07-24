//
//  AlbumVC.swift
//  FlickrAlbum
//
//  Created by Vineet Singh on 23/07/18.
//  Copyright © 2018 Vineet Singh. All rights reserved.
//

import UIKit

class AlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var loaderImage: UIImageView!
    
    static var page = 1
    
    static var searchString: String?
    
    var flickrPhotos: [FlickrPhoto] = [FlickrPhoto]()
    
    var currentIndex: IndexPath?
    
    static var total: Int?
    static var constantTotal: Int?
    
    var imageUrlString: String?
    
    
    //Animator
    let transition = PopAnimator()
    var selectedImage: UIImageView?
    
    //settingTapped
    //let settings = SettingsLauncher()
    
    //numberOfCellsPerRow
    static var numberOfCellsPerRow: Int = 2
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    
    //loader
    var indicatorFooter : UIActivityIndicatorView!
    
    //caching
    static var imageCache = NSCache<NSString, UIImage>()
    
    //searchBar
    var searchBar:UISearchBar = {
        let srch = UISearchBar()
        srch.placeholder = "Search"
        
        //srch.enablesReturnKeyAutomatically = true
        // srch.setShowsCancelButton(true, animated: true)
        return srch
    }()
    
    lazy var settingsLauncher: SettingsLauncher = {
        
        let launcher = SettingsLauncher()
        launcher.albumVC = self
        return launcher
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transition.dismissCompletion = {
            self.selectedImage!.isHidden = false
        }
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        SettingsLauncher.albumCollectionView = self.collectionView
        
        searchBar.frame =  CGRect(x: 0, y: 0, width: view.bounds.width - 44.0, height: 44.0)
        searchBar.delegate = self
        
        loaderView.isHidden = true
        loaderImage.image = UIImage(named: "loader")?.withRenderingMode(.alwaysTemplate)
        loaderImage.tintColor = UIColor(red: 1.0, green: 51/255, blue: 101/255, alpha: 1.0)
        self.navigationItem.titleView = searchBar
        
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "threeDotMenu")?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        button.tintColor = UIColor.white
        button.addTarget(self, action:#selector(self.actionBtnTapped), for:.touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 1.0, green: 51/255, blue: 101/255, alpha: 1.0)
        
        self.navigationController?.hidesBarsOnSwipe = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.titleView = searchBar
        self.collectionView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        AlbumVC.constantTotal = 19
        AlbumVC.total = 19
        
        
    }
    
    @objc func actionBtnTapped(){
        settingsLauncher.showSettings()
    }
    
    func reloadCollectionView(){
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    class func getMorePage(){
        page = page + 1
        total! += constantTotal!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    //end of the scroll view then load next 20 data from api
    //    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    //
    //        self.loadingAnim()
    //
    //    }
    //
    //    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
    //    }
    //
    //    func scrollViewDidScrollToTop(_ scrollView: UIScrollView){
    //        self.loaderView.isHidden = true
    //    }
    
    //    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
    //    }
    
    //   request web to down load data
    
    func loadingAnim(){
        
        loaderView.isHidden = false
        var animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = Int(M_PI_2)
        animation.duration = 0.075
        animation.isCumulative = true
        animation.repeatCount = HUGE
        loaderImage.layer.add(animation, forKey: "loaderImage")
    }
    
    func stopLoadingAnim(){
        if loaderImage.isAnimating{
            loaderImage.layer.removeAllAnimations()
        }
        loaderView.isHidden = true
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let currentRow = indexPath.row
        
        print("*** INdexXXXX: \(indexPath.row)  ***")
        
        print("*** total: \(AlbumVC.total)  ***")
        
        
        //print(" **** These are images in CACHE\(AlbumVC.imageCache)")
        if indexPath.row == AlbumVC.total{
            AlbumVC.getMorePage()
            self.loadingAnim()
            
            print("*** Pagination Started \(indexPath.row)  ***")
            
            FlickrHelper.sharedInstance().photoData(searchStr: AlbumVC.searchString!) { (photos, error) in
                //print("\(photos)")
                if error == nil{
                    if let photos = photos{
                        self.flickrPhotos.append(contentsOf: photos)
                        //print("\(self.flickrPhotos)")
                        DispatchQueue.main.async {
                            self.stopLoadingAnim()
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
        
            //Prefetching and caching large images :
            DispatchQueue.global(qos: .background).async {
                
                for photo in self.flickrPhotos{
                    FlickrHelper.sharedInstance().downloadLargeImage(farm: photo.farm!, server: photo.server!, photoId: photo.photoID!, secret: photo.secret!)
                }
                
            }
        
        
        
        
//        let photo = self.flickrPhotos[indexPath.row]
//
//        FlickrHelper.sharedInstance().downloadLargeImage(farm: photo.farm!, server: photo.server!, photoId: photo.photoID!, secret: photo.secret!)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //        if UIScreen.main.bounds.width < 375{
        //            return CGSize(width: 100, height: 100)
        //        }else{
        //            return CGSize(width: 110, height: 110)
        //        }
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let minimumSpace = CGFloat((AlbumVC.numberOfCellsPerRow - 1) * 10)
        //print("minimumSpace :\(minimumSpace)")
        let cellWidth = (screenWidth - minimumSpace) / CGFloat(AlbumVC.numberOfCellsPerRow)
        let size = CGSize(width: cellWidth, height: cellWidth)
        //print("\(size)")
        
        return size;
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("\(self.flickrPhotos.count)")
        return self.flickrPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
        
        //print("\(self.flickrPhotos[indexPath.row].thumbnail)")
        
        let photo = self.flickrPhotos[indexPath.row]
        
        let imageUrl = "https://farm\(photo.farm!).staticflickr.com/\(photo.server!)/\(photo.photoID!)_\(photo.secret!)_m.jpg"
        
        let url = URL(string: imageUrl)
        
        if let cachedImage = AlbumVC.imageCache.object(forKey: imageUrl as NSString) {
            
            //print("******** Cached Imge In cellForRowAt ****")
            
            cell.imageVIew.image = cachedImage
        }else{
            cell.imageVIew.image = photo.thumbnail
            
            if cell.imageVIew.image == nil{
                
                cell.imageVIew.image = UIImage(named: "Placeholder")
                
                self.imageUrlString = imageUrl
                
                let imageUrl = "https://farm\(photo.farm!).staticflickr.com/\(photo.server!)/\(photo.photoID!)_\(photo.secret!)_m.jpg"
                //print("*** cellForRow AT \n\(imageUrl)")
                
                FlickrHelper.sharedInstance().downloadImageFrom(urlString: imageUrl, completion: { (data) in
                    if let data = data {
                        guard let image: UIImage = UIImage(data: data)else{return}
                        DispatchQueue.main.async {
                            if self.imageUrlString == imageUrl{
                                cell.imageVIew.image = image
                                AlbumVC.imageCache.setObject(image, forKey: imageUrl as NSString)
                            }
                        }
                    }
                })
                
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = self.collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        
        selectedImage = cell.imageVIew
        self.currentIndex = indexPath
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "detailImage") as! DetailImageVC
        mainVC.thumbnail = cell.imageVIew.image
        mainVC.farm = self.flickrPhotos[indexPath.row].farm
        mainVC.secret = self.flickrPhotos[indexPath.row].secret
        mainVC.server = self.flickrPhotos[indexPath.row].server
        mainVC.photoID = self.flickrPhotos[indexPath.row].photoID
        mainVC.transitioningDelegate = self
        self.present(mainVC, animated: true, completion: nil)
    }
}

extension AlbumVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        self.collectionView.setContentOffset(CGPoint(x: 0, y: 44), animated: true)
        self.loadingAnim()
        FlickrHelper.sharedInstance().photoData(searchStr: AlbumVC.searchString!) { (photos, error) in
            //print("\(photos)")
            if error == nil{
                if let photos = photos{
                    self.flickrPhotos = photos
                    //print("\(self.flickrPhotos)")
                    DispatchQueue.main.async {
                        self.stopLoadingAnim()
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        self.collectionView.reloadData()
        self.collectionView.setContentOffset(CGPoint(x: 0, y: 44), animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //reloading here
        if searchBar.text == nil || searchBar.text == ""{
            searchBar.setShowsCancelButton(false, animated: true)
            view.endEditing(true)
            self.collectionView.setContentOffset(CGPoint(x: 0, y: 44), animated: true)
            
            return
        }else {
            AlbumVC.searchString = searchBar.text
        }
    }
}

extension AlbumVC: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.originFrame =
            selectedImage!.superview!.convert(selectedImage!.frame, to: nil)
        
        transition.presenting = true
        selectedImage!.isHidden = true
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
    
    
    
}














