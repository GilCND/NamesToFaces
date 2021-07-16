//
//  ViewController.swift
//  nameToFaces
//
//  Created by Felipe Gil on 2021-06-21.
//

import UIKit
	
class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var people: [Person] = []
    
    
    let loadingActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
            indicator.style = .large
            indicator.color = .white
            indicator.startAnimating()
            indicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            return indicator
    }()
    let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.alpha = 0.9
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return blurEffectView
        }()
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }

    override internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        people.count
    }
    
    override internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            self.present(picker, animated: true)
        }
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imageName = UUID().uuidString
        
        guard let image = info[.editedImage] as? UIImage,
              let imagepath = getDocumentsDirectory()?.appendingPathComponent(imageName) else { return }
    
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagepath)
        }
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        dismiss(animated: true){ [weak self] in
            guard let self = self else { return }
            self.stopLoadingAnimation()
        }
    }
    
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true){ [weak self] in
            guard let self = self else { return }
            self.stopLoadingAnimation()
        }
    }
    
    private func getDocumentsDirectory() -> URL? {
       FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    override internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        	
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
    
        present(alertController, animated: true)
        
    }
    private func makeRenameAlertViewController(indexPath: IndexPath) -> UIAlertController {
        
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
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false // This is an explicit declaration that auto resizing masks won't be used
              loadingActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        #warning("Is there a way to make both suibviews to be called in one line?")
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.addSubview(blurEffectView)
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.addSubview(loadingActivityIndicator)
        
              NSLayoutConstraint.activate([
                
                  // the lines below basically say that all edges of the blur effect view will be pinned to the view's ones
                  blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
                  blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                  blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                  blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                  // and these place the indicator centered in the view at all times
                  loadingActivityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                  loadingActivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
              ])
    }
    
    private func stopLoadingAnimation() {
        blurEffectView.removeFromSuperview()
        loadingActivityIndicator.removeFromSuperview()
    }
}

