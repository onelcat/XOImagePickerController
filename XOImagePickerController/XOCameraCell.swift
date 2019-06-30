//
//  XOCameraCell.swift
//  XOImagePickerController
//
//  Created by hao shuai on 2019/6/28.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import UIKit

class XOCameraCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(XOKit: "takePicture80")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = self.bounds
        self.contentView.addSubview(imageView)
        self.contentView.backgroundColor = #colorLiteral(red: 1, green: 0.6129190483, blue: 0.604277466, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
