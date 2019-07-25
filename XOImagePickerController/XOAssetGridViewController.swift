/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implements the view controller for browsing photos in a grid layout.
*/

import UIKit
import Photos
import PhotosUI
import CoreLocation

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

class XOAssetGridViewController: UICollectionViewController {
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    private var _availableWidth: CGFloat = 0
    private var _safeAreaBottom: CGFloat = 0
    lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        return layout
    }()
    
    // CachingImage
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    
    
    fileprivate
    lazy var _toolView: XOToolView = {
        let view = XOToolView()
        return view
    }()
    
    fileprivate var _videoPhotoBadgeImage: UIImage?
    
    fileprivate var _photoDefImage: UIImage?
    
    fileprivate var _photoSelImage: UIImage?
    
//    fileprivate var _photoSelectButtonImage: (UIImage?,UIImage?)!
    
    fileprivate
    lazy var __configInfo: XOImagePickerController = {
        return self.navigationController as! XOImagePickerController
    }()
    
    init() {
        let itemSize: CGSize = CGSize(width: 80, height: 80)
        let itemSpacing:CGFloat = 2.0
        
        _videoPhotoBadgeImage = UIImage(XOKit: "VideoSendIcon")
        _photoDefImage = UIImage(XOKit: "photo_original_def")
        _photoSelImage = UIImage(XOKit: "photo_original_sel")
        
        let width = UIScreen.main.bounds.width
        let columnCount = (width / itemSize.width).rounded(.towardZero)
        let itemLength = (width - ((columnCount - 1) * itemSpacing)) / columnCount
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemLength, height: itemLength)
        layout.minimumInteritemSpacing = itemSpacing
        layout.minimumLineSpacing = itemSpacing
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController / Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.collectionView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .always
        } else {
            // Fallback on earlier versions
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.collectionView.alwaysBounceHorizontal = false
        
        self.view.addSubview(self._toolView)
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        collectionView.register(XOGridViewCell.self, forCellWithReuseIdentifier: "XOGridViewCell")
//        collectionView.register(XOCameraCell.self, forCellWithReuseIdentifier: "XOCameraCell")

        // Reaching this point without a segue means that this AssetGridViewController
        // became visible at app launch. As such, match the behavior of the segue from
        // the default "All Photos" view.
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        }
        
        _toolView.previewButton.addTarget(self, action: #selector(__buttonClicked(_:)), for: UIControl.Event.touchUpInside)
        _toolView.selectOriginalImageButton.addTarget(self, action: #selector(__buttonClicked(_:)), for: UIControl.Event.touchUpInside)
        _toolView.completeButton.addTarget(self, action: #selector(__buttonClicked(_:)), for: UIControl.Event.touchUpInside)
        
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width: CGFloat
        let y: CGFloat
        let bottom: CGFloat
        if #available(iOS 11.0, *) {
            width = view.bounds.inset(by: view.safeAreaInsets).width
            y = view.bounds.height - view.safeAreaInsets.bottom - 44.0
            bottom = view.safeAreaInsets.bottom
        } else {
            // Fallback on earlier versions
            width = view.bounds.width
            y = view.bounds.height - 40.0
            bottom = 0
        }
        // Adjust the item size if the available width has changed.
        if _availableWidth != width {
            _safeAreaBottom = bottom
            _availableWidth = width
            let columnCount = (width / 80).rounded(.towardZero)
            let itemLength = (width - ((columnCount - 1) * 2)) / columnCount
            let toolViewHeight = 44.0 + bottom
            collectionViewFlowLayout.footerReferenceSize = CGSize(width: _availableWidth, height: toolViewHeight)
            collectionViewFlowLayout.itemSize = CGSize(width: itemLength, height: itemLength)
            collectionViewFlowLayout.minimumLineSpacing = 2
            collectionViewFlowLayout.minimumInteritemSpacing = 2
            collectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: false)
            _toolView.frame = CGRect(x: 0, y: y, width: width, height: 44.0 + bottom)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager.
        let scale = UIScreen.main.scale
        let cellSize = collectionViewFlowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
        // Add a camera button to the navigation bar if the asset collection supports adding content.
        if assetCollection == nil || assetCollection.canPerform(.addContent) && __configInfo.showTakePhotoButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.camera, target: self, action: #selector(self.__presentImagePickerController))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    // MARK: UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    /// - Tag: PopulateCell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = fetchResult.object(at: indexPath.item)
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "XOGridViewCell", for: indexPath) as? XOGridViewCell
            else { fatalError("Unexpected cell in collection view") }

        var mediaType: MediaType = .image
//        debugPrint("cell item", indexPath.item, asset.mediaType.rawValue , asset.mediaSubtypes.rawValue, asset.duration)
        // Add a badge to the cell if the PHAsset represents a Live Photo.
        if asset.mediaSubtypes.contains(.photoLive) {
            mediaType = .photoLive
        }
        else if asset.mediaType == .audio {
            mediaType = .audio(asset.duration)
            
        }
        else if asset.mediaType == .video {
            mediaType = .video(asset.duration)
            cell.videoPhotoBadgeImage = self._videoPhotoBadgeImage
        }
        
        cell.mediaType = mediaType
        
        cell.selectPhotoButton.setImage(_photoDefImage, for: .normal)
        cell.selectPhotoButton.setImage(_photoSelImage, for: .selected)
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        cell.asset = asset
        
        let selectAsset = self.__configInfo.selectAsset
        cell.selectPhotoButton.isSelected = selectAsset.contains(asset)
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // UIKit may have recycled this cell by the handler's activation time.
            // Set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        
        weak var weakCell = cell
        weakCell?.didSelectPhotoBlock = { [weak self] (isSelected) in
            guard let config = self?.__configInfo, let _ = weakCell?.representedAssetIdentifier,let asset = weakCell?.asset  else {
                return
            }
            
            if isSelected {
                // cancel select
                weakCell?.selectPhotoButton.isSelected = false
                config.selectAsset.removeAll(where: { (item) -> Bool in
                    return asset == item
                })
            } else {
                // select:check if over the maxImagesCount
                if config.maxImagesCount > config.selectAsset.count {
                    // 判断视频选择
                    weakCell?.selectPhotoButton.isSelected = true
                    config.selectAsset.append(asset)
                } else {
                    // 提示最大数量
                    debugPrint("照片达到最大限制")
                    return
                }
            }
        }
        return cell
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = XOPhotoPreviewController()
        var fetchResult = [PHAsset]()
        self.fetchResult.enumerateObjects { (asset, index, isStop) in
            fetchResult.append(asset)
        }
        
        vc.fetchResult = fetchResult
        vc.assetCollection = self.assetCollection
        vc.currentIndex = indexPath.item
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: UIScrollView
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK: Asset Caching
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    /// - Tag: UpdateAssets
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The window you prepare ahead of time is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start and stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        // Store the computed rectangle for future comparison.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    // MARK: UI Actions
    /// - Tag: AddAsset
    func addImage(_ image: UIImage, location: CLLocation?, creationDate: Date = Date()) {
        // Add the asset to the photo library.
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            creationRequest.location = location
            creationRequest.creationDate = creationDate
            if let assetCollection = self.assetCollection {
                let addAssetRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                addAssetRequest?.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
            }
        }, completionHandler: {success, error in
            if !success { debugPrint("Error creating the asset: \(String(describing: error))") }
        })
    }
    
    func addVideoUrl(_ url: URL, location: CLLocation?, creationDate: Date = Date()) {
        PHPhotoLibrary.shared().performChanges({
            guard let creationRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url) else {
                debugPrint("Error creating the asset: \(String(describing: "creationRequestForAssetFromVideo faile"))")
                return
            }
            creationRequest.location = location
            creationRequest.creationDate = creationDate
            if let assetCollection = self.assetCollection {
                let addAssetRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                addAssetRequest?.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
            }
        }) { (success, error) in
            if !success { debugPrint("Error creating the asset: \(String(describing: error))") }
        }
    }
    
    @objc private
    func __buttonClicked(_ sender: UIButton?) {
        guard let button = sender else {
            return
        }
        
        
        if button == _toolView.previewButton {
            let configInfo = __configInfo
            guard configInfo.selectAsset.count > 0 else {
                // TODO: 提示没有选择
                return
            }
            
            let vc = XOPhotoPreviewController()
            vc.fetchResult = configInfo.selectAsset
            vc.currentIndex = 0
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        else if button == _toolView.selectOriginalImageButton {
            
        }
        else if button == _toolView.completeButton {
            self.dismiss(animated: true) { }
        }
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension XOAssetGridViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // Change notifications may originate from a background queue.
        // As such, re-dispatch execution to the main queue before acting
        // on the change, so you can update the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            // If we have incremental changes, animate them in the collection view.
            if changes.hasIncrementalChanges {
                guard let collectionView = self.collectionView else { fatalError() }
                // Handle removals, insertions, and moves in a batch update.
                collectionView.performBatchUpdates({
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
                // We are reloading items after the batch update since `PHFetchResultChangeDetails.changedIndexes` refers to
                // items in the *after* state and not the *before* state as expected by `performBatchUpdates(_:completion:)`.
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
            } else {
                // Reload the collection view if incremental changes are not available.
                collectionView.reloadData()
            }
            resetCachedAssets()
        }
    }
}

private
extension XOAssetGridViewController {
    
//    func __getAsset(indexPath: IndexPath) -> PHAsset {
//        let config = __configInfo
//        if config.showTakePhotoButton && config.sortAscendingByModificationDate == true {
//            return fetchResult.object(at: indexPath.item - 1)
//        }
//        return fetchResult.object(at: indexPath.item)
//    }
    
//    func __isShowTakePhotoButton(indexPath: IndexPath) -> Bool {
//        let config = __configInfo
//        if config.showTakePhotoButton {
//            if config.sortAscendingByModificationDate == true && indexPath.item == 0 {
//                return true
//            }
//            if config.sortAscendingByModificationDate == false && indexPath.item ==  fetchResult.count - 1 {
//                return true
//            }
//        }
//        return false
//    }
    
    @objc
    func __presentImagePickerController() {
        let config = __configInfo
        let vc = UIImagePickerController()
        vc.sourceType = config.sourceType // 必须要在其他属性之前
        
        vc.delegate = self
        vc.allowsEditing = config.allowsEditing
        vc.cameraFlashMode = config.cameraFlashMode
        vc.cameraCaptureMode = config.cameraCaptureMode
        vc.cameraDevice = config.cameraDevice
        vc.mediaTypes = config.mediaTypes
        
        if #available(iOS 11.0, *) {
            vc.imageExportPreset = config.imageExportPreset
        } else {
            // Fallback on earlier versions
        }
        
        if #available(iOS 11.0, *) {
            vc.videoExportPreset = config.videoExportPreset.rawValue
        } else {
            // Fallback on earlier versions
        }
        vc.videoMaximumDuration = config.videoMaximumDuration
        vc.videoQuality = config.videoQuality
        self.present(vc, animated: true, completion: nil)
    }
    
//    func __pushPreviewController(indexPath: IndexPath) {
//
//    }
}

// MARK: UIImagePickerControllerDelegate
extension XOAssetGridViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { picker.delegate = nil }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { picker.delegate = nil }
        let type = info[UIImagePickerController.InfoKey.mediaType] as! String
        if type == "public.image" {
            guard let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                fatalError()
            }
            debugPrint("图片输入",photo)
            // TODO: 开启位置权限获取位置数据
            addImage(photo, location: nil)
        }
        else if type == "public.movie" {
            guard let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
                fatalError()
            }
            debugPrint("视频输出",videoUrl)
            // TODO: 开启位置权限获取位置数据
            addVideoUrl(videoUrl, location: nil)
        } else {
            fatalError()
        }
    }
}



