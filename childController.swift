//
//  childController.swift
//  Core Bluetooth
//
//  Created by 清水直輝 on 2017/06/26.
//  Copyright © 2017年 清水直輝. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation
import UserNotifications
import LTMorphingLabel
import MultipeerConnectivity

// 発信（基準）
class childController : UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, CBPeripheralManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate,  UITextFieldDelegate {
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // viewの長さを入れる変数
    var x : CGFloat!
    var y : CGFloat!
    
    var wx : CGFloat!
    var wy : CGFloat!
    
    var wx2 : CGFloat!
    var wy2 : CGFloat!
    
    var cellColor : UIColor!
    
    var arrayLength: Int = 0
    
    var pickerKey : String = ""
    var keyArray : NSMutableArray = []
    var saveConnectArray : NSMutableArray = []
    var connectArray : NSMutableArray = []
    var distanceArray : NSMutableArray = []
    
    
    // serviceType(接続キー)の値を設定
    var connectServiceType = ""
    
    var myPeerId: MCPeerID!
    
    var serviceAdvertiser : MCNearbyServiceAdvertiser!
    var serviceBrowser : MCNearbyServiceBrowser!
    
    var session : MCSession!
    

/******************************* tableView関連 *******************************/
    // Tableで使用する配列を設定する
    let deviceList: NSMutableArray = []
    
    let situationList: NSMutableArray = []
    
    // 端末追加したものを表示する
    var deviceListTableView: UITableView!
    
/******************************* Label *******************************/
    var selectDeviceLabel : LTMorphingLabel!
    var explainLabel : LTMorphingLabel!
    var connectionLabel : LTMorphingLabel!
    
/******************************* Button *******************************/
    // 端末を追加するボタン
    var addDeviceButton = ZFRippleButton()
    
    // 発信ボタン
    var CallOutBtn = ZFRippleButton()
    
    // 端末を追加(addWindow内)
    var addDeviceButton2 = ZFRippleButton()
    
    var bleButton = ZFRippleButton()
    var connectButton = ZFRippleButton()
    
    // 閉じるボタン
    var closeButton = ZFRippleButton()
    
    var returnButton = ZFRippleButton()
    
/******************************* UIView *******************************/
    // addDeviceButtonにアニメーションを追加するためのUIWindow
    var addWindow: UIWindow!
    
    var connectWindow: UIWindow!
    
/******************************* UIDatePickerView *******************************/
    // データベースの中のデータを表示する
    var databasePicker: UIPickerView = UIPickerView()
    var dataArray: NSMutableArray = []
    
    // 選ばれたデータを表示するTextField
    var databaseTextField: UITextField!
    
    
    var connectTextField: UITextField!
    
    // 背景
    
    var ImgChildBackground : UIImage!
    var ImgViewChildBackground : UIImageView!
    
    //追加削除ボタンのアニメーション画像とボタン//
    var ImgLastButton : UIImage!
    
    var ImgAddButton1 : UIImage!
    var ImgAddButton2 : UIImage!
    var ImgAddButton3 : UIImage!
    var ImgAddButtonArray :Array<UIImage> = []
    var BtnAdd : UIButton!
    
    
    var ImgLostButton1 : UIImage!
    var ImgLostButton2 : UIImage!
    var ImgLostButton3 : UIImage!
    var ImgLostButtonArray :Array<UIImage> = []
    var BtnLost : UIButton!
    
    //追加削除ボタンのアニメーション画像//
    
    //探索開始・終了ボタンのアニメーション画像//
    
    var ImgSearchStartButton1 : UIImage!
    var ImgSearchStartButton2 : UIImage!
    var ImgSearchStartButton3 : UIImage!
    var ImgSearchStartButtonArray :Array<UIImage> = []
    var BtnSearchStart : UIButton!
    
    var ImgSearchStopButton1 : UIImage!
    var ImgSearchStopButton2 : UIImage!
    var ImgSearchStopButton3 : UIImage!
    var ImgSearchStopButtonArray :Array<UIImage> = []
    var BtnSearchStop : UIButton!
    //探索開始・終了ボタンのアニメーション画像//
    
    // 接続ボタンについて
    
    var ImgConnectionStartButton1 : UIImage!
    var ImgConnectionStartButton2 : UIImage!
    var ImgConnectionStartButton3 : UIImage!
    var ImgConnectionStartButtonArray :Array<UIImage> = []
    var BtnConnectionStart : UIButton!
    
    var ImgConnectionStopButton1 : UIImage!
    var ImgConnectionStopButton2 : UIImage!
    var ImgConnectionStopButton3 : UIImage!
    var ImgConnectionStopButtonArray :Array<UIImage> = []
    var BtnConnectionStop : UIButton!
    
    
    var ImgViewConnectionState : UIImageView!
    var ImgConnectionState : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        x = self.view.frame.width
        y = self.view.frame.height
        
