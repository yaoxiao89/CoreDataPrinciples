//
//  ListItemsViewController.swift
//  CoreDataPrinciples
//
//  Copyright © 2019 Xiao Yao. All rights reserved.
//  See LICENSE.txt for licensing information.
//

import CoreData
import Foundation
import UIKit
import os.log

// MARK: - ListItemsViewControllerAction

enum ListItemsViewControllerAction {
    case select(ListItem)
}

// MARK: - ListItemsViewControllerDelegate

protocol ListItemsViewControllerDelegate: AnyObject {
    func listItemsViewController(_ viewController: ListItemsViewController, didPerform action: ListItemsViewControllerAction)
}

// MARK: - ListItemsViewController

class ListItemsViewController: UITableViewController {
    
    weak var listItemsDelegate: ListItemsViewControllerDelegate?
    
    private let dataController: NSFetchedResultsController<ListItem>
    private let formatter: DateFormatter
    
    init(context: NSManagedObjectContext) {
        dataController = ListItem.sorted(withContext: context)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        self.formatter = formatter
        super.init(style: .plain)
        dataController.delegate = self
        setupNavigationItem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNavigationItem() {
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addListItem))
        navigationItem.rightBarButtonItem = addItem
    }
    
    @objc private func addListItem() {
        let context = dataController.managedObjectContext
        let listItem = ListItem(context: context)
        listItem.creationDate = Date()
        try? context.save()
    }
    
}

// MARK: - View Lifecycle

extension ListItemsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchData()
    }
    
    private func setupTableView() {
        tableView.register(ListItemCell.self, forCellReuseIdentifier: ListItemCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
    }
    
    private func fetchData() {
        do {
            try dataController.performFetch()
            tableView.reloadData()
        } catch {
            /// For the demo, log the error
            /// In your application, please handle the error :)
            os_log("CoreData Error: %@", error.localizedDescription)
        }
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension ListItemsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let path = newIndexPath else { return }
            tableView?.insertRows(at: [path], with: .fade)
        case .delete:
            guard let path = indexPath else { return }
            tableView?.deleteRows(at: [path], with: .fade)
        case .update:
            guard let path = indexPath else { return }
            tableView?.reloadRows(at: [path], with: .fade)
        case .move:
            guard let deletePath = indexPath, let insertPath = newIndexPath else { return }
            tableView?.deleteRows(at: [deletePath], with: .fade)
            tableView?.insertRows(at: [insertPath], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView?.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView?.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move, .update:
            break
        }
    }
    
}

// MARK: - UITableViewDataSource

extension ListItemsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.reuseIdentifier, for: indexPath) as? ListItemCell else { return UITableViewCell() }
        let listItem = dataController.object(at: indexPath)
        bindCell(cell, to: listItem)
        return cell
    }
    
    private func bindCell(_ cell: ListItemCell, to listItem: ListItem) {
        guard let date = listItem.creationDate else {
            cell.label.text = "-"
            cell.accessoryType = .none
            return
        }
        cell.label.text = formatter.string(from: date)
        cell.accessoryType = listItem.isComplete ? .checkmark : .none
    }
    
}

// MARK: - UITableViewDelegate

extension ListItemsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        /// Use the view context to perform simple operations
        /// In this case, we are updating a boolean attribute
        let listItem = dataController.object(at: indexPath)
        listItem.isComplete = !listItem.isComplete
        try? dataController.managedObjectContext.save()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: nil) { (action, view, completionHandler) in
                /// Use the view context to perform simple operations
                /// In this case, we are deleting a list item
                let listItem = self.dataController.object(at: indexPath)
                let context = self.dataController.managedObjectContext
                context.delete(listItem)
                try? context.save()
                completionHandler(true)
        }
        deleteAction.title = "Delete"
        
        let editAction = UIContextualAction(
            style: .normal,
            title: nil) { (action, view, completionHandler) in
                let listItem = self.dataController.object(at: indexPath)
                self.listItemsDelegate?.listItemsViewController(self, didPerform: .select(listItem))
                completionHandler(true)
        }
        editAction.title = "Edit"
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return config
    }
    
}
