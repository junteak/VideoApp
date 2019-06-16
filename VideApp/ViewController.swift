//
//  ViewController.swift
//  VideApp
//
//  Created by 潤田中 on 2019/06/16.
//  Copyright © 2019 BCC. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

//AVCaptureFileOutputRecordingDelegateは保存するのに絶対必要
class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { (completed, error) in
            if completed{
                print("保存完了！")
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        
        
    }
    
    // 設定に必要なもの
    
    var captureSession = AVCaptureSession()
    
    // カメラ設定に使うもの
    
    var backCamera : AVCaptureDevice?
    var frontCamera : AVCaptureDevice?
    var currentCamera : AVCaptureDevice?
    
    // オーディオ設定
    var audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    
    var videoFileOutput: AVCaptureMovieFileOutput?
    
    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?
    
    //ボタンを押した時使用
    var isRecording = false
    
    
    
    
    func setupDevice(){
        //        ワイドアングルカメラ使用・ビデオタイプはビデオ・・ポジション指定なし
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back{
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device
            }
        }
        
        currentCamera = backCamera
    }
    
    
    func setupCaptureSession(){
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
    }
    
    
    
    
    func setupInputOutput(){
        
        do{
            
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            videoFileOutput = AVCaptureMovieFileOutput()
            captureSession.addOutput(videoFileOutput!)
            
        } catch {
            
            print(error)
            
        }
        
        
    }
    
    func setupPreviewLayer(){
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        
        // self.view 元からあるViewを設定している.
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
    }
    
    func startRunningCaptureSession(){
        
        captureSession.startRunning()
        
        
    }
    
    //アニメーション作るので宣言
    @IBOutlet weak var recordButton: UIButton!
    @IBAction func captureButton(_ sender: UIButton) {
        
        if !isRecording{
            isRecording = true
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat,.autoreverse, .allowUserInteraction], animations: { () -> Void in
                self.recordButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }, completion: nil)
            
            let outputPath = NSTemporaryDirectory() + "output.mp4"
            let outputFileURL = URL(fileURLWithPath: outputPath)
            videoFileOutput?.startRecording(to: outputFileURL, recordingDelegate: self)
            
        } else {
            isRecording = false
            UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: { () -> Void in
                self.recordButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) // ボタンのホワンホワン
            }, completion: nil)
            
            
            recordButton.layer.removeAllAnimations()
            videoFileOutput?.stopRecording()
            
            
            let title = "The movie was saved"
            let message = "Yeah!"
            let okText = "OK"
            
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let okayButton = UIAlertAction(title: okText, style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(okayButton)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
}

