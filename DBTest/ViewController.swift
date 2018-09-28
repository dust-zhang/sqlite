//
//  ViewController.swift
//  test
//
//  Created by dust.zhang on 2018/8/8.
//  Copyright © 2018年 dust.zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let  btn : UIButton = UIButton()
    internal let  viewLayer : UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        // Do any additional setup after loading the view.
        let image = UIImage.init(named: "1537944983087.jpg")
        viewLayer.frame = CGRect(x: 55, y: 55, width: 222, height: 111)
        self.view.addSubview(viewLayer)
        viewLayer.layer.backgroundColor = UIColor.red.cgColor
        viewLayer.layer.contentsGravity = kCAGravityResizeAspect
        viewLayer.layer.contents = image?.cgImage
        
    }
    
    @objc
    private func onButtonStartTime()
    {
        UpLoadLog.shareInstance().reStartTime()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        BMKPDbManager.shareInstance().insert("zhang")
        
        
    }
    
}
