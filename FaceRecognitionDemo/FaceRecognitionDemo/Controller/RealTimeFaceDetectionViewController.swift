//
//  RealTimeFaceDetectionViewController.swift
//  FaceRecognitionDemo
//
//  Created by SATABHISHA ROY on 17/09/20.
//  Copyright © 2020 SATABHISHA ROY. All rights reserved.
//

import UIKit
import AVKit
import Vision

class RealTimeFaceDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var viewCamera: UIView!
    var previewLayer: AVCaptureVideoPreviewLayer?
    let captureSession = AVCaptureSession()
//    var sequenceHandler = VNSequenceRequestHandler()
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.openDetailsPopup(name: "test", confidence: "test")

        // Do any additional setup after loading the view.
//        let captureSession = AVCaptureSession()
        
//        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
//            return
//        }
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        else { fatalError("no front camera. but don't all iOS 10 devices have them?")}
            
            
        guard  let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }

        
        captureSession.addInput(input)
        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspect
//        previewLayer!.frame = viewCamera.bounds
        previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        viewCamera.layer.addSublayer(previewLayer!)
        previewLayer!.frame = viewCamera.frame
        
        captureSession.startRunning()
//        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
//            self.captureSession.startRunning()
//            //Step 13
//        }
        
        DispatchQueue.main.async {
            self.previewLayer!.frame = self.viewCamera!.bounds
        }
  
//        VNImageRequestHandler(cgImage: CGImage, options: [:]).perform(requests: [VNRequest])
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        previewLayer!.frame = viewCamera.bounds
    }
    
    

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
                print("Camera is able to capture the frame", Date())
        
     
                
//                guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else{
//                    return
//                }
//
//                guard let model = try? VNCoreMLModel(for: FaceRecognitionMLModel().model) else{
//                    print("failed to load model")
//                    return
//                }
//                let request = VNCoreMLRequest(model:model) {
//                    (finishedReq, err) in
//
//                    if let results = finishedReq.results {
//                        for observation in results where observation is VNRecognizedObjectObservation {
//                            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
//                                continue
//                            }
//                            // Select only the label with the highest confidence.
//                            let topLabelObservation = objectObservation.labels[0]
//                            print(topLabelObservation.identifier,topLabelObservation.confidence)
//                            if(topLabelObservation.confidence >= 0.9){
//                                self.captureSession.stopRunning()
//
//                                    DispatchQueue.main.async {
//                                        self.openDetailsPopup(name: "It's \(topLabelObservation.identifier)", confidence: "Confidence: \(topLabelObservation.confidence)")
//                                    }
//                            }
//                        }
//                    }
//                }
//
//
//                try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
   
    
    //===============FormDetails Popup code starts===================
    @IBAction func btnPopupOk(_ sender: Any) {
        closeDetailsPopup()
        DispatchQueue.main.async {
            self.captureSession.startRunning()
        }
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
           loader.alpha = 2
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

}
