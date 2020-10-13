//
//  HypeListViewController.swift
//  Hype
//
//  Created by Austin Goetz on 10/12/20.
//

import UIKit

class HypeListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var hypeTableView: UITableView!
    
    // MARK: - Properties
    var refresh: UIRefreshControl = UIRefreshControl()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        loadData()
    }
    
    // MARK: - Actions
    @IBAction func addHypeButtonTapped(_ sender: Any) {
        presentHypeAlert(nil)
    }
    
    // MARK: - Class Functions
    func setUpViews() {
        hypeTableView.delegate = self
        hypeTableView.dataSource = self
        refresh.attributedTitle = NSAttributedString(string: "Pull to see new Hypes")
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)
        hypeTableView.addSubview(refresh)
    }
    
    func updateViews() {
        // Should we dispatch queue here?
        DispatchQueue.main.async {
            self.hypeTableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    @objc func loadData() {
        HypeController.shared.fetchAllHypes { (result) in
            switch result {
            case .success(let hypes):
                HypeController.shared.hypes = hypes
                self.updateViews()
            case .failure(let error):
                // Present error to user
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    func presentHypeAlert(_ hype: Hype?) {
        let alertController = UIAlertController(title: "Get Hype!", message: "What is Hype may never die", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "What is Hype today?"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
            
            if let hype = hype {
                textField.text = hype.body
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Send", style: .default) { (_) in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
            
            if let hype = hype {
                HypeController.shared.update(hype) { (result) in
                    switch result {
                    case .success(_):
                        self.updateViews()
                    case .failure(let error):
                        // Present user with error
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    }
                }
            } else {
                HypeController.shared.saveHypeWith(text: text) { (result) in
                    switch result {
                    case .success(let hype):
                        // Insert saved hype at the first index of the array
                        HypeController.shared.hypes.insert(hype, at: 0)
                        self.updateViews()
                    case .failure(let error):
                        // Present user with error
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    }
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
// MARK: - Extensions
extension HypeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        HypeController.shared.hypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hypeCell", for: indexPath)
        
        let hypeToDisplay = HypeController.shared.hypes[indexPath.row]
        cell.textLabel?.text = hypeToDisplay.body
        cell.detailTextLabel?.text = hypeToDisplay.timestamp.formatDate()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedHype = HypeController.shared.hypes[indexPath.row]
        presentHypeAlert(selectedHype)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let hypeToDelete = HypeController.shared.hypes[indexPath.row]
            guard let indexOfHypeToDelete = HypeController.shared.hypes.firstIndex(of: hypeToDelete) else { return }
            
            HypeController.shared.delete(hypeToDelete) { (result) in
                switch result {
                case .success(let success):
                    if success {
                        HypeController.shared.hypes.remove(at: indexOfHypeToDelete)
                        DispatchQueue.main.async {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    // Present error to user
                }
            }
        }
    }
}
