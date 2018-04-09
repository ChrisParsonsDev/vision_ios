//
//  ViewController.swift
//  aivision-ios
//
//  Created by Chris Parsons on 05/04/2018.
//  Copyright © 2018 Chris Parsons. All rights reserved.
//

import UIKit

class ClassificationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var classificationImageView: UIImageView!
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var chooseImageButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Disable Camera if there's not one..
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        //Image/text Properties
        classificationImageView.contentMode  = .scaleAspectFit
        classificationLabel.text = "Choose an Image to Classify"
        confidenceLabel.text =  ""
    }
    
    //MARK: Methods
    @IBAction func chooseImageFromAlbum(_ sender: Any) {
        let pickerView = UIImagePickerController()
        pickerView.delegate = self
        pickerView.sourceType = .photoLibrary
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func chooseImageFromCamera(_ sender: Any) {
        let pickerView = UIImagePickerController()
        pickerView.delegate = self
        pickerView.sourceType = .camera
        self.present(pickerView, animated: true, completion: nil)
    }
    
    
    func classifyImage(image: UIImage){
        //URL for your AI Vision instance and model
        let urlString = "API URL HERE"
        
        //Set up HTTP Request Object
        var request  = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        
        let imageData = UIImagePNGRepresentation(image)!
        let fileName = "upload.png"
        let fullData = photoDataToFormData(data: imageData,boundary:boundary,fileName:fileName)
        
        request.setValue(String(fullData.count), forHTTPHeaderField: "Content-Length")

        
        request.httpBody = fullData
        request.httpShouldHandleCookies = false
        
        //Perform API Call
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            guard let data = data, error == nil else { return }
            do {
                //Convert response to JSON
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                guard let classification = jsonResponse["classified"] as? [String: AnyObject] else {
                    print("Could not find classification")
                    return
                }
                
                // Retrieve values from API
                let responseClass = Array(classification.keys)[0]
                let responseConfidence = Array(classification.values)[0]
                let responseConfidenceString =  responseConfidence as? String ?? ""
                
                //Update Labels
                performUIUpdatesOnMain{
                    self.classificationLabel.text = responseClass
                    self.confidenceLabel.text = responseConfidenceString
                }
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
    
    func photoDataToFormData(data:Data,boundary:String,fileName:String) -> Data {
        let fullData = NSMutableData()
        
        // 1 - Boundary should start with --
        let lineOne = "--" + boundary + "\r\n"
        fullData.append(lineOne.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"files\"; filename=\"" + fileName + "\"\r\n"
        NSLog(lineTwo)
        fullData.append(lineTwo.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 3
        let lineThree = "Content-Type: image/jpg\r\n\r\n"
        fullData.append(lineThree.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 4
        fullData.append(data as Data)
        
        // 5
        let lineFive = "\r\n"
        fullData.append(lineFive.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 6 - The end
        let lineSix = "--" + boundary + "--\r\n"
        fullData.append(lineSix.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        return fullData as Data
    }
    
    
    //MARK: Delegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            classificationImageView.image = image
            self.classificationLabel.text = ""
            self.confidenceLabel.text = ""
            //Classify the image
            classifyImage(image: image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

