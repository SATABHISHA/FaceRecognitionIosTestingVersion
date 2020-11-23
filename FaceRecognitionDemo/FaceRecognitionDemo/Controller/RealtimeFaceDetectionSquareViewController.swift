//
//  RealtimeFaceDetectionSquareViewController.swift
//  FaceRecognitionDemo
//
//  Created by SATABHISHA ROY on 15/10/20.
//  Copyright © 2020 SATABHISHA ROY. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import VideoToolbox
import Alamofire
import SwiftyJSON

class RealtimeFaceDetectionSquareViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var viewCamera: UIView!
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var drawings: [CAShapeLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        self.addCameraInput()
        self.showCameraFeed()
        self.getCameraFrames()
        self.captureSession.startRunning()
        // Do any additional setup after loading the view.
        
        //-----code to show the Avrrunning session in a view, starts
        DispatchQueue.main.async {
            self.previewLayer.frame = self.viewCamera!.bounds
        }
        //-----code to show the Avrrunning session in a view, ends
    }
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {
        
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        self.detectFace(in: frame)
    }
    
    private func addCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                mediaType: .video,
                position: .front).devices.first else {
            fatalError("No back camera device found, please make sure to run SimpleLaneDetection in an iOS device and not a simulator")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
    }
    
    private func showCameraFeed() {
        /*  self.previewLayer.videoGravity = .resizeAspectFill
         self.view.layer.addSublayer(self.previewLayer)
         self.previewLayer.frame = self.view.frame */
        
        //----code to show realtime session in a view
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        self.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.viewCamera.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.viewCamera.frame
    }
    
    private func getCameraFrames() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    }
    
    private func detectFace(in image: CVPixelBuffer) {
        /*   let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
         DispatchQueue.main.async {
         if let results = request.results as? [VNFaceObservation] {
         self.handleFaceDetectionResults(results)
         } else {
         self.clearDrawings()
         }
         }
         })
         let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
         try? imageRequestHandler.perform([faceDetectionRequest])*/
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation], results.count > 0 {
                    self.handleFaceDetectionResults(results)
                    print("did detect \(results.count) face(s)")
                    self.captureSession.stopRunning()
                    self.loaderStart()
                    nestedif: if(results.count>1){
                        self.loaderEnd()
//                        self.captureSession.stopRunning()
                        self.openDetailsPopup(name: "Multiple faces detected. Please try again.")
                        break nestedif
                    }else {
                       // break nestedif
                        self.loaderEnd()
                        //----convert cvpixel to base64, code starts
                        let image = UIImage(ciImage: CIImage(cvPixelBuffer: image))
                        var imageData = image.jpegData(compressionQuality: 0.2)
                        let base64String = imageData?.base64EncodedString()
                        //                            print("base64convert-=>",base64String)
                        
                        //----convert cvpixel to base64, code ends
                        
                        //===============upload photo to the server code starts==========
                        
                        
                        //                   let api = "https://wrkplan-test.com/f/*ace-recognition/api/recognize"
                        let api = "https://wrkplan-test.com/face-recognition/api/collection/face/recognize"
                        
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
                                nestedif1: if(swiftyJsonVar["FaceMatches"][0]["Face"].exists()){
                                    let name = swiftyJsonVar["FaceMatches"][0]["Face"]["ExternalImageId"].stringValue
                                    print("name-=>",name)
                                    self.openDetailsPopup(name: "Hello \(name)")
                                    
                                    break nestedif1
                                }else {
                                    self.openDetailsPopup(name: "Sorry! Couldn't recognize")
                                    break nestedif1
                                }
                                break
                                
                            case .failure(let error):
                                self.loaderEnd()
                                print("Error: ", error)
                            }
                        }
                    }
                    //===============upload photo to the server code ends===========
                    
                } else {
                    self.clearDrawings()
                    print("did not detect any face")
                }
                
            }
        }
        )
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
        
        
    }
    
    private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation]) {
        
        self.clearDrawings()
        let facesBoundingBoxes: [CAShapeLayer] = observedFaces.flatMap({ (observedFace: VNFaceObservation) -> [CAShapeLayer] in
            let faceBoundingBoxOnScreen = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
            let faceBoundingBoxShape = CAShapeLayer()
            faceBoundingBoxShape.path = faceBoundingBoxPath
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
            var newDrawings = [CAShapeLayer]()
            newDrawings.append(faceBoundingBoxShape)
            if let landmarks = observedFace.landmarks {
                newDrawings = newDrawings + self.drawFaceFeatures(landmarks, screenBoundingBox: faceBoundingBoxOnScreen)
            }
            return newDrawings
        })
        facesBoundingBoxes.forEach({ faceBoundingBox in self.view.layer.addSublayer(faceBoundingBox) })
        self.drawings = facesBoundingBoxes
    }
    
    private func clearDrawings() {
        self.drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
    }
    
    private func drawFaceFeatures(_ landmarks: VNFaceLandmarks2D, screenBoundingBox: CGRect) -> [CAShapeLayer] {
        var faceFeaturesDrawings: [CAShapeLayer] = []
        if let leftEye = landmarks.leftEye {
            let eyeDrawing = self.drawEye(leftEye, screenBoundingBox: screenBoundingBox)
            faceFeaturesDrawings.append(eyeDrawing)
        }
        if let rightEye = landmarks.rightEye {
            let eyeDrawing = self.drawEye(rightEye, screenBoundingBox: screenBoundingBox)
            faceFeaturesDrawings.append(eyeDrawing)
        }
        // draw other face features here
        return faceFeaturesDrawings
    }
    private func drawEye(_ eye: VNFaceLandmarkRegion2D, screenBoundingBox: CGRect) -> CAShapeLayer {
        let eyePath = CGMutablePath()
        let eyePathPoints = eye.normalizedPoints
            .map({ eyePoint in
                CGPoint(
                    x: eyePoint.y * screenBoundingBox.height + screenBoundingBox.origin.x,
                    y: eyePoint.x * screenBoundingBox.width + screenBoundingBox.origin.y)
            })
        eyePath.addLines(between: eyePathPoints)
        eyePath.closeSubpath()
        let eyeDrawing = CAShapeLayer()
        eyeDrawing.path = eyePath
        eyeDrawing.fillColor = UIColor.clear.cgColor
        eyeDrawing.strokeColor = UIColor.green.cgColor
        
        return eyeDrawing
    }
    
    
    //-------to convert uiimage, code starts
    
    
    //===============FormDetails Popup code starts===================
    @IBAction func btnPopupOk(_ sender: Any) {
        closeDetailsPopup()
        self.performSegue(withIdentifier: "dashboard", sender: nil)
     /*   DispatchQueue.main.async {
            self.captureSession.startRunning()
        } */
    }
    
    @IBOutlet var viewDetails: UIView!
    @IBOutlet weak var name: UILabel!
    func openDetailsPopup(name:String?){
//        blurEffect()
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
//            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.viewDetails.removeFromSuperview();
//            self.canelBlurEffect()
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
    
}
