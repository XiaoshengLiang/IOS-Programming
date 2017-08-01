//
//  CustomTabBarController.swift
//  Chatty
//
//  Created by LiangXiaosheng on 2017/4/22.
//  Copyright © 2017 LiangXiaosheng. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        //set up Custom View Controller
        let friendController = FriendsController(collectionViewLayout: UICollectionViewFlowLayout())
        let recentMessagesNavController = UINavigationController(rootViewController: friendController)
//        recentMessagesNavController.tabBarItem.title = "Recent"
        recentMessagesNavController.tabBarItem.image = UIImage(named: "Contacts-50")
        
        viewControllers = [recentMessagesNavController, createDummyNavControllerWithTitle(imageName: "Settings-50"), ]

    }
    
    private func createDummyNavControllerWithTitle(imageName:String)->UINavigationController {
        let viewController = UIViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
//        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = UIImage(named:imageName)
        return navigationController
    }
}