        ImgChildBackground = UIImage(named:"迷子モード（背景）.png")
        ImgViewChildBackground = UIImageView()
        ImgViewChildBackground.frame = CGRect(x:0,y:0,width:self.view.bounds.width,height:self.view.bounds.height)
        ImgViewChildBackground.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/2)
        ImgViewChildBackground.image = ImgChildBackground
        self.view.addSubview(ImgViewChildBackground)
        
        self.view.backgroundColor = UIColor.white
        
        cellColor = UIColor.black
        
        
        myPeerId = MCPeerID(displayName: UIDevice.current.name)
        
        session = {
            let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
            session.delegate = self
            return session
        }()
        
        // 端末追加Viewを作成しておく
        addWindow = UIWindow(frame: CGRect(x: x/2, y: y/2, width: x/1.5, height: y/2))
        addWindow.backgroundColor = UIColor.cyan
        addWindow.isHidden = true
        addWindow.layer.zPosition = 5
        addWindow.alpha = 0
        self.view.addSubview(addWindow)
        
        
        // 端末追加Viewを作成しておく
        connectWindow = UIWindow(frame: CGRect(x: x/2, y: y/2, width: x/1.5, height: y/4))
        connectWindow.backgroundColor = UIColor.cyan
        connectWindow.isHidden = true
        connectWindow.layer.zPosition = 5
        connectWindow.alpha = 0
        self.view.addSubview(connectWindow)
        
        wx = addWindow.frame.width
        wy = addWindow.frame.height
        
        wx2 = connectWindow.frame.width
        wy2 = connectWindow.frame.height
        
        let db = FMDatabase(path: DatabaseClass().table)
        let db2 = FMDatabase(path: DatabaseClass().table2)
        let db3 = FMDatabase(path: DatabaseClass().table3)
        let db4 = FMDatabase(path: DatabaseClass().table8)
        
        let sql = "SELECT * FROM device"
        let sql2 = "SELECT * FROM device2"
        let sql3 = "SELECT * FROM device3"
        let sql4 = "SELECT * FROM device8"
        
        db?.open()
        db2?.open()
        db3?.open()
        db4?.open()
        
        let results = db?.executeQuery(sql, withArgumentsIn: nil)
        let results2 = db2?.executeQuery(sql2, withArgumentsIn: nil)
        let results3 = db3?.executeQuery(sql3, withArgumentsIn: nil)
        let results4 = db4?.executeQuery(sql4, withArgumentsIn: nil)
        
        while (results?.next())! {
            
            // カラム名を指定して値を取得する方法
            let user_id = results?.int(forColumn: "user_id")
            
            // カラムのインデックスを指定して取得する方法
            let user_name = results?.string(forColumnIndex: 1)
            
            print("user_id = \(user_id!), user_name = \(user_name!)")
            
            deviceList.add(user_name!)
        }
        
        
        for i in 0..<deviceList.count {
            
            // 更新できるように空を入れておく
            distanceArray.add("未接続")
        }
        
        
        while (results2?.next())! {
            
            // カラムのインデックスを指定して取得する方法
            let user_name = results2?.string(forColumnIndex: 1)
            
            print("user_name = \(user_name!)")
            
            dataArray.add(user_name!)
            
            arrayLength += 1
        }
        while (results3?.next())! {
            
            // カラムのインデックスを指定して取得する方法
            let user_name = results3?.string(forColumnIndex: 1)
            
            print("user_name = \(user_name!)")
            
            keyArray.add(user_name!)
        }
        
        
        while (results4?.next())! {
            
            // カラム名を指定して値を取得する方法
            let user_id = results4?.int(forColumn: "user_id")
            
            // カラムのインデックスを指定して取得する方法
            let user_name = results4?.string(forColumnIndex: 1)
            
            print("user_id = \(user_id!), user_name = \(user_name!)")
            
            saveConnectArray.add(user_name!)
        }
        
        db?.close()
        db2?.close()
        db3?.close()
        db4?.close()
        
        // Status Barの高さを取得する
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = x
        let displayHeight: CGFloat = y/2
        deviceListTableView = UITableView(frame: CGRect(x: 0, y: (y/15)*2, width: displayWidth, height: displayHeight))
        deviceListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        deviceListTableView.dataSource = self
        deviceListTableView.delegate = self
        deviceListTableView.rowHeight = y/15
        deviceListTableView.layer.zPosition = 2
        self.view.addSubview(deviceListTableView)
        
        // 追加ボタン
        ImgAddButton1 = UIImage(named:"迷子モード（追加１）.png")
        ImgAddButton2 = UIImage(named:"迷子モード（追加２）.png")
        ImgAddButton3 = UIImage(named:"迷子モード（追加３）.png")
        ImgLastButton = UIImage(named:"紛失モード（ボタン）.png")
        
        ImgAddButtonArray.append(ImgAddButton1)
        ImgAddButtonArray.append(ImgAddButton2)
        ImgAddButtonArray.append(ImgAddButton3)
        ImgAddButtonArray.append(ImgLastButton)
        
        // 追加ボタン
        BtnAdd = UIButton()
        BtnAdd.frame = CGRect(x:0,y:0,width:x/2,height:y/8)
        BtnAdd.setImage(ImgAddButtonArray[0], for:.normal)
        BtnAdd.setImage(ImgAddButtonArray[0], for:.highlighted)
        BtnAdd.layer.position = CGPoint(x:x/2,y:y/1.1)
        BtnAdd.tag = 1
        BtnAdd.addTarget(self, action: #selector(childController.onclickbutton(sender:)), for: .touchUpInside)
        
        BtnAdd.imageView?.animationImages = ImgAddButtonArray
        BtnAdd.imageView?.animationDuration = 0.5
        BtnAdd.imageView?.animationRepeatCount = 1
        
        
        self.view.addSubview(BtnAdd)
        
        ImgLostButton1 = UIImage(named:"紛失モード（ボタン4）.png")
        ImgLostButton2 = UIImage(named:"紛失モード（ボタン5）.png")
        ImgLostButton3 = UIImage(named:"紛失モード（ボタン6）.png")
        
        ImgLostButtonArray.append(ImgLostButton1)
        ImgLostButtonArray.append(ImgLostButton2)
        ImgLostButtonArray.append(ImgLostButton3)
        ImgLostButtonArray.append(ImgLastButton)
        
        // 追加ボタン押した後の終了ボタン
        BtnLost = UIButton()
        BtnLost.frame = CGRect(x:0,y:0,width:x/2,height:y/8)
        BtnLost.tag = 1
        BtnLost.setImage(ImgLostButtonArray[0], for:.normal)
        BtnLost.setImage(ImgLostButtonArray[0], for:.highlighted)
        BtnLost.layer.position = CGPoint(x:x/2,y:y/1.1)
        BtnLost.addTarget(self, action: #selector(childController.onclickbutton(sender:)), for: .touchUpInside)
        
        BtnLost.imageView?.animationImages = ImgLostButtonArray
        BtnLost.imageView?.animationDuration = 0.5
        BtnLost.imageView?.animationRepeatCount = 1
        
        self.view.addSubview(BtnLost)
        
        BtnLost.isHidden = true
        
        
        
        // 接続ボタン
        
        ImgConnectionStartButton1 = UIImage(named:"迷子モード（接続1）.png")
        ImgConnectionStartButton2 = UIImage(named:"迷子モード（接続2）.png")
        ImgConnectionStartButton3 = UIImage(named:"迷子モード（接続3）.png")
        
        ImgConnectionStartButtonArray.append(ImgConnectionStartButton1)
        ImgConnectionStartButtonArray.append(ImgConnectionStartButton2)
        ImgConnectionStartButtonArray.append(ImgConnectionStartButton3)
        ImgConnectionStartButtonArray.append(ImgLastButton)
        
        BtnConnectionStart = UIButton()
        BtnConnectionStart.frame = CGRect(x:0,y:0,width:x/3,height:y/8)
        BtnConnectionStart.setImage(ImgConnectionStartButtonArray[0], for:.normal)
        BtnConnectionStart.setImage(ImgConnectionStartButtonArray[0], for:.highlighted)
        BtnConnectionStart.layer.position = CGPoint(x:x/1.3,y:y/1.3)
        BtnConnectionStart.tag = 3
        BtnConnectionStart.addTarget(self, action: #selector(childController.onclickbutton(sender:)), for: .touchUpInside)
        
        BtnConnectionStart.imageView?.animationImages = ImgConnectionStartButtonArray
        BtnConnectionStart.imageView?.animationDuration = 0.5
        BtnConnectionStart.imageView?.animationRepeatCount = 1
        
        
        self.view.addSubview(BtnConnectionStart)
        
        ImgConnectionStopButton1 = UIImage(named:"迷子モード（閉じる１）.png")
        ImgConnectionStopButton2 = UIImage(named:"迷子モード（閉じる２）.png")
        ImgConnectionStopButton3 = UIImage(named:"迷子モード（閉じる３）.png")
        
        ImgConnectionStopButtonArray.append(ImgConnectionStopButton1)
        ImgConnectionStopButtonArray.append(ImgConnectionStopButton2)
        ImgConnectionStopButtonArray.append(ImgConnectionStopButton3)
        ImgConnectionStopButtonArray.append(ImgLastButton)
        
        BtnConnectionStop = UIButton()
        BtnConnectionStop.frame = CGRect(x:0,y:0,width:x/3,height:y/8)
        BtnConnectionStop.setImage(ImgConnectionStopButtonArray[0], for:.normal)
        BtnConnectionStop.setImage(ImgConnectionStopButtonArray[0], for:.highlighted)
        BtnConnectionStop.layer.position = CGPoint(x:x/1.3,y:y/1.3)
        BtnConnectionStop.tag = 3
        BtnConnectionStop.addTarget(self, action: #selector(childController.onclickbutton(sender:)), for: .touchUpInside)
        
        BtnConnectionStop.imageView?.animationImages = ImgConnectionStopButtonArray
        BtnConnectionStop.imageView?.animationDuration = 0.5
        BtnConnectionStop.imageView?.animationRepeatCount = 1
        
        self.view.addSubview(BtnConnectionStop)
        
        BtnConnectionStop.isHidden = true
        
        
        addDeviceButton2.setTitle("追加",for: .normal)
        addDeviceButton2.titleLabel?.font = UIFont(name: "TimesNewRomanPSMT", size: wx/12)
        addDeviceButton2.setTitleColor(UIColor.white, for: .normal)
        addDeviceButton2.setTitleColor(UIColor.gray, for: .highlighted)
        addDeviceButton2.backgroundColor = UIColor.red
        addDeviceButton2.frame = CGRect(x:0,y:0,width:wx/3,height:wy/10)
        addDeviceButton2.layer.position = CGPoint(x:wx/5,y:wy/1.2)
        addDeviceButton2.tag = 4
        addDeviceButton2.layer.zPosition = 2
        addDeviceButton2.isHidden = true
        //addDevicebutton2.setImage(addDeviceImage, for: UIControlState.normal)
        addDeviceButton2.addTarget(self, action: #selector(childController.onclickbutton(sender:)), for: .touchUpInside)
        self.addWindow.addSubview(addDeviceButton2)
        
        
        closeButton.setTitle("閉じる",for: .normal)
        closeButton.titleLabel?.font = UIFont(name: "TimesNewRomanPSMT", size: wx/12)
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.setTitleColor(UIColor.gray, for: .highlighted)
        closeButton.backgroundColor = UIColor.red
        closeButton.frame = CGRect(x:0,y:0,width:wx/3,height:wy/10)
        closeButton.layer.position = CGPoint(x:wx/1.3,y:wy/1.2)
        closeButton.tag = 5
        closeButton.layer.zPosition = 2
        closeButton.isHidden = true
        //closeButton.setImage(addDeviceImage, for: UIControlState.normal)
        closeButton.addTarget(self, action: #selector(childController.onclickbutton(sender:)), for: .touchUpInside)
        self.addWindow.addSubview(closeButton)
        
        let menuImage = UIImage(named: "icons8-戻る-48.png")!.ResizeUIImage(width: x/10, height: x/10)
        
        returnButton.frame = CGRect(x:0,y:0,width:x/10,height:x/10)
        returnButton.layer.position = CGPoint(x:x/15,y:y/20)
        returnButton.tag = 6
        returnButton.layer.zPosition = 2
        returnButton.setImage(menuImage, for: UIControlState.normal)
        returnButton.addTarget(self, action: #selector(childController.onclickbutton(sender:)), for: .touchUpInside)
        self.view.addSubview(returnButton)
        
        databasePicker.frame = CGRect(x:wx/2 - wx/3,y:0,width:wx/1.5, height:wy/2)
        databasePicker.delegate = self
        databasePicker.dataSource = self
        databasePicker.layer.zPosition = 5
        self.addWindow.addSubview(databasePicker)
        
        databaseTextField = UITextField(frame: CGRect(x:0,y:0,width:wx/1.5,height:wy/15))
        if(arrayLength == 0){
            
            databaseTextField.text = ""
        }
        else{
            
            databaseTextField.text = dataArray[0] as? String
            pickerKey = keyArray[0] as! String
        }
        databaseTextField.layer.zPosition = 5
        databaseTextField.borderStyle = UITextBorderStyle.roundedRect
        databaseTextField.layer.position = CGPoint(x: wx/2,y: wy/2 + wy/8)
        databaseTextField.isEnabled = false
        self.addWindow.addSubview(databaseTextField)
        
        
        selectDeviceLabel = LTMorphingLabel(frame: CGRect(x: wx/2 - wx/5, y: wy/2, width: wx/1.5, height: wy/15))
        selectDeviceLabel.textColor = UIColor.black
        selectDeviceLabel.font = UIFont.systemFont(ofSize: wx/15)
        selectDeviceLabel.text = "追加する端末欄"
        selectDeviceLabel.textAlignment = NSTextAlignment.center
        self.addWindow.addSubview(selectDeviceLabel)
        
        // 探索ボタン
        ImgSearchStartButton1 = UIImage(named:"紛失モード（ボタン7）.png")
        ImgSearchStartButton2 = UIImage(named:"紛失モード（ボタン8）.png")
        ImgSearchStartButton3 = UIImage(named:"紛失モード（ボタン9）.png")
        
        ImgSearchStartButtonArray.append(ImgSearchStartButton1)
        ImgSearchStartButtonArray.append(ImgSearchStartButton2)
        ImgSearchStartButtonArray.append(ImgSearchStartButton3)
        ImgSearchStartButtonArray.append(ImgLastButton)
        
        BtnSearchStart = UIButton()
        BtnSearchStart.frame = CGRect(x:0,y:0,width:x/3,height:y/8)
        BtnSearchStart.setImage(ImgSearchStartButtonArray[0], for:.normal)
        BtnSearchStart.setImage(ImgSearchStartButtonArray[0], for:.highlighted)
        BtnSearchStart.layer.position = CGPoint(x:x/5,y:y/1.3)
        BtnSearchStart.tag = 2
        BtnSearchStart.addTarget(self, action: #selector(childController.onclickbutton(sender:)), for: .touchUpInside)
        
        BtnSearchStart.imageView?.animationImages = ImgSearchStartButtonArray
        BtnSearchStart.imageView?.animationDuration = 0.5
        BtnSearchStart.imageView?.animationRepeatCount = 1
        
        
        self.view.addSubview(BtnSearchStart)
        
        ImgSearchStopButton1 = UIImage(named:"紛失モード（ボタン10）.png")
        ImgSearchStopButton2 = UIImage(named:"紛失モード（ボタン11）.png")
        ImgSearchStopButton3 = UIImage(named:"紛失モード（ボタン12）.png")
        
        ImgSearchStopButtonArray.append(ImgSearchStopButton1)
        ImgSearchStopButtonArray.append(ImgSearchStopButton2)
        ImgSearchStopButtonArray.append(ImgSearchStopButton3)
        ImgSearchStopButtonArray.append(ImgLastButton)
        
        BtnSearchStop = UIButton()
        BtnSearchStop.frame = CGRect(x:0,y:0,width:x/3,height:y/8)
        BtnSearchStop.setImage(ImgSearchStopButtonArray[0], for:.normal)
        BtnSearchStop.setImage(ImgSearchStopButtonArray[0], for:.highlighted)
        BtnSearchStop.layer.position = CGPoint(x:x/5,y:y/1.3)
        BtnSearchStop.tag = 2
        BtnSearchStop.addTarget(self, action: #selector(childController.onclickbutton(sender:)), for: .touchUpInside)
        
        BtnSearchStop.imageView?.animationImages = ImgSearchStopButtonArray
        BtnSearchStop.imageView?.animationDuration = 0.5
        BtnSearchStop.imageView?.animationRepeatCount = 1
        
        self.view.addSubview(BtnSearchStop)
        
        BtnSearchStop.isHidden = true
        
        
        
        
        
        explainLabel = LTMorphingLabel(frame: CGRect(x: wx2/2 - wx2/2.5, y: wy2/10, width: wx2, height: wy2/8))
        explainLabel.textColor = UIColor.black
        explainLabel.font = UIFont.systemFont(ofSize: wx2/15)
        explainLabel.text = "接続キーを入力してください"
        explainLabel.textAlignment = NSTextAlignment.center
        self.connectWindow.addSubview(explainLabel)
        
        // connectWindow内の接続開始ボタン
        connectButton.setTitle("接続開始",for: .normal)
        connectButton.titleLabel?.font = UIFont(name: "TimesNewRomanPSMT", size: wx2/12)
        connectButton.setTitleColor(UIColor.white, for: .normal)
        connectButton.setTitleColor(UIColor.gray, for: .highlighted)
        connectButton.backgroundColor = UIColor.red
        connectButton.frame = CGRect(x:0,y:0,width:wx2/2.5,height:wy2/4)
        connectButton.layer.position = CGPoint(x:wx2/2,y:wy2/1.3)
        connectButton.tag = 7
        connectButton.layer.zPosition = 2
        //addDeviceButton.setImage(addDeviceImage, for: UIControlState.normal)
        connectButton.addTarget(self, action: #selector(childController.onclickbutton(sender:)), for: .touchUpInside)
        self.connectWindow.addSubview(connectButton)
        
        
        ImgViewConnectionState = UIImageView()
        ImgViewConnectionState.frame = CGRect(x: x/2 - x/3, y: y/20, width: x/1.5, height: y/20)
        ImgConnectionState = UIImage(named:"紛失モード（ネームプレート）.png")
        ImgViewConnectionState.image = ImgConnectionState
        self.view.addSubview(ImgViewConnectionState)
        connectionLabel = LTMorphingLabel(frame: CGRect(x: x/2 - x/12, y: y/20, width: x, height: y/20))
        connectionLabel.textColor = UIColor.black
        connectionLabel.font = UIFont.systemFont(ofSize: x/20)
        connectionLabel.text = "未接続"
        connectionLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(connectionLabel)
        
        // UITextFieldを作成する
        connectTextField = UITextField(frame: CGRect(x: wx2/2 - wx2/2.5, y: wy2/4, width: wx2/1.3, height: wy2/6))
        connectTextField.placeholder = "15文字以内の半角英字"
        connectTextField.delegate = self
        connectTextField.borderStyle = .roundedRect
        connectTextField.clearButtonMode = .whileEditing
        self.connectWindow.addSubview(connectTextField)
    }
    
    
    
    func onclickbutton(sender:UIButton){
    
        // addDeviceButton(端末追加ボタン)
        if(sender.tag == 1){
            
            if(arrayLength > 0){
                
                if(appDelegate.addButtonM == true){
                    
                    addWindow.isHidden = false
                    addWindow.layer.position = CGPoint(x: x/2, y: y/2)
                    
                    // アニメーション
                    UIWindow.animate(withDuration: 1.0, delay: 0.0, options: . curveEaseIn, animations: {
                        self.addWindow.alpha = 1.0
                    }, completion: nil)
                    
                    self.deviceListTableView.allowsSelection = false
                    addDeviceButton.isEnabled = false
                    addDeviceButton.alpha = 0.2
                    CallOutBtn.isEnabled = false
                    CallOutBtn.alpha = 0.2
                    addDeviceButton2.isHidden = false
                    closeButton.isHidden = false
                    returnButton.alpha = 0.2
                    returnButton.isEnabled = false
                    BtnAdd.imageView?.startAnimating()
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
                        
                        
                    }) { _ in
                        
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.BtnLost.isHidden = false
                        self.BtnAdd.isHidden = true
                    }
                    
                    appDelegate.addButtonM = false
                }
                else{
                    
                    addWindow.alpha = 1.0
                    UIWindow.animate(withDuration: 1.0, delay: 0, options: [.curveEaseIn], animations: {
                        self.addWindow.alpha = 0
                    }, completion: nil)
                    
                    self.deviceListTableView.allowsSelection = true
                    addDeviceButton.isEnabled = true
                    addDeviceButton.alpha = 1
                    CallOutBtn.isEnabled = true
                    CallOutBtn.alpha = 1
                    closeButton.isEnabled = true
                    closeButton.alpha = 1
                    returnButton.isEnabled = true
                    returnButton.alpha = 1
                    
                    BtnAdd.imageView?.startAnimating()
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
                        
                        
                    }) { _ in
                        
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.BtnLost.isHidden = true
                        self.BtnAdd.isHidden = false
                    }
                    
                    appDelegate.addButtonM = true
                }
            }
            else{
                /************************** alertView *************************/
                let alert:UIAlertView? = UIAlertView(title: "端末がありません",message: "設定から端末を登録してください", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                alert?.show()
            }
            
        }
        
        // CallOutBtn(発信ボタン)
        if(sender.tag == 2){
            
            
            if(appDelegate.dispatchBool == true){
                
                BtnSearchStart.imageView?.startAnimating()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.BtnSearchStop.isHidden = false
                    self.BtnSearchStart.isHidden = true
                }
                
                
                // 発信開始
                appDelegate.childPheripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                appDelegate.dispatchBool = false
            }
            else{
                
                BtnSearchStop.imageView?.startAnimating()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.BtnSearchStop.isHidden = true
                    self.BtnSearchStart.isHidden = false
                }
                
                appDelegate.childPheripheralManager.stopAdvertising()
                
                appDelegate.dispatchBool = true
            }
            
            /******************************* 発信について *******************************/
            
        
        }
        
        if(sender.tag == 3){
            
            if(appDelegate.connectW == true){
                
                bleButton.setTitle("閉じる",for: .normal)
                connectWindow.isHidden = false
                connectWindow.layer.position = CGPoint(x: x/2, y: y/2)
                
                // アニメーション
                UIWindow.animate(withDuration: 1.0, delay: 0.0, options: . curveEaseIn, animations: {
                    self.connectWindow.alpha = 1.0
                }, completion: nil)
                
                self.deviceListTableView.allowsSelection = false
                addDeviceButton.isEnabled = false
                addDeviceButton.alpha = 0.2
                CallOutBtn.isEnabled = false
                CallOutBtn.alpha = 0.2
                addDeviceButton2.isHidden = false
                closeButton.isHidden = false
                returnButton.alpha = 0.2
                returnButton.isEnabled = false
                
                BtnConnectionStart.imageView?.startAnimating()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.BtnConnectionStop.isHidden = false
                    self.BtnConnectionStart.isHidden = true
                }
                
                appDelegate.connectW = false
                
            }
            else{
                
                bleButton.setTitle("接続開始",for: .normal)
                connectWindow.alpha = 1.0
                UIWindow.animate(withDuration: 1.0, delay: 0, options: [.curveEaseIn], animations: {
                    self.connectWindow.alpha = 0
                }, completion: nil)
                
                
                BtnConnectionStop.imageView?.startAnimating()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.BtnConnectionStop.isHidden = true
                    self.BtnConnectionStart.isHidden = false
                }
                
                self.deviceListTableView.allowsSelection = true
                addDeviceButton.isEnabled = true
                addDeviceButton.alpha = 1
                CallOutBtn.isEnabled = true
                CallOutBtn.alpha = 1
                closeButton.isEnabled = true
                closeButton.alpha = 1
                returnButton.isEnabled = true
                returnButton.alpha = 1
                appDelegate.connectW = true
            }
            
            
        }
        
        // addDeviceButton2(端末追加ボタン「addWindow」)
        if(sender.tag == 4) {
            
            var sameNameNo = false
            
            let str = databaseTextField.text!
            
            let db = FMDatabase(path: DatabaseClass().table)
            
            let db2 = FMDatabase(path: DatabaseClass().table8)
            
            let sql = "INSERT INTO device (name) VALUES (?);"
            let sql2 = "SELECT * FROM device"
            let sql3 = "INSERT INTO device8 (name) VALUES (?);"
            
            db?.open()
            db2?.open()
            
            
            let results = db?.executeQuery(sql2, withArgumentsIn: nil)
            
            while (results?.next())! {
                
                // カラム名を指定して値を取得する方法
                let user_id = results?.int(forColumn: "user_id")
                
                // カラムのインデックスを指定して取得する方法
                let user_name = results?.string(forColumnIndex: 1)
                
                if(user_name! == str){
                    sameNameNo = true
                }
                
            }
            
            db?.close()
            
            
            
            if(sameNameNo == true){
                
                let alert:UIAlertView? = UIAlertView(title: "追加できません",message: "同じ名前の人の端末は追加できません", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                alert?.show()
                
            }
            else{
                
                let alert:UIAlertView? = UIAlertView(title: "追加しました",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                alert?.show()
                
                db?.open()
                
                // ?で記述したパラメータの値を渡す場合
                db?.executeUpdate(sql, withArgumentsIn: [str])
                db2?.executeUpdate(sql3, withArgumentsIn: [pickerKey])
                // deviceListに追加
                deviceList.add(str)
                distanceArray.add("未接続")
                deviceListTableView.reloadData()
            }
            
            db?.close()
            db2?.close()
            
        }
        
        // closeButton(addWindowを閉じるボタン)
        if(sender.tag == 5){
            
            appDelegate.addButtonM = true
            addWindow.alpha = 1.0
            UIWindow.animate(withDuration: 1.0, delay: 0, options: [.curveEaseIn], animations: {
                self.addWindow.alpha = 0
            }, completion: nil)
            
            self.deviceListTableView.allowsSelection = true
            addDeviceButton.isEnabled = true
            addDeviceButton.alpha = 1
            CallOutBtn.isEnabled = true
            CallOutBtn.alpha = 1
            closeButton.isEnabled = true
            closeButton.alpha = 1
            returnButton.isEnabled = true
            returnButton.alpha = 1
            
            BtnAdd.imageView?.startAnimating()
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
                
                
            }) { _ in
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.BtnLost.isHidden = true
                self.BtnAdd.isHidden = false
            }
        }
        
        // 戻るボタン
        if(sender.tag == 6){
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        // connectWindow内の接続開始ボタン
        if(sender.tag == 7){
            
             if(appDelegate.ble1 == true){
                
                if(connectServiceType != ""){
                    
                    
                    self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: connectServiceType)
                    self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: connectServiceType)
                    
                    self.serviceAdvertiser.delegate = self
                    
                    self.serviceBrowser.delegate = self
                    
                    
                    // 探索開始
                    self.serviceAdvertiser.startAdvertisingPeer()
                    
                    self.serviceBrowser.startBrowsingForPeers()
                    
                    connectButton.setTitle("接続停止",for: .normal)
                    
                    appDelegate.ble1 = false
                    
                }
                
             }
             else{
                
                self.serviceAdvertiser.stopAdvertisingPeer()
                
                self.serviceBrowser.stopBrowsingForPeers()
                
                connectButton.setTitle("接続開始",for: .normal)
             
                appDelegate.ble1 = true
             }
        }
    }
    
    // アラートを表示する
    func alertFunc(title : String, message : String){
        
        let alertController = UIAlertController(title: title,message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "探す", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            
        }
        let cancelButton = UIAlertAction(title: "探さない", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertController.addAction(okAction)
        
        alertController.addAction(cancelButton)
        
        present(alertController,animated: true,completion: nil)
    }
    
    // Cellが選択された際に呼び出される
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // Cellの総数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    // Cellに値を設定する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 再利用するCellを取得する(左にtextLabel、右にdetailLabelを表示するstyleにしている)
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "MyCell")
        
        cell.textLabel!.text = "\(deviceList[indexPath.row])"
        
        cell.detailTextLabel?.text = "\(distanceArray[indexPath.row])"
        
        cell.detailTextLabel?.textColor = cellColor
        
        
        cell.textLabel!.font = UIFont(name: "Arial", size: x/20)
        
        // 矢印マークをつける
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    
    // Cellを挿入または削除しようとした際に呼び出される
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        var value : Int32!
        var value2 : Int32!
        
        // 削除のとき.
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let db = FMDatabase(path: DatabaseClass().table)
            let db2 = FMDatabase(path: DatabaseClass().table8)
            
            let sql = "SELECT * FROM device"
            let sql2 = "SELECT * FROM device8"
            
            db?.open()
            db2?.open()
            
            let results = db?.executeQuery(sql, withArgumentsIn: nil)
            let results2 = db2?.executeQuery(sql2, withArgumentsIn: nil)
            
            while (results?.next())! {
                
                // カラム名を指定して値を取得する方法
                let user_id = results?.int(forColumn: "user_id")
                
                // カラムのインデックスを指定して取得する方法
                let user_name = results?.string(forColumnIndex: 1)
                
                if(user_name! == String(describing: deviceList[indexPath.row])){
                    value = user_id!
                }
                
            }
            
            while (results2?.next())! {
                
                // カラム名を指定して値を取得する方法
                let user_id = results2?.int(forColumn: "user_id")
                
                // カラムのインデックスを指定して取得する方法
                let user_name = results2?.string(forColumnIndex: 1)
                
                if(user_name! == String(describing: keyArray[indexPath.row])){
                    value2 = user_id!
                }
                
            }
            
            
            db?.close()
            db2?.close()
            
            //リムーブ処理
            let sqll = "DELETE FROM device WHERE user_id = ?"
            let sqll2 = "DELETE FROM device8 WHERE user_id = ?"
            
            db?.open()
            db2?.open()
            db?.executeUpdate(sqll, withArgumentsIn: [value])
            db2?.executeUpdate(sqll2, withArgumentsIn: [value2])
            db?.close()
            db2?.close()
            //選択したセルの内容と保存してある内容が一致した場合のIDを削除するようにしてる
            
            // 指定されたセルのオブジェクトをmyItemsから削除する.
            deviceList.removeObject(at: indexPath.row)
            
            // TableViewを再読み込み.
            deviceListTableView.reloadData()
        }
        
    }
    
    
    // 発信メソッドのデリゲートメソッド
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        switch peripheral.state {
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        case .unsupported:
            print("Unsupported")
        case .unauthorized:
            print("Unauthorized")
        case .poweredOff:
            print("PoweredOff")
            
        // BluetoothがONになった時
        case .poweredOn:
            print("PoweredOn")
            
            // iBeaconのUUID（ターミナルで生成したもの）
            let myProximityUUID = NSUUID(uuidString: "9FE2136F-DEEF-4A17-A399-186F55E74B3E")
            
            // iBeaconのIdentifier。同じの端末と繋ぐ
            let myIdentifier = "sample-beacon"
            
            // Major.
            let myMajor : CLBeaconMajorValue = 1
            
            // Minor.
            let myMinor : CLBeaconMinorValue = 1
            
            // BeaconRegionを定義.
            let myBeaconRegion = CLBeaconRegion(proximityUUID: myProximityUUID! as UUID, major: myMajor, minor: myMinor, identifier: myIdentifier)
            
            // Advertisingのフォーマットを作成.
            let myBeaconPeripheralData = NSDictionary(dictionary: myBeaconRegion.peripheralData(withMeasuredPower: nil))
            
            // Advertisingを発信.
            appDelegate.childPheripheralManager.startAdvertising(myBeaconPeripheralData as? [String : Any])
            print("myBeaconPeripheralData = \(myBeaconPeripheralData)")
        }
        
    }
    // 通知！！！
    func sendLocalNotificationForMessage(message: NSString!) {
        
        // Notificationを生成.
        let content = UNMutableNotificationContent()
        
        // Titleを代入する.
        content.title = "通知"
        
        // Bodyを代入する.
        content.body = message! as String
        
        // 音を設定する.
        content.sound = UNNotificationSound.default()
        
        // Requestを生成する.
        let request = UNNotificationRequest.init(identifier: "Title1", content: content, trigger: nil)
        
        // Noticationを発行する.
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print("error = \(String(describing: error))")
        }
    }
    
    //表示列
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //表示個数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    
    //表示内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataArray[row] as? String
    }
    
    //選択時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if(dataArray[row] as? String != nil){
            
            databaseTextField.text = dataArray[row] as? String
            pickerKey = keyArray[row] as! String
            
        }
    }
    
    
    
    // UITextFieldが編集された直前に呼ばれる
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    // UITextFieldが編集された直後に呼ばれる
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        
        // textFieldの値が空なら
        if(connectTextField.text == ""){
            
            
            let alert: UIAlertView? = UIAlertView(title: "入力してください",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
            alert?.show()
            
        }
            // textFieldの値が空じゃないなら
        else if(connectTextField.text != ""){
            
            
            // identifierTextFieldのtextをitext変数に代入
            let itext : String = connectTextField.text!
            
            // 半角英字のみなら
            if itext.isValidNickName {
                
                // 15文字以下なら
                if(itext.characters.count <= 15){
                    
                    connectServiceType = connectTextField.text!
                }
                    
                else{
                    
                    let alert: UIAlertView? = UIAlertView(title: "15文字以内で入力してください",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                    alert?.show()
                    
                    connectTextField.text = ""
                }
            }
                
                
                // 全角が含まれているなら
            else {
                
                // 15文字以上なら
                if(itext.characters.count > 15){
                    
                    let alert: UIAlertView? = UIAlertView(title: "15文字以内で入力してください",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                    alert?.show()
                    
                    connectTextField.text = ""
                }
                    
                else{
                    
                    let alert: UIAlertView? = UIAlertView(title: "半角英字のみで入力してください",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                    alert?.show()
                    
                    connectTextField.text = ""
                }
                
                
            }
            
            
        }
    }
    
    
    // 改行ボタンが押された際に呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        // 改行ボタンが押されたらKeyboardを閉じる処理.
        textField.resignFirstResponder()
        
        return true
    }

    
    
    //UIntに16進で数値をいれるとUIColorが戻る関数
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    // 接続されている端末が変わったら呼び出される
    func connectedDevicesChanged(connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            
            // 接続台数が１台以上の時に読み込まれる
            if(connectedDevices.count > 0){
                
                self.connectionLabel.layer.position = CGPoint(x:self.x/2, y:self.y/14)
                self.connectionLabel.text = "接続台数 : \(connectedDevices.count)台"
            }
            else{
                
                self.connectionLabel.text = "未接続"
            }
        }
    }
    
    
    // 受け取るメソッド
    func change(message : String) {
        
        // まず接続キーを切り取る
        var str : String? = message
        let startIndex = str!.index(str!.startIndex, offsetBy: 0)
        let endIndex = str!.characters.index(of:"@")
        let range = startIndex..<endIndex!
        let connectKey = str!.substring(with:range)
        
        
        // 距離を切り取る
        str!.removeSubrange(range)
        let index = str!.index(str!.startIndex, offsetBy:0)
        str!.remove(at:index)
        let distance = Double(str!)
        
        var text : String!
        
        if(distance! >= 1000) {
            
            text = "離れすぎています"
            cellColor = UIColor.darkGray
        }
        else if(distance! < 1000 && distance! >= 700){
        
            text = "すごく遠いです"
            cellColor = UIColor.blue
        }
        else if(distance! < 700 && distance! >= 500){
        
            text = "まあまあ遠いです"
            cellColor = UIColor.green
        }
        else if(distance! < 500 && distance! >= 300){
        
            text = "少し遠いです"
            cellColor = UIColor.yellow
        }
        else if(distance! < 300 && distance! >= 100){
        
            text = "少し近いです"
            cellColor = UIColor.orange
        }
        else if(distance! < 100 && distance! >= 0){
            
            cellColor = UIColor.red
            if(distance! > 80){
            
                text = "近いです"
            }
            else if(distance! > 60){
            
                text = "結構近いです！"
            }
            else if(distance! > 40){
            
                text = "すごく近いです！！"
            }
            else if(distance! > 20){
                
                text = "めちゃくちゃ近いです！！！"
            }
            else{
            
                text = "もう目の前にいます！！！"
            }
            
            
        }
        else{
            
            text = "接続ができていません"
            cellColor = UIColor.black
            
        }
        
        
        for i in 0..<saveConnectArray.count {
            
            if(saveConnectArray[i] as! String == connectKey){
                
                // 接続キーが同じの人のテーブルリストの値を更新する
                distanceArray[i] = text
                deviceListTableView.reloadData()
            }
        }
        
        
    }
    
    // 受信する関数
    func receveMessage(deviceString: String) {
        OperationQueue.main.addOperation {
            
            self.change(message: deviceString)
            
        }
    }
    
    
    // 送信するメソッド
    func send(message : String) {
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(message.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
                
            }
            catch let error {
                NSLog("error: \(error)")
            }
        }
        
    }
    
    /****************************** advertiser ******************************/
    //アドバタイズが開始できなかった場合に呼ばれる，エラー処理をここに書く
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("アドバタイズが開始できなかった: \(error)")
    }
    
    //他端末から招待を受けた時に呼ばれる(実装必須)
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("他端末から招待を受けた \(peerID)")
        
        //招待への返答(true/false)
        invitationHandler(true, self.session)
    }
    
    /****************************** brower ******************************/
    //探索を開始出来ない場合に呼ばれる，エラー処理を書いても良し！
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("探索が開始できない : \(error)")
    }
    
    //他端末の発見時に呼ばれる
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("見つけたpeerID: \(peerID)")
        NSLog("招待されたpeerID: \(peerID)")
        
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    //端末を見失った時に呼ばれる
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("端末を見失った: \(peerID)")
    }
    
    /****************************** session ******************************/
    // 近くのピアの状態が変更されたときに呼び出されます。
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        connectedDevicesChanged(connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    // データを受信した際に呼ばれる関数
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let str = String(data: data, encoding: .utf8)!
        receveMessage(deviceString: str)
    }
    
    // 近くのピアがローカルピアへのバイトストリーム接続を開くときに呼び出されます。
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("didReceiveStream")
    }
    
    // ローカルピアが近隣のピアからリソースを受信し始めたことを示します。
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("didStartReceivingResourceWithName")
    }
    
    // ローカルピアが近くのピアからリソースを受信し終わったことを示します。
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("didFinishReceivingResourceWithName")
    }
    
}











