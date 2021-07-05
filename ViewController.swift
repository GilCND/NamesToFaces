//
//  ViewController.swift
//  nameToFaces
//
//  Created by Felipe Gil on 2021-06-21.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var people: [Person] = []
    let loadingVC = LoadingViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let person = people[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell, let path = getDocumentsDirectory()?.appendingPathComponent(person.image) else {
            fatalError("Enable to deque PersonCell")
        }
        cell.name.text = person.name
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    @objc private func addNewPerson() {
        startLoadingAnimation()
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        stopLoadingAnimation()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imageName = UUID().uuidString
        guard let image = info[.editedImage] as? UIImage,
              let imagepath = getDocumentsDirectory()?.appendingPathComponent(imageName) else { return }
    
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagepath)
        }
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        dismiss(animated: true)
    }
    
    private func getDocumentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        	
        let alertController = UIAlertController(title: nil, message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let renameAlertViewController = self.makeRenameAlertViewController(indexPath: indexPath)
            self.present(renameAlertViewController, animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self, weak alertController] _ in
            guard let self = self else { return }
            self.people.remove(at: indexPath.item)
            alertController?.dismiss(animated: true)
            self.collectionView.reloadData()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alertController] _ in
            alertController?.dismiss(animated: true)
        }))
    
        self.present(alertController, animated: true)
        
    }
    func makeRenameAlertViewController(indexPath: IndexPath) -> UIAlertController {
        
        let renameAlertController = UIAlertController(title: "Rename", message: "What's the new name?", preferredStyle: .alert)
        renameAlertController.addTextField()
        
        renameAlertController.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self, weak renameAlertController] _ in
            guard let self = self, let newName = renameAlertController?.textFields?[0].text else { return }
            self.people[indexPath.item].name = newName
            
            self.collectionView.reloadData()
        })
        
        renameAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak renameAlertController] _ in
            
            renameAlertController?.dismiss(animated: true)
          
        }))
        return renameAlertController
    }
    
    private func startLoadingAnimation() {
        loadingVC.modalPresentationStyle = .overCurrentContext
        loadingVC.modalTransitionStyle = .crossDissolve
        present(loadingVC, animated: true, completion: nil)
    }
    
    private func stopLoadingAnimation() {
        loadingVC.dismiss(animated: true, completion: nil)
    }
}

