//
//  FirstViewController.swift
//  CustomNavigationBar
//
//  Created by zj on 2017/8/24.
//  Copyright © 2017年 zj. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController,UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(256)) / 255.0, green: CGFloat(arc4random_uniform(256)) / 255.0, blue: CGFloat(arc4random_uniform(256)) / 255.0, alpha: 1.0)
        
        let titles = ["赵","钱","孙","李"]
        let index = arc4random_uniform(4)
        let title = titles[Int(index)];
        self.title = "vc\(title)"
        
        self.navigationItem.rightBarButtonItems = UIBarButtonItem.rightBarbuttonItem(self, action: #selector(backToRootViewController), normalIcon: "classify", hightlightIcon: "classify")
    }
    
    func backToRootViewController() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let firstVC = FirstViewController()
        navigationController?.pushViewController(firstVC, animated: true)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.navigationBar.isHidden = true
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.navigationBar.isHidden = false
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

}
