//
//  XOPhotoPreviewController.swift
//  XOImagePickerController
//
//  Created by luo fengyuan on 2019/6/28.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import UIKit
import Photos
private let reuseIdentifier = "Cell"

class XOPhotoPreviewController: UIViewController {
    
    var fetchResult: PHFetchResult<PHAsset>!
    
    var assetCollection: PHAssetCollection!
    
    var currentIndex: Int = 0
    
    private var _offsetItemCount:CGFloat = 0
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        self.view.addSubview(_collectionView)
        _collectionView.register(XOPhotoPreviewCell.self, forCellWithReuseIdentifier: "XOPhotoPreviewCell")
        
        self.view.clipsToBounds = true;
        NotificationCenter.default.addObserver(self, selector: #selector(__didChangeStatusBarOrientationNotification(noti:)), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: true)
        UIApplication.shared.isStatusBarHidden = true
        
        let w = self.view.frame.width + 20
        _collectionView.setContentOffset(CGPoint(x: w * CGFloat(self.currentIndex), y: 0), animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _layout.itemSize = CGSize(width: self.view.bounds.width + 20, height: self.view.bounds.height)
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
        _collectionView.frame = CGRect(x: -10, y: 0, width: self.view.bounds.width + 20, height: self.view.bounds.height)
        _collectionView.setCollectionViewLayout(_layout, animated: false)
        if (_offsetItemCount > 0) {
            let offsetX = _offsetItemCount * _layout.itemSize.width;
            _collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
        }
    }
    
    func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @objc private
    func __didChangeStatusBarOrientationNotification(noti: Notification) {
        _offsetItemCount = _collectionView.contentOffset.x / _layout.itemSize.width;
    }
    
}

private
extension XOPhotoPreviewController {
    
}

extension XOPhotoPreviewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "XOPhotoPreviewCell", for: indexPath) as? XOPhotoPreviewCell else {
            fatalError()
        }
        cell.dataSource = fetchResult.object(at: indexPath.item)
        return cell
    }
    
    
}
