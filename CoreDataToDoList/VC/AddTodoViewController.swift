//
//  AddTodoListAppViewController.swift
//  CoreDataToDoList
//
//  Created by Sophie Jacquot  on 22/05/2021.
//

import UIKit
import CoreData

class AddTodoViewController: UIViewController {
    
    // MARK: - Properties
    
    var managedContext: NSManagedObjectContext!
    var todo: Todo?
    
    // MARK: Outlets
    
//    @IBOutlet weak var textView: UITextView!
//    @IBOutlet weak var segmentedControl: UISegmentedControl!
//    @IBOutlet weak var doneButton: UIButton!
//    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var boutonAnnuler: UIButton!
    @IBOutlet weak var boutonValider: UIButton!
    @IBOutlet weak var bottomConstraint : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(with:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        textView.becomeFirstResponder()
        
        if let todo = todo {
            textView.text = todo.title
            textView.text = todo.title
            segmentedControl.selectedSegmentIndex = Int(todo.priority)
        }
    }
    
    // MARK: Actions
    
    @objc func keyboardWillShow(with notification: Notification) {
        let key = "UIKeyboardFrameEndUserInfoKey"
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height + 16
        
        bottomConstraint.constant = keyboardHeight
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    fileprivate func dismissAndResign() {
        dismiss(animated: true)
        textView.resignFirstResponder()
    }
    
    
    @IBAction func annuler(_ sender: UIButton) {
        dismissAndResign()
    }
    
    @IBAction func valider(_ sender: UIButton) {
        guard let title = textView.text, !title.isEmpty else {
            return
        }
       
        if let todo = self.todo {
            todo.title = title
            todo.priority = Int16(segmentedControl.selectedSegmentIndex)
        } else {
            let todo = Todo(context: managedContext)
            todo.title = title
            todo.priority = Int16(segmentedControl.selectedSegmentIndex)
            todo.date = Date()
        }
        
        do {
            try managedContext.save()
            dismissAndResign()
        } catch {
            print("Error saving todo: \(error)")
        }
        
    }

}

extension AddTodoViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if boutonValider.isHidden {
            textView.text.removeAll()
            textView.textColor = .white
            
            boutonValider.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
