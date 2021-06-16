//
//  settingController.swift
//  Core Bluetooth
//
//  Created by 清水直輝 on 2017/07/01.
//  Copyright © 2017年 清水直輝. All rights reserved.
//


import UIKit
import LTMorphingLabel

class settingController: UIViewController, UIScrollViewDelegate {
    
    var x : CGFloat!
    var y : CGFloat!
    
    var sx : CGFloat!
    var sy : CGFloat!
    
    
    // scrollViewのインスタンス生成
    let scrollView = UIScrollView()
    
    
    //設定モード
    //レーダー設定
    var ImgSettingLeader1 : UIImage!
    var ImgSettingLeader2 : UIImage!
    var ImgSettingLeader3 : UIImage!
    var ImgSettingLeader4 : UIImage!
    var ImgSettingLeaderListArray : Array<UIImage> = []
    var BtnSettingLeader1 : UIButton!
    var BtnSettingLeader2 : UIButton!
    var BtnSettingLeader3 : UIButton!
    var BtnSettingLeader4 : UIButton!
    //ヘルプ
    var ImgSettingHelp1 : UIImage!
    var ImgSettingHelp2 : UIImage!
    var ImgSettingHelp3 : UIImage!
    var ImgSettingHelp4 : UIImage!
    var ImgSettingHelp5 : UIImage!
    var ImgSettingHelp6 : UIImage!
    var ImgSettingHelp7 : UIImage!
    var ImgsettingHelpListArray : Array<UIImage> = []
    var BtnSettingHelp1 : UIButton!
    var BtnSettingHelp2 : UIButton!
    var BtnSettingHelp3 : UIButton!
    var BtnSettingHelp4 : UIButton!
    var BtnSettingHelp5 : UIButton!
    var BtnSettingHelp6 : UIButton!
    var BtnSettingHelp7 : UIButton!
    
    var ImgSettingBackground : UIImage!
    var ImgViewSettingBackground : UIImageView!
    
