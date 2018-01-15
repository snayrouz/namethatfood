//
//  ViewController.swift
//  wtfood
//
//  Created by Samuel Nayrouz on 12/27/17.
//  Copyright © 2017 Samuel Nayrouz. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage
import TwitterKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            guard let convertedCIImage = CIImage(image: userPickedImage) else {
                fatalError("cannot convert to CIImage")
            }
            detect(image: convertedCIImage)
        
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: food().model) else {
        
            fatalError("Cannot import model")
        }
       
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let result = request.results?.first as? VNClassificationObservation else {
                fatalError("Could not complete classfication")
            }
            
            self.navigationItem.title = result.identifier.capitalized
            
            self.requestInfo(imageName: result.identifier)
            
        }
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch{
            print(error)
        }
        
    }
    
    func requestInfo(imageName: String) {
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : imageName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500"
        ]
        
        Alamofire.request(wikipediaURL, method: .get, parameters: parameters).responseJSON
            { (response) in
                if response.result.isSuccess {
                    print("Retrieved wikipedia information")
                    print(response)
                    //JSON Response to retrieve Wikipedia Image
                    let imageJSON : JSON = JSON(response.result.value!)
                    //JSON Response to retrieve Wikipedia Page
                    let pageid = imageJSON["query"]["pageids"][0].stringValue
                    //JSON Response to retrieve Wikipedia description of image taken by user
                    let imageDescription = imageJSON["query"]["pages"][pageid]["extract"].stringValue
                    //JSON Response to retrieve Wikipedia Image URL
                    let wikiImageUrl = imageJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                    //Set the JSON Response image with Wikipedia URL
                    self.imageView.sd_setImage(with: URL(string: wikiImageUrl))
                    //Set the image description from Wikipedia
                    self.label.text = imageDescription
                }
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
 
    @IBAction func shareTapped(_ sender: UIBarButtonItem) {
        if (TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()) {
            // App must have at least one logged-in user to compose a Tweet
            let composer = TWTRComposerViewController.init(initialText: "I found out I'm eating a __ from the WTFood app!", image: nil, videoURL: nil)
            present(composer, animated: true, completion: nil)
        } else {
            // Log in, and then check again
            TWTRTwitter.sharedInstance().logIn { session, error in
                if session != nil { // Log in succeeded
                    let composer = TWTRComposerViewController.emptyComposer()
                    self.present(composer, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "No Twitter Accounts Available", message: "You must log in before presenting a composer.", preferredStyle: .alert)
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
    }
    
}