// 受信側
class childController2 : UIViewController, CLLocationManagerDelegate, UIAlertViewDelegate, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, UITextFieldDelegate {
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // viewの長さを入れる変数
    var x : CGFloat!
    var y : CGFloat!
    
    var wx : CGFloat!
    var wy : CGFloat!
    
    var arrayLength: Int = 0
    
    let userDefaults = UserDefaults.standard
    
    /******************************* iBeacon関連 *******************************/
    var locationManager:CLLocationManager?
    var proximityUUID:NSUUID?
    var beaconRegion:CLBeaconRegion?
    var nearestBeacon:CLBeacon?
    var str:NSString?
    
    /******************************* bluetooth関連 *******************************/
    
    // serviceType(接続キー)の値を設定
    var connectServiceType = ""
    
    var myPeerId: MCPeerID!
    
    var serviceAdvertiser : MCNearbyServiceAdvertiser!
    var serviceBrowser : MCNearbyServiceBrowser!
    
    var session : MCSession!
    
    var distanceLabel : LTMorphingLabel!
    var explainLabel : LTMorphingLabel!
    
    var bluetoothButton = ZFRippleButton()
    var returnButton = ZFRippleButton()
    
    var connectTextField: UITextField!
    
    // 背景
    var ImgChildBackground : UIImage!
    var ImgViewChildBackground : UIImageView!
    
