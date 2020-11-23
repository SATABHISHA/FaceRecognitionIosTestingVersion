//
//  EnrollNameViewController.swift
//  FaceRecognitionDemo
//
//  Created by SATABHISHA ROY on 12/10/20.
//  Copyright © 2020 SATABHISHA ROY. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class EnrollNameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var view_camera: UIView!
    @IBOutlet weak var imgview_camera: UIImageView!
    @IBOutlet weak var label_camera: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    var base64String:String!
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    //------------camera gesture recogniser onClick code starts------
    @objc func viewcameraTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        present(imagePicker, animated: true, completion: nil)
    }
    //------------camera gesture recogniser onClick code ends------
    
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
//                   loaderStart()
                   
       //            var imageData = UIImagePNGRepresentation(pickedImage)
            var imageData = pickedImage.jpegData(compressionQuality: 0.2)
                base64String = imageData?.base64EncodedString()
                openDetailsPopup()
               }
        
    }
    

    //===============FormDetails/Message Popup code starts===================
    
    //-----message open/close popup starts-----
    @IBOutlet var viewMessage: UIView!
    @IBOutlet weak var label_message: UILabel!
    @IBAction func btn_close_message_popup(_ sender: Any) {
        closeMessagePopup()
    }
    
    func openMessagePopup(message:String){
        blurEffect()
        self.view.addSubview(viewMessage)
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.height
        viewMessage.transform = CGAffineTransform.init(scaleX: 1.3,y :1.3)
        viewMessage.center = self.view.center
        viewMessage.layer.cornerRadius = 10.0
        //        addGoalChildFormView.layer.cornerRadius = 10.0
        label_message.text = message
        viewMessage.alpha = 0
        viewMessage.sizeToFit()
        
        UIView.animate(withDuration: 0.3){
            self.viewMessage.alpha = 1
            self.viewMessage.transform = CGAffineTransform.identity
        }
        
        //        self.confidencelabel.text = confidence!
        
        
    }
    
    func closeMessagePopup(){
        UIView.animate(withDuration: 0.3, animations: {
            self.viewMessage.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.viewMessage.alpha = 0
            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.viewMessage.removeFromSuperview();
            self.canelBlurEffect()
        }
    }
    //-----message open/close popup ends-----
    
    
    
    //--------employee name enrollment popup code starts---
    @IBAction func btnPopupClose(_ sender: Any) {
        closeDetailsPopup()
    }
    @IBAction func btnPopupEnroll(_ sender: Any) {
        
        closeDetailsPopup()
       
        if let text = txt_emp_name.text, text.isEmpty {
            self.showToast(message: "Field cannot be left blank", font: .systemFont(ofSize: 12.0))
          } else {
            
        
        //===============upload photo to the server code starts==========
       
        
//        let api = "https://wrkplan-test.com/face-recognition/api/enroll"
        let api = "https://wrkplan-test.com/face-recognition/api/collection/face/add"
        
        loaderStart()
      /*  let sentData: [String:Any] = [
            "image":base64String!,
            "subject_id": self.txt_emp_name.text!,
            "gallery_name":"arb-india"
        ] */
            let sentData: [String:Any] = [
                "CollectionId" : "arb-usa",
                "ExternalImageId": self.txt_emp_name.text!,
                "ImageBase64":base64String!
            ]
        AF.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in
            switch response.result{
            case .success:
                self.loaderEnd()
                
             let swiftyJsonVar=JSON(response.value ?? "")
             print("responseData-=>",swiftyJsonVar)
                
          /*   if(swiftyJsonVar["images"].exists()){
                self.openMessagePopup(message: "Employee's image enrolled successfully")
//                self.showToast(message: "Employee's image enrolled successfully", font: .systemFont(ofSize: 12.0))
             }else{
                self.openMessagePopup(message: "Sorry! Something went wrong. Image enrollment unsuccessful")
//                self.showToast(message: "Sorry! Something went wrong. Image enrollment unsuccessful", font: .systemFont(ofSize: 12.0))
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
    
    @IBOutlet var viewDetails: UIView!
    
    @IBOutlet weak var txt_emp_name: UITextField!
    func openDetailsPopup(){
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
    //--------employee name enrollment popup code starts---
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
};extension UIViewController {
    
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }
