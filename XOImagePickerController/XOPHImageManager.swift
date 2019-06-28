//
//  XOPHImageManager.swift
//  XOImagePickerController
//
//  Created by luo fengyuan on 2019/6/28.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import Foundation
import Photos

//class XOPHImageManager {
//
//    private let _photoPreviewMaxWidth: CGFloat = 600
//    private let _photoWidth: CGFloat = 828.0
//    private let _ScreenWidth: CGFloat = UIScreen.main.bounds.width
//
//    // 测试发现，如果scale在plus真机上取到3.0，内存会增大特别多。故这里写死成2.0
//    private var _screenScale: CGFloat = 2.0
//
//    init() {
//        _screenScale = 2.0;
//        if (_screenScale > 700) {
//            _screenScale = 1.5;
//        }
//
//    }
//
//    func getPhotoWithAsset(_ asset: PHAsset, photoWidth: CGFloat,
//                                  networkAccessAllowed: Bool,
//                                  progressHandler: ((_ progress: Double,_ error: Error, _ stop: Bool)->Void)?,
//                                  completionHandler: ()->Void) -> PHImageRequestID {
//        var imageSize = CGSize.zero
//        if photoWidth < UIScreen.main.bounds.width && photoWidth < _photoPreviewMaxWidth {
//            imageSize = UIScreen.main.bounds.size
//        } else {
//            let aspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
//            var pixelWidth = photoWidth * self._screenScale;
//            // 超宽图片
//            if aspectRatio > 1.8 {
//                pixelWidth = pixelWidth * aspectRatio;
//            }
//            // 超高图片
//            if aspectRatio < 0.2 {
//                pixelWidth = pixelWidth * 0.5;
//            }
//            let pixelHeight = pixelWidth / aspectRatio;
//            imageSize = CGSize(width: pixelWidth, height: pixelHeight)
//        }
//        var image: UIImage?
//        let option = PHImageRequestOptions()
//        option.resizeMode = .fast
//        return PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: PHImageContentMode.aspectFill, options: option, resultHandler: { (result, info) in
//            if let img = result {
//                image = img
//            }
//            let downloadFinined: Bool
//            if let isCancel = info?[PHImageCancelledKey] as? Bool,  isCancel == false,info?[PHImageErrorKey] == nil {
//                downloadFinined = true
//            } else {
//                downloadFinined = false
//            }
//            if downloadFinined == true, let rs = result {
//
//            }
//        })
//
//    }
//
//
//
//
//}
