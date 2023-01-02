//
//  ViewController.swift
//  SeaFood
//
//  Created by Eyüp Mert on 2.01.2023.
//

import UIKit
import CoreML
import Vision

// UIIMagePickerControllerDelegate always works with UINavigationController delegate.
// That's also why ViewController embedded in navigation controller.
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        // Source of image. Can be camera too if test is on real device.
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
    }
    
    /// Delegate method which returns an UIImage from picker, also possible to allow user to edit image.
    /// - Parameters:
    ///   - picker: UIImagePickerView.
    ///   - info: Result of image picking process. It may includes image or video. It can be edited or original.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Set user picked image as an image to current apps image view.
            imageView.image = userPickedImage
            // Cast userPickedImage to CIImage. This allows app to detect image in Vision framework.
            guard let ciiImage = CIImage(image: userPickedImage) else {
                fatalError("Image could not converted to CIImage.")
            }
            // Pass CIImage version of userPickedImage to AI model.
            detect(image: ciiImage)
        }
        imagePicker.dismiss(animated: true)
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true)
    }
    
    
    /// Get image selected by user in CIImage format and create request with that image.
    /// - Parameter image: User selected image's CIImage version.
    func detect(image: CIImage) {
        
        // Create model from Vision framework with Inception model.
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Model creation error.")
        }
        
        // Create request and get results from Vision framework.
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Image model result could not processed.")
            }
            // First result is tend to be most accurate result.
            // Check is this one includes selected keyword and show it as a result in title of navigation item.
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
        }
        // Create handler for image request.
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            // Perform request.
            try! handler.perform([request])
        } catch {
            
        }
    }
}

