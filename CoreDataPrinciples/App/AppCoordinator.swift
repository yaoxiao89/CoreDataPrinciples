//
//  AppCoordinator.swift
//  CoreDataPrinciples
//
//  Copyright © 2019 Xiao Yao. All rights reserved.
//  See LICENSE.txt for licensing information.
//

import Foundation
import UIKit

// MARK: - AppCoordinator

class AppCoordinator {
    
    let coreDataController = CoreDataController()
    let rootViewController: UIViewController
    
    init() {
        let context = coreDataController.viewContext
        let listItemsVC = ListItemsViewController(context: context)
        let navController = UINavigationController(rootViewController: listItemsVC)
        rootViewController = navController
        listItemsVC.listItemsDelegate = self
    }
    
}

// MARK: - ListItemViewControllerDelegate

extension AppCoordinator: ListItemViewControllerDelegate {
    
    func listItemViewController(_ viewController: ListItemViewController, didPerform action: ListItemViewControllerAction) {
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - ListItemsViewControllerDelegate

extension AppCoordinator: ListItemsViewControllerDelegate {
    
    func listItemsViewController(_ viewController: ListItemsViewController, didPerform action: ListItemsViewControllerAction) {
        switch action {
        case .select(let listItem):
            let listItemVC = ListItemViewController(listItem: listItem, context: coreDataController.viewContext)
            listItemVC.delegate = self
            let navController = UINavigationController(rootViewController: listItemVC)
            rootViewController.present(navController, animated: true, completion: nil)
        }
    }
    
}
