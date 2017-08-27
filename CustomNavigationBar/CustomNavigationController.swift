//
//  CustomNavigationController.swift
//  CustomNavigationBar
//
//  Created by zj on 2017/8/24.
//  Copyright © 2017年 zj. All rights reserved.
//

import UIKit

let ScreenWidth = UIScreen.main.bounds.size.width
let ScreenHeight = UIScreen.main.bounds.size.height
let kDefaultAlpha : CGFloat = 0.6 //默认的将要变透明的遮罩的初始透明度（全黑）
let kTargetTranslateScale : CGFloat = 0.75 //当拖动的距离，占了屏幕的总宽度的3/4时，就让imageView完全显示，遮盖完全消失

func colorFromRGB(rgbValue : Int) -> UIColor {
    return UIColor(red: CGFloat(((rgbValue & 0xFF0000) >> 16))/255.0, green: CGFloat(((rgbValue & 0x0FF00) >> 16))/255.0, blue: CGFloat(((rgbValue & 0x0000FF) >> 16))/255.0, alpha: 1.0)
}

class CustomNavigationController: UINavigationController,UIGestureRecognizerDelegate,UINavigationControllerDelegate {
    
    var screenshotImageView : UIImageView!
    var coverView : UIView!
    var screenshotImgs : Array<UIImage>!
    var panGestureRec : UIScreenEdgePanGestureRecognizer!
    
    var nextVCScreenShotImg : UIImage!
    
