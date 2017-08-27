//
//  UIBarButtonItem + Extension.swift
//  CustomNavigationBar
//
//  Created by zj on 2017/8/24.
//  Copyright © 2017年 zj. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    class func leftBarbuttonItem(_ target:AnyObject,action : Selector,normalIcon : String,hightlightIcon : String) -> [UIBarButtonItem] {
        let leftBtn = UIButton(type: .custom)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        leftBtn.setBackgroundImage(UIImage(named: normalIcon), for: .normal)
        leftBtn.setBackgroundImage(UIImage(named: hightlightIcon), for: .highlighted)
        leftBtn.addTarget(target, action: action, for: .touchUpInside);
        let leftBarBtn = UIBarButtonItem(customView: leftBtn)
        
        //创建UIBarButtonSystemItemFixedSpace
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        
        //将宽度设置为负值
        spaceItem.width = -15;
        
        //将两个BarButtonItem都返回
        return [spaceItem,leftBarBtn];

    }
    
    class func rightBarbuttonItem(_ target:AnyObject,action : Selector,normalIcon : String,hightlightIcon : String) -> [UIBarButtonItem] {
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        rightBtn.setBackgroundImage(UIImage(named: normalIcon), for: .normal)
        rightBtn.setBackgroundImage(UIImage(named: hightlightIcon), for: .highlighted)
        rightBtn.addTarget(target, action: action, for: .touchUpInside);
        let rightBarBtn = UIBarButtonItem(customView: rightBtn)
        
        //创建UIBarButtonSystemItemFixedSpace
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        
        //将宽度设置为负值
        spaceItem.width = -15;
        
        //将两个BarButtonItem都返回
        return [rightBarBtn,spaceItem];
        
    }
}
