//
//  ViewController.swift
//  FaceRecognitionDemo
//
//  Created by SATABHISHA ROY on 03/09/20.
//  Copyright © 2020 SATABHISHA ROY. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var view_camera: UIView!
    @IBOutlet weak var imgview_camera: UIImageView!
    @IBOutlet weak var label_camera: UILabel!
//    var model: FaceRecognitionMLModel!
    
    
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Face Recognition Demo"
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .front
        imagePicker.allowsEditing = false
        // Do any additional setup after loading the view.
        
        //----------imageview Leave Balance tap gesture code starts------
        let tapGestureRecognizer_view_camera = UITapGestureRecognizer(target: self, action: #selector(viewcameraTapped(tapGestureRecognizer:)))
        view_camera.isUserInteractionEnabled = true
        view_camera.addGestureRecognizer(tapGestureRecognizer_view_camera)
        //---------mageview Leave Balance tap gesture code ends------
        
        
    }
    
    @IBAction func btn_get_realtime_face_detection(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "realtimedetector", sender: nil)
    }
    //------------camera gesture recogniser onClick code starts------
    @objc func viewcameraTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        present(imagePicker, animated: true, completion: nil)
    }
    //------------camera gesture recogniser onClick code ends------
    
    override func viewWillAppear(_ animated: Bool) {
//        model = FaceRecognitionMLModel()
    }
    
    /* override func viewDidLayoutSubviews() {
     super.viewDidLayoutSubviews()
     view_camera.roundCorners([.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 15)
     imageView.roundCorners([.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 15)
     }*/
    public static var image_to_base64:String?
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
     /*   if let userPickedimage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = userPickedimage
            
            guard let ciImage = CIImage(image: userPickedimage) else{
                fatalError("Couldn't convert UiImage")
            }
            
            let imageData:NSData = userPickedimage.pngData()! as NSData
            let dataImage = imageData.base64EncodedString(options: .lineLength64Characters)
            ViewController.image_to_base64 = dataImage
//            print(dataImage)
           let image_data_to_base64 = convertImageToBase64(userPickedimage)
            self.detect_image_api(image: dataImage)
            //            detect(image: ciImage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil) */
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.contentMode = .scaleToFill
            imageView.image = pickedImage
            imagePicker.dismiss(animated: true, completion: nil)
                   loaderStart()
                   
       //            var imageData = UIImagePNGRepresentation(pickedImage)
            var imageData = pickedImage.jpegData(compressionQuality: 0.2)
                   let base64String = imageData?.base64EncodedString()
                   
                   //===============upload photo to the server code starts==========
                  
                   
//                   let api = "https://wrkplan-test.com/f/*ace-recognition/api/recognize"
            let api = "https://wrkplan-test.com/face-recognition/api/collection/face/recognize"
            
//            let api = "https://wrkplan-test.com/face-recognition/api/collection/face/list"
                   
                   /*let sentData: [String:Any] = [
                    "image":base64String,
                    "gallery_name":"arb-india"
                   ]*/
            let sentData: [String:Any] = [
                "CollectionId":"arb-usa",
                "ImageBase64":base64String,
            ]
                   AF.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
                       response in
                       switch response.result{
                       case .success:
                           self.loaderEnd()
                           
                        let swiftyJsonVar=JSON(response.value ?? "")
                        print("responseData-=>",swiftyJsonVar)
                       /* if(swiftyJsonVar["images"].exists()){
                            let name = swiftyJsonVar["images"][0]["candidates"][0]["subject_id"].stringValue
                            print("name-=>",name)
                            self.openDetailsPopup(name: "Hello \(name)", confidence: name)
                        }else{
//                            print("Couldn't recognize")
                            self.openDetailsPopup(name: "Sorry! Couldn't recognize", confidence: "Sorry! Couldn't recognize")
                        } */
                         
                           
//                           self.profileImageView.image = pickedImage
//                           let message = "Added successfully!!";
//                           Toast(text: message, duration: Delay.short).show()
                           break

                       case .failure(let error):
                           self.loaderEnd()
                           print("Error: ", error)
                       }
                   }
                   //===============upload photo to the server code ends===========
               }
        
    }
    
    func convertImageToBase64(_ image: UIImage) -> String {
        let imageData:NSData = image.jpegData(compressionQuality: 0.4)! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            return strBase64
     }