    var animationController : AnimationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        navigationBar.tintColor = colorFromRGB(rgbValue: 0x6F7179)
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: -0.8, height: 0)
        view.layer.shadowOpacity = 0.6
        
        animationController = AnimationController()
        
        //1、创建Pan手势识别器，并绑定监听方法
        panGestureRec = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(pan:)))
        panGestureRec.edges = UIRectEdge.left
        //为导航控制器的view添加Pan手势识别器
        view.addGestureRecognizer(panGestureRec)
        
        //2、创建截图的ImageView
        screenshotImageView = UIImageView()
        //app的frame是包括了状态栏高度的frame
        screenshotImageView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        
        //3、创建截图上面的黑色半透明遮罩
        coverView = UIView()
        //遮罩的frame就是截图的frame
        coverView.frame = screenshotImageView.frame
        //遮罩为黑色
        coverView.backgroundColor = UIColor.black
        
        //4、存放所有的截图数组初始化
        screenshotImgs = []
       
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.navigationOperation = operation
        animationController.navigationController = self
        return animationController
    }
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        //只有在导航控制器里面有子控制器的时候才需要截图
        if viewControllers.count >= 1 {
            //调用自定义方法，使用上下文截图
            screenShot()
            viewController.navigationItem.leftBarButtonItems = UIBarButtonItem.leftBarbuttonItem(self, action: #selector(leftBarBtnClicked(btn:)), normalIcon: "back", hightlightIcon: "back")
            viewController.hidesBottomBarWhenPushed = true
        }
         //截图完毕之后，才调用父类的push方法
        super.pushViewController(viewController, animated: true)

    }
    
    //重写常用的Pop方法
    /*
     由于可能调用的是导航栏的popViewController(animated: Bool) -> UIViewController?方法、popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]?方法 或func popToRootViewController(animated: Bool) -> [UIViewController]?来返回，这种情况下，删除的可能就不是一张截图，因此我们需要分别重写这些Pop方法，去确定我们要删除多少张图片
     */
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let index = viewControllers.count
        if screenshotImgs.count >= index - 1 {
            screenshotImgs.removeLast()
        }
        return super.popViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        var removeCount = 0
        for  vc in viewControllers {
            if viewController == vc {
                break
            }
            screenshotImgs.removeLast()
            removeCount += 1
        }
        animationController.removeCount = removeCount
        return super.popToViewController(viewController, animated: animated)
    }
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        animationController.removeCount = screenshotImgs.count
        screenshotImgs.removeAll()
        return super.popToRootViewController(animated: animated)
    }
    
    //MARK:实现截图保存功能，并在push前截图
    func screenShot() {
        //将要被截图的view，即窗口的根控制器的view
        let beyondVC = self.view.window?.rootViewController;
        //背景图片 总的大小
        let size = beyondVC?.view.frame.size
        //开启上下文，使用参数之后，截出来的是原图（YES  0.0 质量高）
        UIGraphicsBeginImageContextWithOptions(size!, true, 0.0)
        //要裁剪的矩形范围
        let rect = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        ////注：iOS7以后renderInContext：由drawViewHierarchyInRect：afterScreenUpdates：替代
        if tabBarController == beyondVC {
            beyondVC?.view.drawHierarchy(in: rect, afterScreenUpdates: false)
        }else{
            view.drawHierarchy(in: rect, afterScreenUpdates: false)
        }
        
        //从上下文中，取出UIImage
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        //添加截取好的图片到图片数组
        if let _snapshot = snapshot {
            screenshotImgs.append(_snapshot)
        }
        //千万记得，结束上下文（移除栈顶的基于当前位图的图形上下文）
        UIGraphicsEndImageContext()
    }
    
    
    //MARK:响应手势的方法
    func panGestureRecognizer(pan : UIScreenEdgePanGestureRecognizer) {
        //如果当前显示的控制器已经是根控制器了，不做任何切换动画，直接返回
        if self.visibleViewController == self.viewControllers[0] {
            return
        }
        //判断pan手势的各个阶段
        switch panGestureRec.state {
        case .began://开始拖拽阶段
            dragBegin()
        case .ended,.cancelled,.failed://结束拖拽阶段
            dragEnd()
        default://正在拖拽阶段
            dragging(pan: pan)
        }
    }
    
    //MARK:开始拖拽，添加图片和遮罩
    func dragBegin() {
        //重点：每次开始pan手势时，都要添加截图imageView和遮罩cover到window中
        view.window?.insertSubview(screenshotImageView, at: 0)
        view.window?.insertSubview(coverView, aboveSubview: screenshotImageView)
        
        //并且，让imageView显示截图数组中的最后（最新）一张截图
        screenshotImageView.image = screenshotImgs.last
    }
    
    //MARK:正在拖动，动画效果的精髓，进行位移和透明度的变化
    func dragging(pan : UIScreenEdgePanGestureRecognizer) {
        //得到手指拖动的位移
        let offsetX = pan.translation(in: view).x
        
        //让整个view都平移
        //挪动整个导航view
        if offsetX > 0 {
            view.transform = CGAffineTransform(translationX: offsetX, y: 0)
        }
        
        //计算目前手指拖动位移占屏幕总的宽高的比例，当这个比例达到3/4时，就让imageview完全显示，遮盖完全消失
        let currentTranslateScaleX = offsetX / self.view.frame.width
        
        if offsetX < ScreenWidth {
            screenshotImageView.transform = CGAffineTransform(translationX: (offsetX - ScreenWidth) * 0.6, y: 0)
        }
        
        // 让遮盖透明度改变,直到减为0,让遮罩完全透明,默认的比例-(当前平衡比例/目标平衡比例)*默认的比例
        let alpha = kDefaultAlpha - (currentTranslateScaleX / kTargetTranslateScale) * kDefaultAlpha
        
        coverView.alpha = alpha
    }
    
    //MARK:结束拖动，判断结束时拖动的距离做响应的处理，并将图片和遮罩从父控件上移除
    func dragEnd() {
        //取出挪动的距离
        let translateX = view.transform.tx
        //取出宽度
        let width = view.frame.size.width
        
        if translateX <= 40 {// 如果手指移动的距离还不到屏幕的一半,往左边挪 (弹回)
            UIView.animate(withDuration: 0.3, animations: {
                //重要~~让被右移的view弹回归位,只要清空transform即可办到
                self.view.transform = CGAffineTransform.identity
                //让imageview大小恢复默认的
                self.screenshotImageView.transform = CGAffineTransform(translationX: -ScreenWidth, y: 0)
                //让遮盖的透明度恢复默认的alpha
                self.coverView.alpha = kDefaultAlpha
            }, completion: { (finished) in
                //重要,动画完成之后,每次都要记得 移除两个view,下次开始拖动时,再添加进来
                self.screenshotImageView.removeFromSuperview()
                self.coverView.removeFromSuperview()
                
            })
        }else{// 如果手指移动的距离还超过了屏幕的一半,往右边挪
            UIView.animate(withDuration: 0.3, animations: {
                // 让被右移的view完全挪到屏幕的最右边,结束之后,还要记得清空view的transform
                self.view.transform = CGAffineTransform(translationX: width, y: 0)
                //让imageView位移还原
                self.screenshotImageView.transform = CGAffineTransform(translationX: 0, y: 0)
                //让遮盖alpha变为0，变得完全透明
                self.coverView.alpha = 0
            }, completion: { (finished) in
                // 重要~~让被右移的view完全挪到屏幕的最右边,结束之后,还要记得清空view的transform,不然下次再次开始drag时会出问题,因为view的transform没有归零
                self.view.transform = CGAffineTransform.identity
                // 移除两个view,下次开始拖动时,再加回来
                self.screenshotImageView.removeFromSuperview()
                self.coverView.removeFromSuperview()
                // 执行正常的Pop操作:移除栈顶控制器,让真正的前一个控制器成为导航控制器的栈顶控制器
                self.popViewController(animated: false)
                self.animationController.removeLastScreenShot()
            })
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:返回方法
    func leftBarBtnClicked(btn:UIButton) {
        self.popViewController(animated: true)
    }
    
    
}