    var ImgViewConnectionState : UIImageView!
    var ImgConnectionState : UIImage!
    
    
    // 接続ボタンについて
    var ImgConnectionStartButton1 : UIImage!
    var ImgConnectionStartButton2 : UIImage!
    var ImgConnectionStartButton3 : UIImage!
    var ImgConnectionStartButtonArray :Array<UIImage> = []
    var BtnConnectionStart : UIButton!
    
    var ImgConnectionStopButton1 : UIImage!
    var ImgConnectionStopButton2 : UIImage!
    var ImgConnectionStopButton3 : UIImage!
    var ImgConnectionStopButtonArray :Array<UIImage> = []
    var BtnConnectionStop : UIButton!
    
    var ImgLastButton : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        x = self.view.frame.width
        y = self.view.frame.height
        
        self.view.backgroundColor = UIColor.white
        
        myPeerId = MCPeerID(displayName: UIDevice.current.name)
        
        session = {
            let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
            session.delegate = self
            return session
        }()
        
        ImgLastButton = UIImage(named:"紛失モード（ボタン）.png")
        
        ImgChildBackground = UIImage(named:"迷子モード（その他の背景）.png")
        ImgViewChildBackground = UIImageView()
        ImgViewChildBackground.frame = CGRect(x:0,y:0,width:self.view.bounds.width,height:self.view.bounds.height)
        ImgViewChildBackground.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/2)
        ImgViewChildBackground.image = ImgChildBackground
        self.view.addSubview(ImgViewChildBackground)
        
        
        ImgViewConnectionState = UIImageView()
        ImgViewConnectionState.frame = CGRect(x: x/2 - x/3, y: y/3, width: x/1.5, height: y/15)
        ImgConnectionState = UIImage(named:"紛失モード（ネームプレート）.png")
        ImgViewConnectionState.image = ImgConnectionState
        self.view.addSubview(ImgViewConnectionState)
        
        distanceLabel = LTMorphingLabel(frame: CGRect(x: x/2 - x/12, y: y/3, width: x, height: y/15))
        distanceLabel.textColor = UIColor.black
        distanceLabel.font = UIFont.systemFont(ofSize: x/20)
        distanceLabel.text = "未接続"
        distanceLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(distanceLabel)
        
        
        
        locationManager = CLLocationManager() // インスタンスの生成
        locationManager?.delegate = self // CLLocationManagerDelegateプロトコルを実装するクラスを指定する
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        let status = CLLocationManager.authorizationStatus()
        
        let appStatus = UIApplication.shared.applicationState
        let isBackground = appStatus == .background || appStatus == .inactive
        if isBackground {
            print("バックグラウンドで位置情報を更新するようにする!")
            locationManager?.startUpdatingLocation()
        }
        if status == CLAuthorizationStatus.notDetermined {
            print("didChangeAuthorizationStatus:\(status)");
            // まだ承認が得られていない場合は、認証ダイアログを表示
            //locationManager.requestWhenInUseAuthorization()
            locationManager?.requestAlwaysAuthorization()
        }
        
        if(CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)) {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            
            // 取得制度を最高にする！！！
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            
            // 取得頻度の設定.(1mごとに位置情報取得)
            self.locationManager?.distanceFilter = 1
            
            // UUIDの指定
            self.proximityUUID = NSUUID(uuidString: "9FE2136F-DEEF-4A17-A399-186F55E74B3E")
            
            self.beaconRegion = CLBeaconRegion(proximityUUID: self.proximityUUID! as UUID, major: CLBeaconMajorValue(1), minor: CLBeaconMinorValue(1), identifier: "sample-beacon")
            self.beaconRegion?.notifyOnEntry = true
            
            // 退域通知の設定.
            self.beaconRegion?.notifyOnExit = true
            
            let status = CLLocationManager.authorizationStatus()
            if status == CLAuthorizationStatus.notDetermined {
                self.locationManager?.requestAlwaysAuthorization()
            } else {
                
                // 指定された領域の監視を開始します
                self.locationManager?.startMonitoring(for: self.beaconRegion!)
                
                //print("監視を開始")
            }
        } else {
            print("iBeaconを使用できない")
            let alert:UIAlertView? = UIAlertView(title: "確認",message: "お使いの端末ではiBeaconを利用できません。", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "OK")
            alert?.show()
        }
        
        
        // 接続ボタン
        
        ImgConnectionStartButton1 = UIImage(named:"迷子モード（接続1）.png")
        ImgConnectionStartButton2 = UIImage(named:"迷子モード（接続2）.png")
        ImgConnectionStartButton3 = UIImage(named:"迷子モード（接続3）.png")
        
        ImgConnectionStartButtonArray.append(ImgConnectionStartButton1)
        ImgConnectionStartButtonArray.append(ImgConnectionStartButton2)
        ImgConnectionStartButtonArray.append(ImgConnectionStartButton3)
        ImgConnectionStartButtonArray.append(ImgLastButton)
        
        BtnConnectionStart = UIButton()
        BtnConnectionStart.frame = CGRect(x:0,y:0,width:x/2,height:y/8)
        BtnConnectionStart.setImage(ImgConnectionStartButtonArray[0], for:.normal)
        BtnConnectionStart.setImage(ImgConnectionStartButtonArray[0], for:.highlighted)
        BtnConnectionStart.layer.position = CGPoint(x:x/2,y:y/2 + y/6)
        BtnConnectionStart.tag = 2
        BtnConnectionStart.addTarget(self, action: #selector(childController2.onclickbutton(sender:)), for: .touchUpInside)
        
        BtnConnectionStart.imageView?.animationImages = ImgConnectionStartButtonArray
        BtnConnectionStart.imageView?.animationDuration = 0.5
        BtnConnectionStart.imageView?.animationRepeatCount = 1
        
        
        self.view.addSubview(BtnConnectionStart)
        
        ImgConnectionStopButton1 = UIImage(named:"迷子モード（閉じる１）.png")
        ImgConnectionStopButton2 = UIImage(named:"迷子モード（閉じる２）.png")
        ImgConnectionStopButton3 = UIImage(named:"迷子モード（閉じる３）.png")
        
        ImgConnectionStopButtonArray.append(ImgConnectionStopButton1)
        ImgConnectionStopButtonArray.append(ImgConnectionStopButton2)
        ImgConnectionStopButtonArray.append(ImgConnectionStopButton3)
        ImgConnectionStopButtonArray.append(ImgLastButton)
        
        BtnConnectionStop = UIButton()
        BtnConnectionStop.frame = CGRect(x:0,y:0,width:x/2,height:y/8)
        BtnConnectionStop.setImage(ImgConnectionStopButtonArray[0], for:.normal)
        BtnConnectionStop.setImage(ImgConnectionStopButtonArray[0], for:.highlighted)
        BtnConnectionStop.layer.position = CGPoint(x:x/2,y:y/2 + y/6)
        BtnConnectionStop.tag = 2
        BtnConnectionStop.addTarget(self, action: #selector(childController2.onclickbutton(sender:)), for: .touchUpInside)
        
        BtnConnectionStop.imageView?.animationImages = ImgConnectionStopButtonArray
        BtnConnectionStop.imageView?.animationDuration = 0.5
        BtnConnectionStop.imageView?.animationRepeatCount = 1
        
        self.view.addSubview(BtnConnectionStop)
        
        BtnConnectionStop.isHidden = true

        
        let menuImage = UIImage(named: "icons8-戻る-48.png")!.ResizeUIImage(width: x/10, height: x/10)
        
        returnButton.frame = CGRect(x:0,y:0,width:x/10,height:x/10)
        returnButton.layer.position = CGPoint(x:x/15,y:y/20)
        returnButton.tag = 3
        returnButton.layer.zPosition = 2
        returnButton.setImage(menuImage, for: UIControlState.normal)
        returnButton.addTarget(self, action: #selector(childController.onclickbutton(sender:)), for: .touchUpInside)
        self.view.addSubview(returnButton)
        
        explainLabel = LTMorphingLabel(frame: CGRect(x: x/2 - x/3, y: y/2 - y/10, width: x/1.5, height: y/8))
        explainLabel.textColor = UIColor.white
        explainLabel.font = UIFont.systemFont(ofSize: x/20)
        explainLabel.text = "接続キーを入力してください"
        explainLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(explainLabel)
        
        // UITextFieldを作成する.
        connectTextField = UITextField(frame: CGRect(x: x/2 - x/2.5, y: y/2, width: x/1.3, height: y/15))
        connectTextField.placeholder = "15文字以内の半角英字で入力"
        connectTextField.delegate = self
        connectTextField.borderStyle = .roundedRect
        connectTextField.clearButtonMode = .whileEditing
        self.view.addSubview(connectTextField)
    }
    
    
    func onclickbutton(sender:UIButton){
        
        // bluetooth接続開始ボタン
        if(sender.tag == 2){
            
            if(appDelegate.ble2 == true){
                
                if(connectServiceType != ""){
                    
                    print("bluetooth開始 = \(connectServiceType)")
                    
                    BtnConnectionStart.imageView?.startAnimating()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.BtnConnectionStop.isHidden = false
                        self.BtnConnectionStart.isHidden = true
                    }
                    
                    self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: connectServiceType)
                    
                    self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: connectServiceType)
                    
                    
                    self.serviceAdvertiser.delegate = self
                    
                    self.serviceBrowser.delegate = self
                    
                    serviceAdvertiser.startAdvertisingPeer()
                    
                    serviceBrowser.startBrowsingForPeers()
                    
                    bluetoothButton.setTitle("接続停止",for: .normal)
                    
                    appDelegate.ble2 = false
                }
                
            }
            else{
                print("bluetooth切断")
                
                BtnConnectionStop.imageView?.startAnimating()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.BtnConnectionStop.isHidden = true
                    self.BtnConnectionStart.isHidden = false
                }
                
                serviceAdvertiser.stopAdvertisingPeer()
                
                serviceBrowser.stopBrowsingForPeers()
                
                bluetoothButton.setTitle("接続開始",for: .normal)
                
                appDelegate.ble2 = true
            }
            
        }
        
        if(sender.tag == 3){
            
            
            self.dismiss(animated: true, completion: nil)
            
            locationManager?.stopMonitoring(for: self.beaconRegion!)
        }
    }
    
    
    
    // UITextFieldが編集された直前に呼ばれる
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing: \(textField.text!)")
    }
    
    // UITextFieldが編集された直後に呼ばれる
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing: \(textField.text!)")
        
        
        // textFieldの値が空なら
        if(connectTextField.text == ""){
            
            
            let alert: UIAlertView? = UIAlertView(title: "入力してください",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
            alert?.show()
            
        }
            // textFieldの値が空じゃないなら
        else if(connectTextField.text != ""){
            
            
            // identifierTextFieldのtextをitext変数に代入
            let itext : String = connectTextField.text!
            
            // 半角英字のみなら
            if itext.isValidNickName {
                
                // 15文字以下なら
                if(itext.characters.count <= 15){
                    
                    connectServiceType = connectTextField.text!
                }
                
                else{
                    
                    let alert: UIAlertView? = UIAlertView(title: "15文字以内で入力してください",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                    alert?.show()
                    
                    connectTextField.text = ""
                }
            }
                
                
            // 全角が含まれているなら
            else {
                
                // 15文字以上なら
                if(itext.characters.count > 15){
                    
                    let alert: UIAlertView? = UIAlertView(title: "15文字以内で入力してください",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                    alert?.show()
                    
                    connectTextField.text = ""
                }
                
                else{
                    
                    let alert: UIAlertView? = UIAlertView(title: "半角英字のみで入力してください",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                    alert?.show()
                    
                    connectTextField.text = ""
                }
                
                
            }
            
            
        }
    }
    
    
    // 改行ボタンが押された際に呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn \(textField.text!)")
        
        // 改行ボタンが押されたらKeyboardを閉じる処理.
        textField.resignFirstResponder()
        
        return true
    }

    
    // 受け取るメソッド
    func change(message : String) {
        
        
    }
    
    // 接続されている端末が変わったら呼び出される
    func connectedDevicesChanged(connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            
            // 接続台数が１台以上の時に読み込まれる
            if(connectedDevices.count > 0){
                
                self.distanceLabel.text = "接続中"
                self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2.7)
            }
            else{
                
                self.distanceLabel.text = "未接続"
                self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2.7)
            }
        }
    }
    
    // 受信する関数
    func receveToken(deviceString: String) {
        OperationQueue.main.addOperation {
            self.change(message: deviceString)
            
        }
    }
    
    
    // 送信するメソッド
    func send(message : String) {
        NSLog("%@", "sendColor: \(message) to \(session.connectedPeers.count) peers")
        
        // このセッションに現在接続しているすべてのピアの配列の数が０以上なら条件に入る
        if session.connectedPeers.count > 0 {
            do {
                /* NSDataオブジェクトにカプセル化(オブジェクトの内部のデータ、振る舞い、
                 実際の型を隠蔽(隠す))されたメッセージを近くのピアに送信します。 */
                try self.session.send(message.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
                
                // data : 送信するメッセージを含むオブジェクト。
                // toPeers : メッセージを受け取るべきピアを表すピアIDオブジェクトの配列。
                // with(mode) : 使用する伝送モード（信頼性の高いまたは信頼できない配信）。
                
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
        
    }
    
    
    /****************************** advertiser ******************************/
    //アドバタイズが開始できなかった場合に呼ばれる，エラー処理をここに書く
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    //他端末から招待を受けた時に呼ばれる(実装必須)
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        
        //招待への返答(true/false)
        invitationHandler(true, self.session)
    }
    
    /****************************** brower ******************************/
    //探索を開始出来ない場合に呼ばれる，エラー処理を書いても良し！
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "探索が開始できない : \(error)")
    }
    
    //他端末の発見時に呼ばれる
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "見つけたpeerID: \(peerID)")
        NSLog("%@", "招待されたpeerID: \(peerID)")
        
        // peerID : 招待する端末のMCPeerIDを渡す
        // toSession : どのSessionに対して招待を行うかを，先に作っておいたMCSessionのインスタンスを渡すことで知らせます
        // withContext : 相手に対して追加で提示する情報
        // timeout : 招待に対して返答がなかった場合，タイムアウトする時間の長さの設定
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    //端末を見失った時に呼ばれる
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "端末を見失った: \(peerID)")
    }
    
    
    /****************************** session ******************************/
    // 近くのピアの状態が変更されたときに呼び出されます。
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state)")
        connectedDevicesChanged(connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    // データを受信した際に呼ばれる関数
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let str = String(data: data, encoding: .utf8)!
        
        receveToken(deviceString: str)
    }
    
    // 近くのピアがローカルピアへのバイトストリーム接続を開くときに呼び出されます。
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    // ローカルピアが近隣のピアからリソースを受信し始めたことを示します。
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    // ローカルピアが近くのピアからリソースを受信し終わったことを示します。
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    
    // 領域観測が開始した場合
    func locationManager(_ manager: CLLocationManager!, didStartMonitoringFor region: CLRegion!) {
        
    }
    
    // 領域に侵入した場合
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if(region is CLBeaconRegion && CLLocationManager.isRangingAvailable()) {
            
            self.locationManager?.startRangingBeacons(in: region as! CLBeaconRegion)
        }
    }
    
    // 領域から退出した場合
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        if(region is CLBeaconRegion && CLLocationManager.isRangingAvailable()) {
            self.locationManager?.stopRangingBeacons(in: region as! CLBeaconRegion)
            
            distanceLabel.text = "未接続"
            self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2.7)
        }
    }
    
    // 領域内にいるかどうかの判断
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        switch(state) {
        case .inside:
            if(region is CLBeaconRegion && CLLocationManager.isRangingAvailable()) {
                
                self.locationManager?.startRangingBeacons(in: region as! CLBeaconRegion)
                
            }
            break
        case .outside:
            print("領域の外にいる")
            distanceLabel.text = "未接続"
            break
        case .unknown:
            print("え...?")
            break
        default:
            break
        }
    }
    
    // 距離計測
    func locationManager(_ manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        
        
        if(beacons.count > 0) {
            
            self.nearestBeacon = beacons[0] as? CLBeacon
            
            let proximity:CLProximity! = self.nearestBeacon?.proximity
            let bAccuracy:CLLocationAccuracy! = self.nearestBeacon?.accuracy
            var rangeMessage : String!
            
            if(proximity == CLProximity.immediate) {
                rangeMessage = "ビーコンがすぐ近くにある！"
                print("すぐ近く = \(CLProximity.immediate)")
            }
            else if(proximity == CLProximity.near) {
                rangeMessage = "ビーコンが比較的近くにある！"
                print("近く = \(CLProximity.near)")
            }
            else if(proximity == CLProximity.far) {
                rangeMessage = "ビーコンは遠くにあります。"
            }
            else if(proximity == CLProximity.unknown) {
                rangeMessage = "ビーコンが判定できなかった"
            }
            
            self.str = "\(bAccuracy! * 100) [cm]" as NSString
            print("距離解散 = \(str!)")
            
            let distance : String = String(bAccuracy! * 100)
            
            let connection = userDefaults.string(forKey: "myConnectKey")
            
            // 接続キーと距離を送信
            send(message: "\(String(describing: connection!))@\(distance)")
            print("String(describing: connection) = \(String(describing: connection!))")
            
            
            if(bAccuracy! * 100 < 0){
                
                distanceLabel.text = "受信中です"
                distanceLabel.textColor = UIColor.black
                self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2.7)
            }
            else{
                
                
                if(bAccuracy! * 100 >= 1000){
                
                    distanceLabel.text = "離れすぎています"
                    distanceLabel.textColor = UIColor.darkGray
                    self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2.7)
                }
                else if(bAccuracy! * 100 < 1000 && bAccuracy! * 100 >= 700){
                
                    distanceLabel.text = "すごく遠いです"
                    distanceLabel.textColor = UIColor.blue
                    self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2.7)
                }
                else if(bAccuracy! * 100 < 700 && bAccuracy! * 100 >= 500){
                    
                    distanceLabel.text = "まあまあ遠いです"
                    distanceLabel.textColor = UIColor.green
                    self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2.7)
                }
                else if(bAccuracy! * 100 < 500 && bAccuracy! * 100 >= 300){
                    
                    distanceLabel.text = "少し遠いです"
                    distanceLabel.textColor = UIColor.yellow
                    self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2.7)
                }
                else if(bAccuracy! * 100 < 300 && bAccuracy! * 100 >= 100){
                    
                    distanceLabel.text = "少し近いです"
                    distanceLabel.textColor = UIColor.orange
                    self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2.7)
                }
                else if(bAccuracy! * 100 < 100 && bAccuracy! * 100 >= 0){
                    
                    
                    if(bAccuracy! * 100 > 80){
                        
                        distanceLabel.text = "近いです"
                        distanceLabel.textColor = UIColor.red
                        self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2.7)
                    }
                    else if(bAccuracy! * 100 > 60){
                        
                        distanceLabel.text = "結構近いです！"
                        distanceLabel.textColor = UIColor.red
                        self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2.7)
                    }
                    else if(bAccuracy! * 100 > 40){
                        
                        distanceLabel.text = "すごく近いです！！"
                        distanceLabel.textColor = UIColor.red
                        self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2.7)
                    }
                    else if(bAccuracy! * 100 > 20){
                        
                        distanceLabel.text = "めちゃくちゃ近いです！！！"
                        distanceLabel.textColor = UIColor.red
                        self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2.7)
                    }
                    else{
                        
                        distanceLabel.text = "もう目の前にいます！！！"
                        distanceLabel.textColor = UIColor.red
                        self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2.7)
                    }
                    
                    
                }
                
                
            }
            
        }
    }
    
    // 領域観測に失敗した場合
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        
    }
    
    // 位置情報の許可設定
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if(status == .notDetermined) {
        } else if(status == .authorized) {
            
            beaconRegion?.notifyEntryStateOnDisplay = true
            self.locationManager?.startMonitoring(for: self.beaconRegion!)
            self.locationManager?.startRangingBeacons(in: self.beaconRegion!)
            
        } else if(status == .authorizedWhenInUse) {
            
            beaconRegion?.notifyEntryStateOnDisplay = true
            // 指定された地域のビーコンの通知の配信を開始します。
            self.locationManager?.startMonitoring(for: self.beaconRegion!)
            self.locationManager?.startRangingBeacons(in: self.beaconRegion!)
            
        }
    }
    
    
}
