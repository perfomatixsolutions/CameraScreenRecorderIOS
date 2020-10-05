//
//  ViewController.swift
//  RecordVideo
//
//  Created by Manu on 07/09/20.
//  Copyright © 2020 perfomatix. All rights reserved.
//

import UIKit
import ReplayKit
import Photos
import AVKit
class ViewController: UIViewController, RPPreviewViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let recorder = RPScreenRecorder.shared()
    var assetWriter: AVAssetWriter!
    var videoURL: URL!
    var videoInput: AVAssetWriterInput!
    var audioMicInput: AVAssetWriterInput!
    
    @IBOutlet weak var annotationView: JVDrawingView!
    
    @IBOutlet weak var drawing: JVDrawingView!
    
    
    var session: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.annotationView.type = .graffiti
 
        let imgPicker = UIImagePickerController()
        if UIImagePickerController.isCameraDeviceAvailable( UIImagePickerController.CameraDevice.front) {
           imgPicker.delegate = self
           imgPicker.sourceType = .camera
           addChild(imgPicker)
           self.drawing.addSubview(imgPicker.view)
            imgPicker.view.frame = CGRect(origin: .zero, size: CGSize(width: drawing.bounds.width, height: drawing.bounds.height))
           imgPicker.allowsEditing = false
           imgPicker.showsCameraControls = false
           imgPicker.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }

    
    @IBAction func stoprecord(_ sender: Any) {
    recorder.stopCapture { (error) in

        if let error = error { return }

        guard let videoInput = self.videoInput else { return }
        guard let audioMicInput = self.audioMicInput else { return }
        guard let assetWriter = self.assetWriter else { return }
        guard let videoURL = self.videoURL else { return }

        videoInput.markAsFinished()
        audioMicInput.markAsFinished()
        assetWriter.finishWriting(completionHandler: {

            PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                }) { (saved, error) in

                    if let error = error {
                        print("PHAssetChangeRequest Video Error: \(error.localizedDescription)")
                        return
                    }

                    if saved {
                        print("videoSaved")
                    }
                }
        })
    }
    }
    
    @IBAction func recordButton(_ sender: Any) {
        recorder.isMicrophoneEnabled = true
       guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }

        let dirPath = "\(documentsPath)/Videos_\(UUID().uuidString).mp4"
        
       videoURL = URL(fileURLWithPath: dirPath)

       guard let videoURL = videoURL else { return }

       do {
           try FileManager.default.removeItem(at: videoURL)
       } catch {}

       do {
           try assetWriter = AVAssetWriter(outputURL: videoURL, fileType: .mp4) // AVAssetWriter(url: videoURL, fileType: .mp4) didn't make a difference
       } catch {}

       let videoSettings: [String : Any] = [
           AVVideoCodecKey: AVVideoCodecType.h264,
           AVVideoWidthKey: view.bounds.width,
           AVVideoHeightKey: view.bounds.height
       ]

       videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
       videoInput.expectsMediaDataInRealTime = true
       if assetWriter.canAdd(videoInput) {
           assetWriter.add(videoInput)
       }

       let audioSettings: [String:Any] = [AVFormatIDKey : kAudioFormatMPEG4AAC,
           AVNumberOfChannelsKey : 2,
           AVSampleRateKey : 44100.0,
           AVEncoderBitRateKey: 192000
       ]

       audioMicInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
       audioMicInput.expectsMediaDataInRealTime = true
       if assetWriter.canAdd(audioMicInput) {
           assetWriter.add(audioMicInput)
       }

       guard recorder.isAvailable else { return }
        recorder.startCapture(handler: { (cmSampleBuffer, rpSampleBufferType, err) in
           if let err = err { return }
            
            if CMSampleBufferDataIsReady(cmSampleBuffer) {

                   DispatchQueue.main.async {

                       switch rpSampleBufferType {
                       case .video:

                           print("writing sample....")

                           if self.assetWriter?.status == AVAssetWriter.Status.unknown {

                               print("Started writing")
                               self.assetWriter?.startWriting()
                               self.assetWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(cmSampleBuffer))
                           }

                           if self.assetWriter.status == AVAssetWriter.Status.failed {
                               print("StartCapture Error Occurred, Status = \(self.assetWriter.status.rawValue), \(self.assetWriter.error!.localizedDescription) \(self.assetWriter.error.debugDescription)")
                                return
                           }

                           if self.assetWriter.status == AVAssetWriter.Status.writing {
                               if self.videoInput.isReadyForMoreMediaData {
                                   print("Writing a sample")
                                   if self.videoInput.append(cmSampleBuffer) == false {
                                        print("problem writing video")
                                   }
                                }
                            }

                       case .audioMic:
                           if self.audioMicInput.isReadyForMoreMediaData {
                               print("audioMic data added")
                               self.audioMicInput.append(cmSampleBuffer)
                           }

                       default:
                           print("not a video sample")
                       }
                   }
            }
            
        })

}

}
