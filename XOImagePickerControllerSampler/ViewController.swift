//
//  ViewController.swift
//  XOImagePickerControllerSampler
//
//  Created by luo fengyuan on 2019/6/25.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import UIKit
import XOImagePickerController

class GridViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        cell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if (indexPath.row == 2) {
//            return CGSize(width: 200, height: 200)
//        }
        return CGSize(width: 80, height: 80)
    }
}

class ViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        button.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
        button.addTarget(self, action: #selector(self.buttonAction), for: UIControl.Event.touchUpInside)
        self.view.addSubview(button)
        // Do any additional setup after loading the view.
    }
    
    @objc func buttonAction() {
        
        let nvc = XOImagePickerController()
//        nvc.sourceType = .photoLibrary
        self.present(nvc, animated: true, completion: nil)
    }


}

