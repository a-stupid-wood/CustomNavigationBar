//
//  AnimationController.swift
//  CustomNavigationBar
//
//  Created by zj on 2017/8/24.
//  Copyright © 2017年 zj. All rights reserved.
//

import UIKit

class AnimationController: NSObject,UIViewControllerAnimatedTransitioning {
    
    var navigationOperation : UINavigationControllerOperation!
    var navigationController : UINavigationController?{
        didSet{
           let beyondVC = navigationController!.view.window?.rootViewController
            //判断该导航栏是否有TabBarController
            if navigationController!.tabBarController == beyondVC {
                isTabbarExist = true
            }else {
                isTabbarExist = false
            }
        }
    }
    
    //导航栏Pop时删除了多少张截图（调用PopToViewController时，计算要删除的截图的数量）
    var removeCount : NSInteger = 0
    
    var screenShotArray : Array<UIImage> = []
    //所属的导航栏有没有TabBarController
    var isTabbarExist = false
    
    class func animationController(operation : UINavigationControllerOperation) -> AnimationController{
        let ac = AnimationController()
        ac.navigationOperation = operation;
        return ac
    }
   
    class func animationController(operation : UINavigationControllerOperation, navigationController : UINavigationController) -> AnimationController {
        let ac = AnimationController()
        ac.navigationController = navigationController
        ac.navigationOperation = operation
        return ac
    }
    
    //MARK:UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let screenImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        let screenImg = self.screenShot()
        screenImgView.image = screenImg
        
        //取出fromViewController,fromView和toViewController，toView
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let toView = transitionContext.view(forKey: .to)
        
        var fromViewEndFrame = transitionContext.finalFrame(for: fromVC!)
        fromViewEndFrame.origin.x = ScreenWidth
        var fromViewStartFrame = fromViewEndFrame
        let toViewEndFrame = transitionContext.finalFrame(for: toVC!)
        let toViewStartFrame = toViewEndFrame
        
        let containerView = transitionContext.containerView
        
        if navigationOperation == UINavigationControllerOperation.push {
            screenShotArray.append(screenImg!)
            
            //这句非常重要，没有这句，就无法正常push和Pop出对应的界面
            containerView.addSubview(toView!)
            
            toView?.frame = toViewStartFrame
            
            //将截图添加到导航栏的view所属的window上
            navigationController?.view.window?.insertSubview(screenImgView, at: 0)
            
            navigationController?.view.transform = CGAffineTransform(translationX: ScreenWidth, y: 0)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { 
                self.navigationController?.view.transform = CGAffineTransform(translationX: 0, y: 0)
                screenImgView.center = CGPoint(x: -ScreenWidth / 2.0, y: ScreenHeight / 2.0)
            }, completion: { (finished) in
                screenImgView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
        
        if navigationOperation == UINavigationControllerOperation.pop {
            fromViewStartFrame.origin.x = 0
            containerView.addSubview(toView!)
            
            let lastVCImgView = UIImageView(frame: CGRect(x: -ScreenWidth, y: 0, width: ScreenWidth, height: ScreenHeight))
            //若removeCount大于0，则说明pop了不止一个控制器
            if removeCount > 0 {
                for i in 0 ..< removeCount {
                    if i == removeCount - 1 {
                        //当删除到要跳转页面的截图时，不要删除，并将该截图作为ToVC的截图显示
                        lastVCImgView.image = screenShotArray.last
                        removeCount = 0
                        break
                    }else{
                        screenShotArray.removeLast()
                    }
                }
            }else{
                lastVCImgView.image = screenShotArray.last
            }
            screenImgView.layer.shadowColor = UIColor.black.cgColor
            screenImgView.layer.shadowOffset = CGSize(width: -0.8, height: 0)
            screenImgView.layer.shadowOpacity = 0.6
            navigationController?.view.window?.addSubview(lastVCImgView)
            navigationController?.view.addSubview(screenImgView)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { 
                screenImgView.center = CGPoint(x: ScreenWidth * 3 / 2.0, y: ScreenHeight / 2.0)
                lastVCImgView.center = CGPoint(x: ScreenWidth / 2.0, y: ScreenHeight / 2.0)
            }, completion: { (finished) in
                lastVCImgView.removeFromSuperview()
                screenImgView.removeFromSuperview()
                self.screenShotArray.removeLast()
                transitionContext.completeTransition(true)
            })
        }
    }
    
    func removeLastScreenShot() {//调用此方法删除数组最后一张截图 (调用pop手势或一次pop多个控制器时使用)
        screenShotArray.removeLast()
    }
    
    func removeAllScreenShot() {// 移除全部屏幕截图
        screenShotArray.removeAll()
    }
    
    func removeLastScreenShot(withNumber number : NSInteger) {//从截屏数组尾部移除指定数量的截图
        for _ in 0 ..< number {
            screenShotArray.removeLast()
        }
    }

    
    func screenShot() -> UIImage? {
        //将要被截图的view，即窗口的根控制器的view
        let beyondVC = self.navigationController?.view.window?.rootViewController;
        //背景图片 总的大小
        let size = beyondVC?.view.frame.size
        //开启上下文，使用参数之后，截出来的是原图（YES  0.0 质量高）
        UIGraphicsBeginImageContextWithOptions(size!, true, 0.0)
        //要裁剪的矩形范围
        let rect = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        ////注：iOS7以后renderInContext：由drawViewHierarchyInRect：afterScreenUpdates：替代
        if isTabbarExist {
            beyondVC?.view.drawHierarchy(in: rect, afterScreenUpdates: false)
        }else {
            navigationController?.view.drawHierarchy(in: rect, afterScreenUpdates: false)
        }
        //从上下文中，取出UIImage
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        //千万记得，结束上下文（移除栈顶的基于当前位图的图形上下文）
        UIGraphicsEndImageContext()

        return snapshot;
    }
    
}
