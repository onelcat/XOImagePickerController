//
//  XOImagePickerController.swift
//  XOImagePickerController
//
//  Created by hao shuai on 2019/6/25.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import Foundation
import PhotosUI
import MobileCoreServices

enum MediaType {
    case image
    case photoLive
    case gif
    case video(_ duration: Double)
    case audio(_ duration: Double)
}

open class XOImagePickerController: UINavigationController {
    
    /// default value is UIImagePickerControllerSourceTypeCamera.
    open var sourceType: UIImagePickerController.SourceType = .camera
    
    /// default value is an array containing kUTTypeImage.
    open var mediaTypes: [String] = [kUTTypeImage as String,kUTTypeMovie as String]
    
    /// replacement for -allowsImageEditing; default value is NO.
    open var allowsEditing: Bool = false
    
    /// default value is UIImagePickerControllerImageExportPresetCompatible.
    open var imageExportPreset: UIImagePickerController.ImageURLExportPreset = .compatible
    
    /// video properties apply only if mediaTypes includes kUTTypeMovie
    /// default value is 10 minutes.
    open var videoMaximumDuration: TimeInterval = 15
    
    /// default value is UIImagePickerControllerQualityTypeMedium. If the cameraDevice does not support the videoQuality, it will use the default value.
    open var videoQuality: UIImagePickerController.QualityType = .typeMedium
    
    /// videoExportPreset can be used to specify the transcoding quality for videos (via a AVAssetExportPreset* string). If the value is nil (the default) then the transcodeQuality is determined by videoQuality instead. Not valid if the source type is UIImagePickerControllerSourceTypeCamera
    open var videoExportPreset: AVCaptureSession.Preset = .hd1280x720
    
    /// camera additions available only if sourceType is UIImagePickerControllerSourceTypeCamera.
    /// set to NO to hide all standard camera UI. default is YES
    open var showsCameraControls: Bool = false
    
    /// set a view to overlay the preview view.
    open var cameraOverlayView: UIView?
    
    /// set the transform of the preview view.
    open var cameraViewTransform: CGAffineTransform = CGAffineTransform.identity
    
    /// default is UIImagePickerControllerCameraCaptureModePhoto
    open var cameraCaptureMode: UIImagePickerController.CameraCaptureMode = .photo
    
    /// default is UIImagePickerControllerCameraDeviceRear
    open var cameraDevice: UIImagePickerController.CameraDevice = .rear
    
    /// default is UIImagePickerControllerCameraFlashModeAuto.
    open var cameraFlashMode: UIImagePickerController.CameraFlashMode = .auto
    
    open var selectAsset: [PHAsset] = []
    
    open var selectCoverImage: [UIImage] = []
    
    open var showTakePhotoButton = true
    
    open var allowPickingVideo = true
    
    open var allowPickingImage = true
    
    open var allowTakePicture = true
    
    open var allowCameraLocation = true
    
    open var allowTakeVideo = true
    
    open var allowPickingOriginalPhoto = true
    
    open var sortAscendingByModificationDate = true
    
    open var maxImagesCount: Int = 9
    
    public init() {
        let vc = XOAssetGridViewController()
        super.init(rootViewController: vc)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
}

