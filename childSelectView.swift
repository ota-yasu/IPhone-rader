//
//  childSelectView.swift
//  iPhoneレーダー
//
//  Created by 清水直輝 on 2017/08/18.
//  Copyright © 2017年 平子英樹. All rights reserved.
//


import UIKit
import LTMorphingLabel

class childSelectView : UIViewController {
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var x: CGFloat!
    var y: CGFloat!
    
    var ImgSettingBackground : UIImage!
    var ImgViewSettingBackground : UIImageView!
    
    @IBOutlet weak var menuButton: UIButton!
    
    // アニメーションボタン
    var leaderButton = ZFRippleButton()
    var normalButton = ZFRippleButton()
    
    // アニメーションラベル
    var leaderLabel : LTMorphingLabel!
    var normalLabel : LTMorphingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        x = self.view.frame.width
        y = self.view.frame.height
        
        menuButton.layer.zPosition = 5
        
        ImgSettingBackground = UIImage(named:"まち.png")
        ImgViewSettingBackground = UIImageView()
        ImgViewSettingBackground.frame = CGRect(x:0,y:0,width:self.view.bounds.width,height:self.view.bounds.height)
        ImgViewSettingBackground.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/2)
        ImgViewSettingBackground.image = ImgSettingBackground
        self.view.addSubview(ImgViewSettingBackground)
        
        
        
        let leaderImage = UIImage(named:"基準のボタン.png")
        leaderButton.frame = CGRect(x:0,y:0,width:(leaderImage?.size.width)!,height:(leaderImage?.size.height)!)
        leaderButton.layer.position = CGPoint(x:x/2,y:y/2 - y/6)
        leaderButton.tag = 1
        leaderButton.setImage(leaderImage, for: .normal)
        leaderButton.addTarget(self, action: #selector(childSelectView.onclickbutton(sender:)), for: .touchUpInside)
        self.view.addSubview(leaderButton)
        
        leaderLabel = LTMorphingLabel(frame: CGRect(x: x/2 - x/4, y: y/2 - y/2.5, width: x, height: y/20))
        leaderLabel.textColor = UIColor.red
        leaderLabel.font = UIFont.systemFont(ofSize: x/20)
        leaderLabel.text = "みんなの中心となる人"
        leaderLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(leaderLabel)
        
        
        normalLabel = LTMorphingLabel(frame: CGRect(x: x/2 - x/2.5, y: y/2 + y/5, width: x, height: y/20))
        normalLabel.textColor = UIColor.blue
        normalLabel.font = UIFont.systemFont(ofSize: x/20)
        normalLabel.text = "中心の人とはぐれないようにする人"
        normalLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(normalLabel)
        
        
        let normalImage = UIImage(named:"普通.png")
        normalButton.frame = CGRect(x:0,y:0,width:(normalImage?.size.width)!/1.5,height:(normalImage?.size.height)!/1.5)
        normalButton.layer.position = CGPoint(x:x/2,y:y/2 + y/2.7)
        normalButton.tag = 2
        normalButton.setImage(normalImage, for: .normal)
        normalButton.addTarget(self, action: #selector(childSelectView.onclickbutton(sender:)), for: .touchUpInside)
        self.view.addSubview(normalButton)
        
        self.view.backgroundColor = UIColor.lightGray
        
        
    }
    
    func onclickbutton(sender:UIButton){
        
        appDelegate.dispatchBool = true
        appDelegate.receveBool = true
        appDelegate.ble1 = true
        appDelegate.ble2 = true
        
        if(sender.tag == 1){
            
            
            
            let childMove: UIViewController = childController()
            childMove.modalTransitionStyle = .crossDissolve
            self.present(childMove, animated: true, completion: nil)
            
        }
        else{
            
            let childMove: UIViewController = childController2()
            childMove.modalTransitionStyle = .crossDissolve
            self.present(childMove, animated: true, completion: nil)
        }
    }
    
    @IBAction func menuClick(_ sender: UIButton) {
        
        guard let rootViewController = rootViewController() else { return }
        rootViewController.presentMenuViewController()
    }
    
}
