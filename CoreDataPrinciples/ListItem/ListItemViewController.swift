//
//  ListItemViewController.swift
//  CoreDataPrinciples
//
//  Copyright © 2019 Xiao Yao. All rights reserved.
//  See LICENSE.txt for licensing information.
//

import CoreData
import Foundation
import UIKit

// MARK: - ListItemViewControllerAction

enum ListItemViewControllerAction {
    case cancel
    case save
}

// MARK: - ListItemViewControllerDelegate

protocol ListItemViewControllerDelegate: AnyObject {
    func listItemViewController(_ viewController: ListItemViewController, didPerform action: ListItemViewControllerAction)
}

// MARK: - ListItemViewController

class ListItemViewController: UIViewController {
    
    weak var delegate: ListItemViewControllerDelegate?
    
    private let context: NSManagedObjectContext
    private let listItem: ListItem
    
    init(listItem: ListItem?, context: NSManagedObjectContext) {
        /// Create a private context
        let ctx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        ctx.persistentStoreCoordinator = context.persistentStoreCoordinator
        self.context = context
        
        if let item = listItem {
            self.listItem = self.context.object(with: item.objectID) as! ListItem
        } else {
            self.listItem = ListItem(context: self.context)
        }
        
        super.init(nibName: nil, bundle: nil)
        
        setupNavigationItem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNavigationItem() {
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelItem
        
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveItem
    }
    
    @objc private func cancel() {
        /// Do not save the context, the changes will be tossed
        delegate?.listItemViewController(self, didPerform: .cancel)
    }
    
    @objc private func save() {
        /// Save the context - the changes will be persisted
        try? context.save()
        delegate?.listItemViewController(self, didPerform: .save)
    }
    
}

// MARK: - View Lifecycle

extension ListItemViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(updateDate(datePicker:)), for: .valueChanged)
        view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc private func updateDate(datePicker: UIDatePicker) {
        listItem.creationDate = datePicker.date
    }
    
}
