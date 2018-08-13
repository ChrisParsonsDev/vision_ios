//
//  DetectionViewController.swift
//  aivision-ios
//
//  Created by Chris Parsons on 13/08/2018.
//  Copyright © 2018 Chris Parsons. All rights reserved.
//

import UIKit

class DetectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var detectionImageView: UIImageView!
    @IBOutlet weak var labelTableView: UITableView!
    @IBOutlet weak var chooseImageButton: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Properties
    var objectsDetected: [ObjectDetectionClassification] = [ObjectDetectionClassification(classification: "Hello", confidence: "world")]

    
    //MARK: Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Disable camera if there's not one..
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        //Initate Table View
        tableView.tableFooterView = UIView(frame: .zero)
    }

    //MARK: Methods
    @IBAction func chooseImageFromCamera(_ sender: Any) {
        let pickerView = UIImagePickerController()
        pickerView.delegate = self
        pickerView.sourceType = .camera
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func chooseImageFromAlbum(_ sender: Any) {
        let pickerView = UIImagePickerController()
        pickerView.delegate = self
        pickerView.sourceType = .photoLibrary
        self.present(pickerView, animated: true, completion: nil)
    }
    
    
    func classifyImage(image: UIImage){
        //URL for your AI Vision instance and model
        let urlString = "Insert API URL Here"
        
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
                guard let _ = jsonResponse["classified"] as? [String: AnyObject] else {
                    print("Could not find classification")
                    return
                }
                
                // Retrieve values from API
                
                //Update Labels
                performUIUpdatesOnMain{
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
            detectionImageView.image = image
            //Classify the image
            classifyImage(image: image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsDetected.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetectionCell")!
        let currentClassification = self.objectsDetected[(indexPath as NSIndexPath).row]
        // Set the label and confidence
        cell.textLabel?.text = currentClassification.classification
        cell.detailTextLabel?.text = currentClassification.confidence
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Maybe do something if a row is selected?
    }
}
