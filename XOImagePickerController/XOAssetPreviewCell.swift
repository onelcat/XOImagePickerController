//
//  XOAssetPreviewCell.swift
//  XOImagePickerController
//
//  Created by luo fengyuan on 2019/6/28.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import Foundation
import Photos


protocol XOAssetPreviewCell {
    var dataSource: PHAsset? { get set }
    func singleTap(_ tap: UITapGestureRecognizer?)
}

class XOPhotoPreviewCell: UICollectionViewCell, XOAssetPreviewCell {
    
    var singleTapHander:(()->Void)?
    
    private
    var _imageRequestID: PHImageRequestID = 0
    
    private
    var _targetSize: CGSize {
        var scale = UIScreen.main.scale
        if scale > 2.0 {
            scale = 2.0
        }
        return CGSize(width: self.bounds.width * scale, height: self.bounds.height * scale)
    }
    
    lazy private var _imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill;
        view.clipsToBounds = true;
        view.backgroundColor = UIColor.init(white: 1.0, alpha: 0.5)
        return view
    }()
    
    lazy private var _scrollView: UIScrollView = {
        let view = UIScrollView()
        view.bouncesZoom = true;
        view.maximumZoomScale = 2.5;
        view.minimumZoomScale = 1.0;
        view.isMultipleTouchEnabled = true;
        view.scrollsToTop = false;
        view.showsHorizontalScrollIndicator = true;
        view.showsVerticalScrollIndicator = false;
        view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        view.delaysContentTouches = false;
        view.canCancelContentTouches = true;
        view.alwaysBounceVertical = false;
        return view
    }()
    lazy private var _progressView: UIProgressView = {
        let view = UIProgressView()
        view.progress = 0
        return view
    }()
    
    var dataSource: PHAsset? {
        didSet {
            guard let asset = self.dataSource else {
                return
            }
            if self._imageRequestID != 0 {
                PHImageManager.default().cancelImageRequest(_imageRequestID)
            }
            __updateStaticImage(asset)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        _scrollView.delegate = self
        if #available(iOS 11.0, *) {
            _scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        };
        
        contentView.addSubview(_scrollView)
        _scrollView.addSubview(_imageView)
        _progressView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 1)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        self.contentView.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        tap2.numberOfTapsRequired = 2
        tap1.require(toFail: tap2)
        self.contentView.addGestureRecognizer(tap2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width: CGFloat
        let height: CGFloat = self.bounds.height
        if #available(iOS 11.0, *) {
            width = self.bounds.inset(by: self.safeAreaInsets).width
        } else {
            // Fallback on earlier versions
            width = self.bounds.width
        }
        _scrollView.frame = CGRect(x: 10, y: 0, width: width - 20, height: height)
        __recoverSubviews()
    }

    @objc
    func singleTap(_ tap: UITapGestureRecognizer?) {
        if let handler = singleTapHander {
            handler()
        }
    }
    
    @objc
    func doubleTap(_ tap: UITapGestureRecognizer?) {
        if (_scrollView.zoomScale > _scrollView.minimumZoomScale) {
            _scrollView.contentInset = UIEdgeInsets.zero
            _scrollView.setZoomScale(_scrollView.minimumZoomScale, animated: true)
        } else {
            guard let touchPoint = tap?.location(in: self._imageView) else {
                return
            }
            let newZoomScale = _scrollView.maximumZoomScale;
            let xsize = self.bounds.width / newZoomScale;
            let ysize = self.bounds.height / newZoomScale;
            _scrollView.zoom(to: CGRect(x: touchPoint.x - xsize/2, y: touchPoint.y - ysize/2, width: xsize, height: ysize), animated: true)
        }
    }
    
    private
    func __updateStaticImage(_ asset: PHAsset) {
        // Prepare the options to pass when fetching the (photo, or video preview) image.
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            // The handler may originate on a background queue, so
            // re-dispatch to the main queue for UI work.
            DispatchQueue.main.sync {
                debugPrint(progress)
                self._progressView.progress = Float(progress)
            }
        }
        // MARK: 防止内存💥
        var temp_image: UIImage?
        self._imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: _targetSize,contentMode: .aspectFit,options: options,resultHandler: { image, _ in
            // PhotoKit finished the request, so hide the progress view.
            self._progressView.isHidden = true
            // If the request succeeded, show the image view.
            guard let img = image else { return }
            temp_image = img
            self._imageView.isHidden = false
            self._imageView.image = temp_image
            self.__resizeSubviews()
            self._imageRequestID = 0
        })
        __configMaximumZoomScale()
    }
    
    private
    func __configMaximumZoomScale() {
        _scrollView.maximumZoomScale = 2.5
        if let asset = self.dataSource {
            let aspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
            // 优化超宽图片的显示
            if aspectRatio > 1.5 {
                _scrollView.maximumZoomScale *= aspectRatio / 1.5;
            }
        }
    }
    
    private
    func __recoverSubviews() {
        _scrollView.setZoomScale(_scrollView.minimumZoomScale, animated: false)
        __resizeSubviews()
    }
    
    func __resizeSubviews() {
        guard let image = _imageView.image else {
            return
        }
        let imgW = self._scrollView.bounds.width
        var imgH:CGFloat
        if (image.size.height / image.size.width > self.bounds.height / self._scrollView.bounds.height) {
            imgH = (image.size.height / (image.size.width / self._scrollView.bounds.width))
        } else {
            var height = image.size.height / image.size.width * self._scrollView.bounds.width;
            if height < 1 || height.isNaN { height = self.bounds.height }
            imgH = height
        }
        if imgH > self.bounds.height && imgH - self.bounds.height <= 1 {
            imgH = self.bounds.height
        }
        let contentSizeH = max(imgH, self.bounds.height)
        _scrollView.contentSize = CGSize(width: self._scrollView.bounds.width, height: contentSizeH)
        _scrollView.scrollRectToVisible(self.bounds, animated: false)
        _scrollView.alwaysBounceVertical = imgH <= self.bounds.height ? false : true
        
        let x = (_scrollView.bounds.width - imgW) / 2.0
        let y = (_scrollView.bounds.height - imgH) / 2.0

        _imageView.frame = CGRect(x: x, y: y, width: imgW, height: imgH)
        
    }
    
    private
    func __refreshImageContainerViewCenter() {
        let offsetX = (_scrollView.bounds.width > _scrollView.contentSize.width) ? ((_scrollView.bounds.width - _scrollView.contentSize.width) * 0.5) : 0.0;
        let offsetY = (_scrollView.bounds.height > _scrollView.contentSize.height) ? ((_scrollView.bounds.height - _scrollView.contentSize.height) * 0.5) : 0.0;
        self._imageView.center = CGPoint(x: _scrollView.contentSize.width * 0.5 + offsetX, y: _scrollView.contentSize.height * 0.5 + offsetY)
    }
    
}

extension XOPhotoPreviewCell:UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self._imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        __refreshImageContainerViewCenter()
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
}
//
//class XOVideoPreviewCell:UICollectionViewCell , XOAssetPreviewCell {
//
//
//    var dataSource: PHAsset? {
//        didSet {
//
//        }
//    }
//
//    func singleTap(_ tap: UITapGestureRecognizer?) {
//
//    }
//
//}
