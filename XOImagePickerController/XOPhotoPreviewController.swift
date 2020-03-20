//
//  XOPhotoPreviewController.swift
//  XOImagePickerController
//
//  Created by hao shuai on 2019/6/28.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import UIKit
import Photos

final
class XOPhotoPreviewController: UIViewController {
    
    var fetchResult: [PHAsset]!
    
    var assetCollection: PHAssetCollection!
    
    var currentIndex: Int = 0
    
    var delegate: XOAssetGridViewControllerChanageAsset?
    
    private var changeSelelctIndex: Set<Int> = []
    
    private var _offsetItemCount: CGFloat = 0
    private var _availableWidth: CGFloat = 0
    lazy private var _layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    lazy private var _collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: _layout)
        view.backgroundColor = UIColor.black
        view.isPagingEnabled = true;
        view.scrollsToTop = false;
        view.showsHorizontalScrollIndicator = false
        view.contentOffset = CGPoint.zero
        return view
    }()
    
    private
    lazy var _rightBarButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(XOKit: "photo_def_photoPickerVc"), for: UIControl.State.normal)
        button.setImage(UIImage(XOKit: "photo_sel_photoPickerVc"), for: UIControl.State.selected)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        self.view.addSubview(_collectionView)
        _collectionView.register(XOPhotoPreviewCell.self, forCellWithReuseIdentifier: "XOPhotoPreviewCell")
        _collectionView.register(XOVideoPreviewCell.self, forCellWithReuseIdentifier: "XOVideoPreviewCell")
        if #available(iOS 11.0, *) {
            _collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.clipsToBounds = true;
        NotificationCenter.default.addObserver(self, selector: #selector(__didChangeStatusBarOrientationNotification(_:)), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
        _rightBarButton.addTarget(self, action: #selector(self.__buttonClicked(_:)), for: UIControl.Event.touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: _rightBarButton)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let width: CGFloat
        if #available(iOS 11.0, *) {
            width = view.bounds.inset(by: view.safeAreaInsets).width
        } else {
            // Fallback on earlier versions
            width = view.bounds.width
        }
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if #available(iOS 9.0,*) {
            
        } else {
            UIApplication.shared.isStatusBarHidden = true
        }
        if self.currentIndex > 0 {
            _collectionView.setContentOffset(CGPoint(x: (width + 20 ) * CGFloat(self.currentIndex), y: 0), animated: false)
        }
        __refreshNaviBarAndBottomBarState()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width: CGFloat
        let height: CGFloat = view.bounds.height
        if #available(iOS 11.0, *) {
            width = view.bounds.inset(by: view.safeAreaInsets).width
        } else {
            // Fallback on earlier versions
            width = view.bounds.width
        }
        // Adjust the item size if the available width has changed.
        if _availableWidth != width {
            _availableWidth = width
            _layout.itemSize = CGSize(width: width + 20, height: height)
            _layout.minimumInteritemSpacing = 0;
            _layout.minimumLineSpacing = 0;
            let count = fetchResult.count
            _collectionView.contentSize = CGSize(width: CGFloat(count) * (width + 20.0), height: 0)
            _collectionView.frame = CGRect(x: -10, y: 0, width: width + 20, height: height)
            _collectionView.setCollectionViewLayout(_layout, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (_offsetItemCount > 0) {
            let offsetX = _offsetItemCount * _layout.itemSize.width;
            _collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let indexs = self.changeSelelctIndex.sorted()
        delegate?.chanageSelectStatus(indexs: indexs)
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    func prefersStatusBarHidden() -> Bool {
        return true
    }
}

private
extension XOPhotoPreviewController {
    
    @objc
    func __buttonClicked(_ sender: UIButton?) {
        guard let config = self.navigationController as? XOImagePickerController else {
            return
        }
        let asset = self.fetchResult[self.currentIndex]
        changeSelelctIndex.insert(self.currentIndex)
        if config.selectAsset.contains(asset) {
            // 清除
            _rightBarButton.isSelected = false
//            debugPrint("现在的数据",config.selectAsset.count)
            for i in 0..<config.selectAsset.count {
//                debugPrint("当前表亲啊", config.selectAsset.count,i)
                if config.selectAsset[i] == asset {
                    config.selectAsset.remove(at: i)
//                    debugPrint("移除元素")
                    return
                }
            }
            
        } else {
            // 添加
            config.selectAsset.append(asset)
            _rightBarButton.isSelected = true
        }
    }
    
    
    @objc
    func __didChangeStatusBarOrientationNotification(_ notification: Notification) {
        _offsetItemCount = _collectionView.contentOffset.x / _layout.itemSize.width;
    }
    
    func __didTapPreviewCell() {
        let isHideNaviBar = self.navigationController?.isNavigationBarHidden ?? false
        self.navigationController?.setNavigationBarHidden(!isHideNaviBar, animated: true)
        self.navigationController?.setToolbarHidden(!isHideNaviBar, animated: true)
    }
    
    func __refreshNaviBarAndBottomBarState() {
        guard let config = self.navigationController as? XOImagePickerController else {
            return
        }
        let asset = self.fetchResult[self.currentIndex]
        
        if config.selectAsset.contains(asset) {
            _rightBarButton.isSelected = true
        } else {
            _rightBarButton.isSelected = false
        }
    }
}

extension XOPhotoPreviewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = fetchResult[indexPath.item]
        if asset.mediaType == .image {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "XOPhotoPreviewCell", for: indexPath) as? XOPhotoPreviewCell else {
                fatalError()
            }
            cell.dataSource = asset
            cell.singleTapHander = { [weak self] in
                self?.__didTapPreviewCell()
            }
            return cell
        }
        if asset.mediaType == .video {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "XOVideoPreviewCell", for: indexPath) as? XOVideoPreviewCell else {
                fatalError()
            }
            cell.dataSource = asset
            cell.singleTapHander = { [weak self] in
                self?.__didTapPreviewCell()
            }
            return cell
        }
        fatalError()
    }
    
}

extension XOPhotoPreviewController {
//    scrollViewDidScroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width: CGFloat
        if #available(iOS 11.0, *) {
            width = view.bounds.inset(by: view.safeAreaInsets).width
        } else {
            width = view.bounds.width
        }
        var offSetWidth = scrollView.contentOffset.x;
        offSetWidth = offSetWidth + ((width + 20) * 0.5);
        //
        let currentIndex:Int = Int(offSetWidth / (width + 20));
        if currentIndex < self.fetchResult.count && self.currentIndex != currentIndex {
            self.currentIndex = currentIndex
            __refreshNaviBarAndBottomBarState()
        }
        NotificationCenter.default.post(name: NSNotification.Name.XOKit.PhotoPreviewCollectionViewDidScroll, object: nil)
    }
}
