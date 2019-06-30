//
//  XOKitResource.swift
//  XOImagePickerController
//
//  Created by hao shuai on 2019/6/28.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import Foundation

extension UIImage {
    convenience init?(XOKit name: String) {
        let bundle = Bundle.XOKit()
        print(bundle)
        let exName = name + "@2x"
        
        guard let imagePath = bundle.path(forResource: exName, ofType: "png") else {
            return nil
        }
        if FileManager.default.fileExists(atPath: imagePath) {
            debugPrint("加载文件", imagePath)
            self.init(contentsOfFile: imagePath)
        } else {
            debugPrint("加载本地图片")
            self.init(named: name)
        }
    }
    
}
