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
    
    static let height: CGFloat = 44.0
    
    var previewButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setTitle("预览", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    
    var selectOriginalImageButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setTitle("原图", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    
    var completeButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setTitle("完成", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = #colorLiteral(red: 0, green: 1, blue: 0.1177390888, alpha: 1)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5.0
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        addSubview(previewButton)
        addSubview(selectOriginalImageButton)
        addSubview(completeButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        let width = self.bounds.width
        if _availableWidth != width {
            
            _availableWidth = width
            
            let y: CGFloat = 7.0
            
            previewButton.frame = CGRect(x: 13, y: y, width: 60, height: 30)
            
            selectOriginalImageButton.frame = CGRect(x: 80, y: y, width: 60, height: 30)
            
            let cx = width - 73.0
            completeButton.frame = CGRect(x: cx, y: y, width: 60, height: 30)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
