//
//  ProductViewController.swift
//  Kaique
//
//  Created by Kaique Coqueiro on 25/11/18.
//  Copyright © 2018 Kaique Coqueiro. All rights reserved.
//

import UIKit
import CoreData

class ProductViewController: UIViewController {
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var tfValue: UITextField!
    @IBOutlet weak var stCard: UISwitch!
    
    var product: Product!
    var smallImage: UIImage!
    var pickerView: UIPickerView!
    var dataSource:[State] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        
        tfState.inputView = pickerView
        
        tfState.inputAccessoryView = toolbar
        
        loadStates()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addImage(tapGestureRecognizer:)))
        ivImage.isUserInteractionEnabled = true
        ivImage.addGestureRecognizer(tapGestureRecognizer)
        
        if product != nil {
            tfName.text = product.name
            tfValue.text = "\(product.value)"
            tfState.text = product.states?.name
            stCard.setOn(product.card, animated: false)
            if let image = product.image as? UIImage {
                ivImage.image = image
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    
    func cancel() {
        
        tfState.resignFirstResponder()
    }
    
    func done() {
        
        tfState.text = dataSource[pickerView.selectedRow(inComponent: 0)].name
        
        cancel()
    }
    
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }

    @IBAction func addImage(tapGestureRecognizer: UITapGestureRecognizer) {
        
        let alert = UIAlertController(title: "Selecionar imagem", message: "De onde você quer escolher a imagem?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        }
        alert.addAction(photosAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    @IBAction func registerProduct(_ sender: Any) {
        if product == nil {
            product = Product(context: context)
        }
        
        if (tfName.text?.isEmpty)! {
            alertWithTitle(title: "Erro", message: "Digite o nome do produto.", ViewController: self, toFocus:tfName)
            return
        } else {
            product.name = tfName.text
        }
        
        if (tfState.text?.isEmpty)! {
            alertWithTitle(title: "Erro", message: "Escolha um estado.", ViewController: self, toFocus:tfState)
            return
        } else {
             product.states = dataSource[pickerView.selectedRow(inComponent: 0)]
        }
        
        if (tfValue.text?.isEmpty)! {
            alertWithTitle(title: "Erro", message: "Digite um valor para o produto.", ViewController: self, toFocus:tfValue)
            return
        } else {
            product.value = Double(tfValue.text!)!
        }
        
        
        product.card = stCard.isOn
        if smallImage != nil {
            product.image = smallImage
        }
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }

    }
    
    func alertWithTitle(title: String!, message: String, ViewController: UIViewController, toFocus:UITextField) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
            toFocus.becomeFirstResponder()
        });
        alert.addAction(action)
        ViewController.present(alert, animated: true, completion:nil)
    }

    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()

        imagePicker.sourceType = sourceType
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
}


extension ProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        
        let smallSize = CGSize(width: 278, height: 134.5)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        ivImage.image = smallImage
        
        dismiss(animated: true, completion: nil)
    }
}

extension ProductViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return dataSource[row].name
    }
}

extension ProductViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
}

