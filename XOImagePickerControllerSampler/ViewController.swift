//
//  ViewController.swift
//  XOImagePickerControllerSampler
//
//  Created by luo fengyuan on 2019/6/25.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import UIKit
import XOImagePickerController


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
        
        let nvc = XOImagePickerController.init()
        nvc.showTakePhotoButton = true
        self.present(nvc, animated: true, completion: nil)
    }


}

