//
//  AlbumVC.swift
//  FlickrAlbum
//
//  Created by Vineet Singh on 23/07/18.
//  Copyright © 2018 Vineet Singh. All rights reserved.
//

import UIKit

class AlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var loaderImage: UIImageView!
    
    static var page = 1
    
    static var searchString: String?
    
    var flickrPhotos: [FlickrPhoto] = [FlickrPhoto]()
    
    var currentIndex: IndexPath?
    
    static var total: Int = 20
    static var constantTotal: Int = 20
    
    var imageUrlString: String?
    
    
    //Animator
    let transition = PopAnimator()
    var selectedImage: UIImageView?

    let detailObj = DetailImageVC()
    
    private var animationController: PopAnimator = PopAnimator()
    var hideSelectedCell: Bool = false
    
    
    
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
    
        self.navigationController?.delegate = self
        
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
        self.collectionView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 50, right: 0)
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
        total += constantTotal
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func loadingAnim(){
        
        loaderView.isHidden = false
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
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
        
        //Pagination
        
        if indexPath.row == (AlbumVC.total - 2){
            AlbumVC.getMorePage()
            self.loadingAnim()
            
            print("*** Pagination Started \(indexPath.row)  ***")
            
            FlickrHelper.sharedInstance().photoData(searchStr: AlbumVC.searchString!) { (photos, error) in
                if error == nil{
                    if let photos = photos{
                        self.flickrPhotos.append(contentsOf: photos)
                        DispatchQueue.main.async {
                            self.stopLoadingAnim()
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
        
        //Prefetching Large Images Data
        
        let photo = self.flickrPhotos[indexPath.row]

        FlickrHelper.sharedInstance().downloadLargeImage(farm: photo.farm!, server: photo.server!, photoId: photo.photoID!, secret: photo.secret!)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //changing cell per row
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let minimumSpace = CGFloat((AlbumVC.numberOfCellsPerRow - 1) * 10)
        let cellWidth = (screenWidth - minimumSpace) / CGFloat(AlbumVC.numberOfCellsPerRow)
        let size = CGSize(width: cellWidth, height: cellWidth)
        
        return size;
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.flickrPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
        
        
        let photo = self.flickrPhotos[indexPath.row]
        
        let imageUrl = "https://farm\(photo.farm!).staticflickr.com/\(photo.server!)/\(photo.photoID!)_\(photo.secret!)_m.jpg"
        
        //checking if the image is in Cache:
        
        if let cachedImage = AlbumVC.imageCache.object(forKey: imageUrl as NSString) {
            
            
            cell.imageVIew.image = cachedImage
        
        }else{
            cell.imageVIew.image = photo.thumbnail
            
            if cell.imageVIew.image == nil{
                
                cell.imageVIew.image = UIImage(named: "Placeholder")
                
                self.imageUrlString = imageUrl
                
                DispatchQueue.main.async {
                    FlickrHelper.sharedInstance().downloadImageFrom(urlString: imageUrl, completion: { (data) in
                        if let data = data {
                            guard let image: UIImage = UIImage(data: data)else{return}
                            DispatchQueue.main.async {
                                if self.imageUrlString == imageUrl{
                                    cell.imageVIew.image = image
                                    AlbumVC.imageCache.setObject(image, forKey: imageUrl as NSString)
                                    let visibleIndexPath = collectionView.indexPathsForVisibleItems
                                    collectionView.reloadItems(at: visibleIndexPath)
                                }
                            }
                        }
                    })
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = self.collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        
        self.selectedImage = cell.imageVIew
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
    
    //Searching for the entered Keyword:
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        self.collectionView.setContentOffset(CGPoint(x: 0, y: 44), animated: true)
        self.loadingAnim()
        FlickrHelper.sharedInstance().photoData(searchStr: AlbumVC.searchString!) { (photos, error) in
            if error == nil{
                if let photos = photos{
                    self.flickrPhotos = photos
                    DispatchQueue.main.async {
                        self.stopLoadingAnim()
                        self.collectionView.reloadData()
                        AlbumVC.constantTotal = 20
                        AlbumVC.total = 20
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














