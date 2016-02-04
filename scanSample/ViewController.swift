//
//  ViewController.swift
//  scanSample
//
//  Created by Alen Palamar on 04.02.16.
//  Copyright © 2016 itxpalamar.eu. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var highlightView : UIView = UIView()
    
 
    
    @IBOutlet var nbrPZNLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBarView: UIView = UIView(frame: CGRectMake(0, 0, 414, 25))
        statusBarView.backgroundColor = UIColor.whiteColor()
        self.view!.addSubview(statusBarView)
        self.highlightView.autoresizingMask = [.FlexibleTopMargin, .FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
        self.highlightView.layer.borderColor = UIColor.greenColor().CGColor
        self.highlightView.layer.borderWidth = 3
        self.view.addSubview(self.highlightView)
        captureSession = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            failed()
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return;
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        previewLayer.frame = view.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(previewLayer);
        captureSession.startRunning();
        self.view.bringSubviewToFront(self.highlightView)
    }
    

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        var highlightViewRect = CGRectZero
        var barCodeObject : AVMetadataObject!
        var detectionString : String!
        
        let barCodeTypes = [AVMetadataObjectTypeUPCECode,
            AVMetadataObjectTypeCode39Code,
            AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code,
            AVMetadataObjectTypeEAN8Code,
            AVMetadataObjectTypeCode93Code,
            AVMetadataObjectTypeCode128Code,
            AVMetadataObjectTypePDF417Code,
            AVMetadataObjectTypeQRCode,
            AVMetadataObjectTypeAztecCode
        ]
        
        for metadata in metadataObjects {
            for barcodeType in barCodeTypes {
                if metadata.type == barcodeType {
                    barCodeObject = self.previewLayer.transformedMetadataObjectForMetadataObject(metadata as! AVMetadataMachineReadableCodeObject)
                    highlightViewRect = barCodeObject.bounds
                    detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    self.captureSession.stopRunning()
                    break
                }
            }
        }
        self.highlightView.frame = highlightViewRect
    }
    
    
    func failed() {
        let ac = UIAlertController(title: "Hinweis", message: "Das Scannen wir nicht von Ihrem Gerät unterstützt", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
        captureSession = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.running == false) {
            captureSession.startRunning();
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.running == true) {
            captureSession.stopRunning();
        }
    }
}

