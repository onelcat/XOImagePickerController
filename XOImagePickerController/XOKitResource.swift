//
//  XOKitResource.swift
//  XOImagePickerController
//
//  Created by luo fengyuan on 2019/6/28.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import Foundation

extension UIImage {
    convenience init?(XOKit name: String) {
        let bundle = Bundle.XOKit()
        
        let exName = name + "@2x"
        
        guard let imagePath = bundle.path(forResource: exName, ofType: "png") else {
            return nil
        }
        
        if FileManager.default.isExecutableFile(atPath: imagePath) {
            self.init(contentsOfFile: imagePath)
        } else {
            self.init(named: name)
        }
    }
    
}