    // 注意事項TableView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        x = self.view.frame.width
        y = self.view.frame.height
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "KohinoorTelugu-Medium", size: y/30)!]
        
        /****************************** scrollView ******************************/
        
        scrollView.backgroundColor = UIColor.lightGray
        
        // 表示窓のサイズと位置を設定
        scrollView.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        scrollView.center = self.view.center
        
        // 中身の大きさを設定
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: y*1.01)
        
        // スクロールの跳ね返り
        scrollView.bounces = true
        
        // スクロールバーの見た目と余白
        scrollView.indicatorStyle = .white
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        scrollView.showsHorizontalScrollIndicator = true
        // Delegate を設定
        scrollView.delegate = self
        
        self.view.addSubview(scrollView)
        
        /****************************** ここからレイアウトなどのUI設計 ******************************/
        
        sx = self.scrollView.frame.width
        sy = self.scrollView.frame.height
        
        
        ImgSettingBackground = UIImage(named:"設定モード（タイルの背景）.png")
        ImgViewSettingBackground = UIImageView()
        ImgViewSettingBackground.frame = CGRect(x:0,y:0,width:self.view.bounds.width,height:self.view.bounds.height)
        
        ImgViewSettingBackground.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/2)
        ImgViewSettingBackground.image = ImgSettingBackground
        self.scrollView.addSubview(ImgViewSettingBackground)
        
        ImgSettingLeader1 = UIImage(named:"設定モード（歯車左下テキストver）.png")
        ImgSettingLeader2 = UIImage(named:"設定モード（歯車真下テキストver）.png")
        ImgSettingLeader3 = UIImage(named:"設定モード（歯車真上テキストver）.png")
        ImgSettingLeader4 = UIImage(named:"設定モード（歯車右下テキストver）.png")
        
        BtnSettingLeader1 = UIButton()
        BtnSettingLeader2 = UIButton()
        BtnSettingLeader3 = UIButton()
        BtnSettingLeader4 = UIButton()
        
        BtnSettingLeader1.frame = CGRect(x:0,y:0,width:self.view.bounds.width / 2.6,height:self.view.bounds.width / 2.6)
        BtnSettingLeader2.frame = CGRect(x:0,y:0,width:self.view.bounds.width / 3,height:self.view.bounds.width / 3)
        BtnSettingLeader3.frame = CGRect(x:0,y:0,width:self.view.bounds.width / 1.75,height:self.view.bounds.width / 1.75)
        BtnSettingLeader4.frame = CGRect(x:0,y:0,width:self.view.bounds.width / 2.6,height:self.view.bounds.width / 2.6)
        
        BtnSettingLeader1.setImage(ImgSettingLeader1, for: .normal)
        BtnSettingLeader2.setImage(ImgSettingLeader2, for: .normal)
        BtnSettingLeader3.setImage(ImgSettingLeader3, for: .normal)
        BtnSettingLeader4.setImage(ImgSettingLeader4, for: .normal)
        
        BtnSettingLeader1.layer.position = CGPoint(x:self.view.bounds.width/5.2,y:self.view.bounds.height / 2.5 - self.view.bounds.width / 10.5)
        BtnSettingLeader2.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height / 2.05 - self.view.bounds.width / 9)
        BtnSettingLeader3.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height / 4.5 - self.view.bounds.width / 10)
        BtnSettingLeader4.layer.position = CGPoint(x:self.view.bounds.width/1.24,y:self.view.bounds.height / 2.5 - self.view.bounds.width / 10.5)
        
        BtnSettingLeader1.layer.zPosition = 3
        BtnSettingLeader2.layer.zPosition = 3
        BtnSettingLeader3.layer.zPosition = 3
        BtnSettingLeader4.layer.zPosition = 3
        
        BtnSettingLeader1.tag = 1
        BtnSettingLeader2.tag = 2
        BtnSettingLeader3.tag = 3
        BtnSettingLeader4.tag = 4
        
        BtnSettingLeader1.addTarget(self, action: #selector(settingController.SettingButtonLeaderClick(sender:)), for: .touchUpInside)
        BtnSettingLeader2.addTarget(self, action: #selector(settingController.SettingButtonLeaderClick(sender:)), for: .touchUpInside)
        BtnSettingLeader3.addTarget(self, action: #selector(settingController.SettingButtonLeaderClick(sender:)), for: .touchUpInside)
        BtnSettingLeader4.addTarget(self, action: #selector(settingController.SettingButtonLeaderClick(sender:)), for: .touchUpInside)
        
        self.scrollView.addSubview(BtnSettingLeader1)
        self.scrollView.addSubview(BtnSettingLeader2)
        self.scrollView.addSubview(BtnSettingLeader3)
        self.scrollView.addSubview(BtnSettingLeader4)
        
        //歳差っそあいs
        
        ImgSettingHelp1 = UIImage(named:"設定モード（真上）.png")
        ImgSettingHelp2 = UIImage(named:"設定モード（真ん中）.png")
        ImgSettingHelp3 = UIImage(named:"設定モード（真下）.png")
        ImgSettingHelp4 = UIImage(named:"設定モード（左上）.png")
        ImgSettingHelp5 = UIImage(named:"設定モード（左下）.png")
        ImgSettingHelp6 = UIImage(named:"設定モード（右上）.png")
        ImgSettingHelp7 = UIImage(named:"設定モード（右下）.png")
        
        BtnSettingHelp1 = UIButton()
        BtnSettingHelp2 = UIButton()
        BtnSettingHelp3 = UIButton()
        BtnSettingHelp4 = UIButton()
        BtnSettingHelp5 = UIButton()
        BtnSettingHelp6 = UIButton()
        BtnSettingHelp7 = UIButton()
        
        BtnSettingHelp1.frame = CGRect(x:0,y:0,width:ImgSettingHelp1.size.width,height:ImgSettingHelp1.size.height)
        BtnSettingHelp2.frame = CGRect(x:0,y:0,width:ImgSettingHelp2.size.width,height:ImgSettingHelp2.size.height)
        BtnSettingHelp3.frame = CGRect(x:0,y:0,width:ImgSettingHelp3.size.width,height:ImgSettingHelp3.size.height)
        BtnSettingHelp4.frame = CGRect(x:0,y:0,width:ImgSettingHelp4.size.width,height:ImgSettingHelp4.size.height)
        BtnSettingHelp5.frame = CGRect(x:0,y:0,width:ImgSettingHelp5.size.width,height:ImgSettingHelp5.size.height)
        BtnSettingHelp6.frame = CGRect(x:0,y:0,width:ImgSettingHelp6.size.width,height:ImgSettingHelp6.size.height)
        BtnSettingHelp7.frame = CGRect(x:0,y:0,width:ImgSettingHelp7.size.width,height:ImgSettingHelp7.size.height)
        
        BtnSettingHelp1.setImage(ImgSettingHelp1, for: .normal)
        BtnSettingHelp2.setImage(ImgSettingHelp2, for: .normal)
        BtnSettingHelp3.setImage(ImgSettingHelp3, for: .normal)
        BtnSettingHelp4.setImage(ImgSettingHelp4, for: .normal)
        BtnSettingHelp5.setImage(ImgSettingHelp5, for: .normal)
        BtnSettingHelp6.setImage(ImgSettingHelp6, for: .normal)
        BtnSettingHelp7.setImage(ImgSettingHelp7, for: .normal)
        
        
        BtnSettingHelp1.layer.zPosition = 3
        BtnSettingHelp2.layer.zPosition = 3
        BtnSettingHelp3.layer.zPosition = 3
        BtnSettingHelp4.layer.zPosition = 3
        BtnSettingHelp5.layer.zPosition = 3
        BtnSettingHelp6.layer.zPosition = 3
        BtnSettingHelp7.layer.zPosition = 3
        
        
        BtnSettingHelp1.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height / 1.625)
        BtnSettingHelp2.layer.position = CGPoint(x:self.view.bounds.width/2.02,y:self.view.bounds.height / 1.30)
        BtnSettingHelp3.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height / 1.09)
        
        BtnSettingHelp4.layer.position = CGPoint(x:self.view.bounds.width/4.4,y:self.view.bounds.height / 1.425)
        BtnSettingHelp5.layer.position = CGPoint(x:self.view.bounds.width/4.33,y:self.view.bounds.height / 1.15)
        BtnSettingHelp6.layer.position = CGPoint(x:self.view.bounds.width/1.31,y:self.view.bounds.height / 1.425)
        BtnSettingHelp7.layer.position = CGPoint(x:self.view.bounds.width/1.31,y:self.view.bounds.height / 1.15)
        
        BtnSettingHelp1.tag = 1
        BtnSettingHelp2.tag = 2
        BtnSettingHelp3.tag = 3
        BtnSettingHelp4.tag = 4
        BtnSettingHelp5.tag = 5
        BtnSettingHelp6.tag = 6
        BtnSettingHelp7.tag = 7
        
        BtnSettingHelp1.addTarget(self, action: #selector(settingController.SettingButtonHelpClick(sender:)), for: .touchUpInside)
        BtnSettingHelp2.addTarget(self, action: #selector(settingController.SettingButtonHelpClick(sender:)), for: .touchUpInside)
        BtnSettingHelp3.addTarget(self, action: #selector(settingController.SettingButtonHelpClick(sender:)), for: .touchUpInside)
        BtnSettingHelp4.addTarget(self, action: #selector(settingController.SettingButtonHelpClick(sender:)), for: .touchUpInside)
        BtnSettingHelp5.addTarget(self, action: #selector(settingController.SettingButtonHelpClick(sender:)), for: .touchUpInside)
        BtnSettingHelp6.addTarget(self, action: #selector(settingController.SettingButtonHelpClick(sender:)), for: .touchUpInside)
        BtnSettingHelp7.addTarget(self, action: #selector(settingController.SettingButtonHelpClick(sender:)), for: .touchUpInside)
        
        self.scrollView.addSubview(BtnSettingHelp1)
        self.scrollView.addSubview(BtnSettingHelp2)
        self.scrollView.addSubview(BtnSettingHelp3)
        self.scrollView.addSubview(BtnSettingHelp4)
        self.scrollView.addSubview(BtnSettingHelp5)
        self.scrollView.addSubview(BtnSettingHelp6)
        self.scrollView.addSubview(BtnSettingHelp7)
        
        
    }
    
    // バーガーボタンが押された時の処理
    @IBAction func menuClick(_ sender: UIButton) {
        
        guard let rootViewController = rootViewController() else {return
        }
        rootViewController.presentMenuViewController()
    }
    
    /******************** UIScriollViewDelegateメソッド ********************/
    // スクロール中の処理
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // ドラッグ開始時の処理
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    
    func SettingButtonLeaderClick(sender : UIButton){
        // レーダー音
        if(sender.tag == 1){
            let navigationController = navigationLeaderView()
            self.navigationController?.pushViewController(navigationController, animated: true)
        }
        // 端末登録
        else if(sender.tag == 2){
            let navigationController = navigationDeviceView()
            self.navigationController?.pushViewController(navigationController, animated: true)
        }
        
        else if(sender.tag == 3){
            
        }
        // あなたの端末情報
        else if(sender.tag == 4){
            let navigationController = navigationInformationView()
            self.navigationController?.pushViewController(navigationController, animated: true)
        }
        
        let rotationAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
        rotationAnimation.toValue = CGFloat(-M_PI / 180) * 360
        rotationAnimation.duration = 0.8
        rotationAnimation.repeatCount = 1
        BtnSettingLeader1.layer.add(rotationAnimation, forKey: "rotationAnimation")
        rotationAnimation.toValue = CGFloat(M_PI / 180) * 360
        rotationAnimation.duration = 0.8
        rotationAnimation.repeatCount = 1
        BtnSettingLeader2.layer.add(rotationAnimation, forKey: "rotationAnimation")
        rotationAnimation.toValue = CGFloat(-M_PI / 180) * 360
        rotationAnimation.duration = 0.8
        rotationAnimation.repeatCount = 1
        BtnSettingLeader4.layer.add(rotationAnimation, forKey: "rotationAnimation")
        
    }

    
    func SettingButtonHelpClick(sender : UIButton){
        // アプリについて
        if(sender.tag == 1){
            let navigationController = navigationApplicationView()
            self.navigationController?.pushViewController(navigationController, animated: true)
        }
        //
        else if(sender.tag == 2){
            
        }
        // 紛失モード
        else if(sender.tag == 3){
            
            let navigationController = navigationLostView()
            self.navigationController?.pushViewController(navigationController, animated: true)
        }
        // 迷子モード
        else if(sender.tag == 4){
            
            let navigationController = navigationChildView()
            self.navigationController?.pushViewController(navigationController, animated: true)
        }
        // 注意事項
        else if(sender.tag == 5){
            
            let navigationController = navigationWarningView()
            self.navigationController?.pushViewController(navigationController, animated: true)
        }
        // 接続キーについて
        else if(sender.tag == 6){
            
            let navigationController = navigationKeyView()
            self.navigationController?.pushViewController(navigationController, animated: true)
        }
        // 設定について
        else if(sender.tag == 7){
            let navigationController = navigationSettingView()
            self.navigationController?.pushViewController(navigationController, animated: true)
        }
        
        let rotationAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI / 180) * 360
        rotationAnimation.duration = 0.8
        rotationAnimation.repeatCount = 1
        BtnSettingHelp1.layer.add(rotationAnimation, forKey: "rotationAnimation")
        rotationAnimation.toValue = CGFloat(-M_PI / 180) * 360
        rotationAnimation.duration = 0.8
        rotationAnimation.repeatCount = 1
        BtnSettingHelp3.layer.add(rotationAnimation, forKey: "rotationAnimation")
        BtnSettingHelp4.layer.add(rotationAnimation, forKey: "rotationAnimation")
        rotationAnimation.toValue = CGFloat(M_PI / 180) * 360
        rotationAnimation.duration = 0.8
        rotationAnimation.repeatCount = 1
        BtnSettingHelp5.layer.add(rotationAnimation, forKey: "rotationAnimation")
        rotationAnimation.toValue = CGFloat(-M_PI / 180) * 360
        rotationAnimation.duration = 0.8
        rotationAnimation.repeatCount = 1
        BtnSettingHelp6.layer.add(rotationAnimation, forKey: "rotationAnimation")
        rotationAnimation.toValue = CGFloat(M_PI / 180) * 360
        rotationAnimation.duration = 0.8
        rotationAnimation.repeatCount = 1
        BtnSettingHelp7.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
}