//    public static func  convertImageToBase64String(image : UIImage ) -> String
//    {
//        let strBase64 =  image.pngData()?.base64EncodedString()
//        return strBase64!
//    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    /*func detect(image: CIImage){
        
        
        guard let model = try? VNCoreMLModel(for: FaceRecognitionMLModel().model) else{
            fatalError("Loading CoreMl Model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("Model failed to process image")
            }
            //            print(results)
            //            self.navigationItem.title = results.description
            if let firstResult = results.first{
                print("confidence-=>",firstResult.confidence)
                if(firstResult.confidence >= 0.9){
                    self.openDetailsPopup(name: "It's \(firstResult.identifier)", confidence: "Confidence: \(firstResult.confidence)")
                }
                
                /*  if firstResult.identifier.contains("Manika Roy"){
                 self.titleName.text = "It's Manika"
                 self.navigationItem.title = "Manika Roy"
                 print("1")
                 }
                 if firstResult.identifier.contains("Satabhisha Roy"){
                 self.titleName.text = "It's Satabhisha...Hey! Welcome"
                 self.navigationItem.title = "Satabhisha Roy"
                 print("2")
                 }
                 else if firstResult.identifier.contains("Swapan Kr Roy"){
                 self.titleName.text = "It's Swapan..."
                 self.navigationItem.title = "Swapan Roy"
                 print("3")
                 }
                 //                    else if firstResult.identifier.contains("Arup Dutta"){
                 //                    self.titleName.text = "It's Arup..."
                 //                    self.navigationItem.title = "Arup Dutta"
                 //                    print("5")
                 //                }
                 else if firstResult.identifier.contains("Vivan"){
                 self.titleName.text = "It's Vivan..."
                 self.navigationItem.title = "Vivan"
                 print("5")
                 }*/
                else{
                    print("4")
                    print("result-=>, Couldn't recognize")
                    self.openDetailsPopup(name: "Sorry! couldn't recognize you", confidence: "Confidence: \(firstResult.confidence)")
                    
                }
            }else{
                //                self.titleName.text = "Sorry couldn't recognize sorry!"
                //                self.navigationItem.title = "Sorry couldn't recognize sorry!"
                //                self.titleName.text = "Sorry couldn't recognize sorry!"
                print("6")
                print("result-=>, Couldn't recognize")
                self.openDetailsPopup(name: "Sorry! couldn't recognize you", confidence: "Confidence: 0.0")
            }
            
        }
        
        
        
        
        let handler = VNImageRequestHandler(ciImage: image)
        do{
            try handler.perform([request])
        }catch{
            print("Error")
        }
    } */
    
    func detect1(image: CIImage){
        
        let url = self.getDocumentsDirectory().appendingPathComponent("FaceRecognitionMLModel.mlmodel")
        //        let url = self.getDocumentsDirectory()
        print("url-=>",url)
        
        //            guard let model = try? VNCoreMLModel(for: FaceRecognitionMLModel().model) else{
        //                fatalError("Loading CoreMl Model failed")
        //            }
        //
        guard let compiledModelURL = try? MLModel.compileModel(at: url)else {
            fatalError("Model failed to load url")
        }
        guard let model_dynamic = try? MLModel(contentsOf: compiledModelURL) else{
            fatalError("Model failed to load")
        }
        guard let model = try? VNCoreMLModel(for: model_dynamic) else{
            fatalError("Loading CoreMl Model failed")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("Model failed to process image")
            }
            //            print(results)
            //            self.navigationItem.title = results.description
            if let firstResult = results.first{
                print("confidence-=>",firstResult.confidence)
                if(firstResult.confidence >= 0.6){
                    self.openDetailsPopup(name: "It's \(firstResult.identifier)", confidence: "Confidence: \(firstResult.confidence)")
                }
                /*  if firstResult.identifier.contains("Manika Roy"){
                 self.titleName.text = "It's Manika"
                 self.navigationItem.title = "Manika Roy"
                 print("1")
                 }
                 if firstResult.identifier.contains("Satabhisha Roy"){
                 self.titleName.text = "It's Satabhisha...Hey! Welcome"
                 self.navigationItem.title = "Satabhisha Roy"
                 print("2")
                 }
                 else if firstResult.identifier.contains("Swapan Kr Roy"){
                 self.titleName.text = "It's Swapan..."
                 self.navigationItem.title = "Swapan Roy"
                 print("3")
                 }
                 //                    else if firstResult.identifier.contains("Arup Dutta"){
                 //                    self.titleName.text = "It's Arup..."
                 //                    self.navigationItem.title = "Arup Dutta"
                 //                    print("5")
                 //                }
                 else if firstResult.identifier.contains("Vivan"){
                 self.titleName.text = "It's Vivan..."
                 self.navigationItem.title = "Vivan"
                 print("5")
                 }*/
                else{
                    print("4")
                    print("result-=>, Couldn't recognize")
                    self.openDetailsPopup(name: "Sorry! couldn't recognize you", confidence: "Confidence: \(firstResult.confidence)")
                    
                }
            }else{
                //                self.titleName.text = "Sorry couldn't recognize sorry!"
                //                self.navigationItem.title = "Sorry couldn't recognize sorry!"
                //                self.titleName.text = "Sorry couldn't recognize sorry!"
                print("6")
                print("result-=>, Couldn't recognize")
                self.openDetailsPopup(name: "Sorry! couldn't recognize you", confidence: "Confidence: 0.0")
            }
            
        }
        
        
        
        
        let handler = VNImageRequestHandler(ciImage: image)
        do{
            try handler.perform([request])
        }catch{
            print("Error")
        }
    }
    
    
    
    //===============FormDetails Popup code starts===================
    @IBAction func btnPopupOk(_ sender: Any) {
        closeDetailsPopup()
    }
    
    @IBOutlet var viewDetails: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var confidencelabel: UILabel!
    func openDetailsPopup(name:String?, confidence:String?){
        blurEffect()
        self.view.addSubview(viewDetails)
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.height
        viewDetails.transform = CGAffineTransform.init(scaleX: 1.3,y :1.3)
        viewDetails.center = self.view.center
        viewDetails.layer.cornerRadius = 10.0
        //        addGoalChildFormView.layer.cornerRadius = 10.0
        viewDetails.alpha = 0
        viewDetails.sizeToFit()
        
        UIView.animate(withDuration: 0.3){
            self.viewDetails.alpha = 1
            self.viewDetails.transform = CGAffineTransform.identity
        }
        
        self.name.text = name!
        //        self.confidencelabel.text = confidence!
        
        
    }
    func closeDetailsPopup(){
        UIView.animate(withDuration: 0.3, animations: {
            self.viewDetails.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.viewDetails.alpha = 0
            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.viewDetails.removeFromSuperview();
            self.canelBlurEffect()
        }
    }
    //===============FormDetails Popup code ends===================
    
    // ====================== Blur Effect Defiend START ================= \\
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var blurEffectView: UIVisualEffectView!
    var loader: UIVisualEffectView!
    func loaderStart() {
        // ====================== Blur Effect START ================= \\
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        loader = UIVisualEffectView(effect: blurEffect)
        loader.frame = view.bounds
        loader.alpha = 1
        view.addSubview(loader)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 2, y: 2)
        activityIndicator.transform = transform
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.white
        loadingIndicator.startAnimating();
        loader.contentView.addSubview(loadingIndicator)
        
        // screen roted and size resize automatic
        loader.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth];
        
        // ====================== Blur Effect END ================= \\
    }
    
    func loaderEnd() {
        self.loader.removeFromSuperview();
    }
    // ====================== Blur Effect Defiend END ================= \\
    // ====================== Blur Effect function calling code starts ================= \\
    func blurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = 0.7
        view.addSubview(blurEffectView)
        // screen roted and size resize automatic
        blurEffectView.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth];
        
    }
    func canelBlurEffect() {
        self.blurEffectView.removeFromSuperview();
    }
    
    // ====================== Blur Effect function calling code ends ================= \\
    
};
extension UIView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}


