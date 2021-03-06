//
//  TableViewController.swift
//  CoreDataToDoList
//
//  Created by Sophie Jacquot  on 22/05/2021.
//

import UIKit
import CoreData

class TodoTableViewController: UITableViewController {
   
    
    // MARK: - Properties
    
    var todos: [Todo] = []
    
    var resultsController: NSFetchedResultsController<Todo>!
    let coreDataStack = CoreDataStack()
    
    private var managedContext: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Request
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        
        // Init
        request.sortDescriptors = [sortDescriptors]
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        resultsController.delegate = self
        
        // Fetch
        do {
            try resultsController.performFetch()
        } catch {
            print("Perform fetch error: \(error)")
        }
        
//        let searchController = UISearchController(searchResultsController: nil)
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchResultsUpdater = self
//        navigationItem.searchController = searchController
//        navigationItem.leftBarButtonItem = editButtonItem
        
    }
    
    //MARK: - Private Methods
    
//    private func fetchItems(searchQuery: String? = nil) -> [Todo] {
//        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
//
//        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
//        let titleSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//
//        fetchRequest.sortDescriptors = [dateSortDescriptor, titleSortDescriptor]
//
//        resultsController = NSFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: coreDataStack.managedContext,
//            sectionNameKeyPath: nil,
//            cacheName: nil
//        )
//        resultsController.delegate = self
//
//        if let searchQuery = searchQuery, !searchQuery.isEmpty {
//            let predicate = NSPredicate(format: "%K contains[cd] %@",
//                                        argumentArray: [#keyPath(Todo.title), searchQuery])
//            fetchRequest.predicate = predicate
//        }
//
//        do {
//            return try self.managedContext.fetch(fetchRequest)
//        } catch {
//            print("Perform fetch error: \(error)")
//        }
//    }
    

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)

        let todo = resultsController.object(at: indexPath)
        cell.textLabel?.text = todo.title
        cell.detailTextLabel?.text = DateFormatter.localizedString(
            from: todo.date!,
            dateStyle: .medium,
            timeStyle: .short
        )

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Supprimer") { (action, view, completion) in
            // TODO: Delete todo
            let todo = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(todo)
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("delete failed: \(error)")
                completion(false)
            }
        }
        action.image = UIImage(named: "trash")
        action.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Fait") { (action, view, completion) in
            let todo = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(todo)
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("delete failed: \(error)")
                completion(false)
            }
        }
        action.image = UIImage(named: "check")
        action.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowAddTodo", sender: tableView.cellForRow(at: indexPath))
    }
    
     // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddTodoViewController {
            vc.managedContext = resultsController.managedObjectContext
        }
        
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? AddTodoViewController {
            vc.managedContext = resultsController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell) {
                let todo = resultsController.object(at: indexPath)
                vc.todo = todo
            }
        }
     }
}

extension TodoTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                let todo = resultsController.object(at: indexPath)
                cell.textLabel?.text = todo.title
            }
        default:
            break
        }
    }
}

//extension TodoTableViewController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        let searchQuery = searchController.searchBar.text
//        todos = fetchItems(searchQuery: searchQuery)
//        tableView.reloadData()
//    }
//}

