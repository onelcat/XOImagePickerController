//
//  XOToolView.swift
//  XOImagePickerController
//
//  Created by eru yan on 2019/7/1.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import Foundation

class XOToolView: UIView {
    private var _availableWidth: CGFloat = 0
    var previewButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setTitle("预览", for: .normal)
        return button
    }()
    
    var selectOriginalImageButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setTitle("原图", for: .normal)
        return button
    }()
    
    var completeButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setTitle("完成", for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(previewButton)
        addSubview(selectOriginalImageButton)
        addSubview(completeButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
