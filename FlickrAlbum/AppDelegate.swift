//
//  AppDelegate.swift
//  FlickrAlbum
//
//  Created by Vineet Singh on 23/07/18.
//  Copyright © 2018 Vineet Singh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 1.0, green: 51/255, blue: 101/255, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        
        // Override point for customization after application launch.
        return true
    }

}

