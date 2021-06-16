//
//  menuViewController.swift
//  Core Bluetooth
//
//  Created by 清水直輝 on 2017/07/14.
//  Copyright © 2017年 清水直輝. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    // メニュー画面のインスタンス
    var menuViewController: UIViewController!
    
    // コンテンツ(ViewController)のインスタンス
    var contentViewController: UIViewController!
    
    // 設定画面にインスタンス
    var settingViewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.
        // 各ViewControllerをロード
        // storyboardIDが"menu"と"content"のViewのインスタンスを生成
        self.menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "menu")
        self.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "leader")
        
        
        // 2.
        // メニューViewControllerを登録
        // 子ViewControllerとして追加.
        // ViewControllerのViewをコンテナに追加
        self.addChildViewController(self.menuViewController)
        self.view.addSubview(self.menuViewController.view)
        self.menuViewController.didMove(toParentViewController: self)
        
        // 3.
        // コンテンツViewControllerを登録
        // 子ViewControllerとして追加.
        // ViewControllerのViewをコンテナに追加
        self.addChildViewController(self.contentViewController)
        self.view.addSubview(self.contentViewController.view)
        self.contentViewController.didMove(toParentViewController: self)
        
        // 4.
        // メニューは非表示にする
        // メニューを前に出す
        self.menuViewController.view.isHidden = true
        self.view.bringSubview(toFront: self.menuViewController.view)
        
    }
    
    
    // メニューViewControllerの表示
    func presentMenuViewController(){
        
        // 子ViewControllerのViewをView階層に追加するからtrue,アニメーションも使うからtrue
        menuViewController.beginAppearanceTransition(true, animated: true)
        self.menuViewController.view.isHidden = false
        
        // offsetByはインデックスを指定した値だけ移動する
        // menuViewControllerを-x軸方向に横サイズ分移動する
        self.menuViewController.view.frame = menuViewController.view.frame.offsetBy(dx: -menuViewController.view.frame.size.width, dy: 0)
        
        // UIViewのアニメーション
        // アニメーションが素早く開始し、完了すると遅くなるイージーアウトカーブを使用します。
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            // アニメーションの範囲をmenuView全部にする
            let bounds = self.menuViewController.view.bounds
            
            // -x軸方向に位置を指定する
            self.menuViewController.view.frame = CGRect(x:-bounds.size.width / 1.4, y:0, width:bounds.size.width, height:bounds.size.height)
            
        }, completion: {_ in
            
            // 子コントローラに外観が変更されたことを通知する
            self.menuViewController.endAppearanceTransition()
        })
    }
    
    // メニューViewControllerの非表示
    func dismissMenuViewController(){
        
        self.menuViewController.beginAppearanceTransition(false, animated: true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.menuViewController.view.frame = self.menuViewController.view.frame.offsetBy(dx: -self.menuViewController.view.bounds.size.width / 2, dy: 0)
        }, completion: {_ in
            
            // 非表示にする
            self.menuViewController.view.isHidden = true
            self.menuViewController.endAppearanceTransition()
        })
    }
    
    
    
    // コンテンツViewControllerにUIViewControllerをセット
    func set(contentViewController: UIViewController){
        
        // 既存コンテンツと新コンテンツが同じであれば無視する
        if let currentContentViewController = self.contentViewController {
            guard type(of:currentContentViewController) != type(of:contentViewController) else {
                return }
        }
        
        // 既存コンテンツの開放
        self.contentViewController.willMove(toParentViewController: nil)
        self.contentViewController.view.removeFromSuperview()
        self.contentViewController.removeFromParentViewController()
        
        // 新コンテンツのセット
        self.contentViewController = contentViewController
        self.view.addSubview(contentViewController.view)
        self.view.bringSubview(toFront: self.menuViewController.view)
        self.addChildViewController(contentViewController)
        
        
        // 新コンテンツフェードイン
        contentViewController.view.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            contentViewController.view.alpha = 1
        }, completion: { _ in
            contentViewController.didMove(toParentViewController: self)
        })
    }
    
}

// UIViewControllerならRootViewControllerを呼べるように拡張している
extension UIViewController {
    func rootViewController() -> RootViewController? {
        
        var vc = self.parent
        while(vc != nil){
            guard let viewController = vc else { return nil }
            if viewController is RootViewController {
                return viewController as? RootViewController
            }
            vc = viewController.parent
        }
        return nil
    }
}

// メニュー画面
class menuViewController : UIViewController {
    
    var leaderButton = ZFRippleButton()
    var childButton = ZFRippleButton()
    var settingButton = ZFRippleButton()
    var closeButton = ZFRippleButton()
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    let leaderClass = leaderViewController()
    
    // 初回はボタンが勝手にアニメーションを始めるからそれを防ぐ変数
    var firstLayout = false
    
    // 横、縦の長さを格納する変数
    var x : CGFloat!
    var y : CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        x = self.view.frame.width / 1.16
        y = self.view.frame.height
        
        buttonMake(x: x, y: y)
        
        
    }
    
    // ボタンを設定する関数
    func buttonMake(x: CGFloat, y: CGFloat){
        
        let sizeX = self.view.frame.width - x
        
        let resizeCloseImage = UIImage(named: "閉じる.png")!.ResizeUIImage(width: sizeX, height: sizeX)
        let resizeLeaderImage = UIImage(named: "レーダー.png")!.ResizeUIImage(width: sizeX, height: sizeX)
        let resizeChildImage = UIImage(named: "迷子.png")!.ResizeUIImage(width: sizeX, height: sizeX)
        let resizeSettingImage = UIImage(named: "設定.png")!.ResizeUIImage(width: sizeX, height: sizeX)
        
        // 閉じるボタン
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.setTitleColor(UIColor.gray, for: .highlighted)
        closeButton.frame = CGRect(x:0,y:0,width:sizeX*2,height:sizeX*2)
        closeButton.layer.position = CGPoint(x:x,y:0)
        closeButton.tag = 1
        closeButton.setImage(resizeCloseImage, for: UIControlState())
        closeButton.addTarget(self, action: #selector(menuViewController.clickButton(sender:)), for: .touchUpInside)
        self.view.addSubview(closeButton)
        
        // レーダーボタン
        leaderButton.setTitleColor(UIColor.white, for: .normal)
        leaderButton.setTitleColor(UIColor.gray, for: .highlighted)
        leaderButton.frame = CGRect(x:0,y:0,width:sizeX*2,height:sizeX*2)
        leaderButton.layer.position = CGPoint(x:x,y:0)
        leaderButton.setImage(resizeLeaderImage, for: UIControlState())
        leaderButton.tag = 2
        leaderButton.addTarget(self, action: #selector(menuViewController.clickButton(sender:)), for: .touchUpInside)
        self.view.addSubview(leaderButton)
        
        // 迷子ボタン
        childButton.setTitleColor(UIColor.white, for: .normal)
        childButton.setTitleColor(UIColor.gray, for: .highlighted)
        childButton.frame = CGRect(x:0,y:0,width:sizeX*2,height:sizeX*2)
        childButton.layer.position = CGPoint(x:x,y:0)
        childButton.tag = 3
        childButton.setImage(resizeChildImage, for: UIControlState())
        childButton.addTarget(self, action: #selector(menuViewController.clickButton(sender:)), for: .touchUpInside)
        self.view.addSubview(childButton)
        
        // 設定ボタン
        settingButton.setTitleColor(UIColor.white, for: .normal)
        settingButton.setTitleColor(UIColor.gray, for: .highlighted)
        settingButton.frame = CGRect(x:0,y:0,width:sizeX*2,height:sizeX*2)
        settingButton.layer.position = CGPoint(x:x,y:0)
        settingButton.tag = 4
        settingButton.setImage(resizeSettingImage, for: UIControlState())
        settingButton.addTarget(self, action: #selector(menuViewController.clickButton(sender:)), for: .touchUpInside)
        self.view.addSubview(settingButton)
        
    }
    
    // 画面が表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(firstLayout == true){
            
            UIButton.animate(withDuration: 0.5, delay: 0.0, options: .transitionCrossDissolve, animations: {
                self.closeButton.center.y = self.y/10
            }, completion: nil)
            
            UIButton.animate(withDuration: 0.5, delay: 0.1, options: .transitionCrossDissolve, animations: {
                self.leaderButton.center.y = self.y/4.3
            }, completion: nil)
            
            
            UIButton.animate(withDuration: 0.5, delay: 0.2, options: .transitionCrossDissolve, animations: {
                self.childButton.center.y = self.y/2.7
            }, completion: nil)
            
            UIButton.animate(withDuration: 0.5, delay: 0.3, options: .transitionCrossDissolve, animations: {
                self.settingButton.center.y = self.y/2
            }, completion: nil)
        }
        else{
            
            firstLayout = true
        }
    }
    
    // 画面が消えた直後に呼ばれる
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.closeButton.center.y = 0
        self.leaderButton.center.y = 0
        self.childButton.center.y = 0
        self.settingButton.center.y = 0
    }
    
    // ボタンのクリック処理
    func clickButton(sender: UIButton) {
        
        // 閉じるボタンが押された時の処理
        if(sender.tag == 1){
            
            guard let rootViewController = rootViewController() else {return }
            rootViewController.dismissMenuViewController()
        }
        
        // レーダーボタンが押された時の処理
        if(sender.tag == 2){
            
            guard let rootViewController = rootViewController() else {return }
            rootViewController.dismissMenuViewController()
            
            let leaderViewController = self.storyboard!.instantiateViewController(withIdentifier: "leader")
            rootViewController.set(contentViewController: leaderViewController)
            
            
        }
        
        // 迷子ボタンが押された時の処理
        if(sender.tag == 3){
            
            guard let rootViewController = rootViewController() else {return }
            rootViewController.dismissMenuViewController()
            
            let childViewController = self.storyboard!.instantiateViewController(withIdentifier: "childSelect")
            rootViewController.set(contentViewController: childViewController)
            
        }
        
        // 設定ボタンが押された時の処理
        if(sender.tag == 4){
            
            guard let rootViewController = rootViewController() else {return }
            rootViewController.dismissMenuViewController()
            
            let settingViewController = self.storyboard!.instantiateViewController(withIdentifier: "setting")
            rootViewController.set(contentViewController: settingViewController)
            
        }
        
    }
    
    
}


