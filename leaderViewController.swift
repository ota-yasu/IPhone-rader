//
//  leaderViewController.swift
//  iPhoneレーダー
//
//  Created by 清水直輝 on 2017/07/27.
//  Copyright © 2017年 平子英樹. All rights reserved.
//
//notej63njjx8


import UIKit
import MapKit
import NCMB
import AVFoundation
import CoreLocation
import CoreBluetooth
import LTMorphingLabel


class leaderViewController: UIViewController,UITextFieldDelegate, CLLocationManagerDelegate,AVAudioPlayerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CBPeripheralManagerDelegate {
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // 「distanceClass」のインスタンスを生成
    let disClass = NCMBObject(className: "distanceClass")
    
    let sharedNote = NCMBObject(className:"distanceClass")
    
    /******************************* UIView *******************************/
    var clickAction : UIView! = nil
    var clickActionR : UIView! = nil
    var clickActionR1: UIView! = nil
    var clickActionR2 : UIView! = nil
    var clickActionR3 : UIView! = nil
    var clickActionR4 : UIView! = nil
    var clickActionO : UIView! = nil
    var clickActionY : UIView! = nil
    var clickActionGr : UIView! = nil
    var clickActionB : UIView! = nil
    var clickActionG : UIView! = nil
    
    var SearchLabel : UILabel! = nil
    var AddiPhone : UILabel! = nil
    var myimageview : UIImageView!
    
    /******************************* Map *******************************/
    var myLocationManager: CLLocationManager!
    var onlyoneBool : Bool! = false
    
    var othersLatitude : Double = 0
    var othersLongitude : Double = 0
    
    var myLatitude : Double = 0
    var myLongitude : Double = 0
    
    var myLatDist : CLLocationDistance!
    var myLonDist : CLLocationDistance!
    
    /******************************* 音を再生するのに使う変数 *******************************/
    var audioFile : AVAudioFile!
    var audioFilePlayer: AVAudioPlayerNode!
    var mixer : AVAudioMixerNode!
    var input : AVAudioInputNode!
    var audioEngine : AVAudioEngine!
    var myAudioPlayer : AVAudioPlayer!
    var AudioRate : Float! = 0
    var audioUnitTimePitch: AVAudioUnitTimePitch!
    
    var recordBool : Bool = false
    
    /******************************* 変数 *******************************/
    
    var arrayLength: Int = 0
    var clickcount : Int! = 0
    var DateCount : Int32! = 0
    
    var pushB = 0
    
    var startM = false
    var SearchiPhoneBool : Bool! = true
    var secondcount : Bool! = true
    
    
    var numRound: Double = 0
    
    // 北か南を入れる
    var angleUD : String = ""
    // 東か西を入れる
    var angleRL : String = ""
    
    var angle : String = ""
    
    // プッシュ通知でメッセージを入れる変数
    var message = "探索開始"
    
    var x: CGFloat!
    var y: CGFloat!
    var tmpW:CGFloat!
    var tmpH:CGFloat!
    var wx: CGFloat!
    var wy: CGFloat!
    
    var deviceDistance:Double = 0
    
    // 保存変数
    let userDefault = UserDefaults.standard
    
    var windowLabel : LTMorphingLabel!
    
    /******************************* Timer *******************************/
    
    
    // 追加するためのUIWindow
    var selectWindow: UIWindow!
    
    
    var distanceLabel : LTMorphingLabel!
    
    /******************************* UIDatePickerView *******************************/
    // データベースの中のデータを表示する
    var databasePicker: UIPickerView = UIPickerView()
    
    
    // 登録した人の名前を格納する
    var dataArray: NSMutableArray = []
    // 登録した人の接続キー及びパスワードを格納する
    var keyArray: NSMutableArray = []
    
    // 端末追加画面の説明ラベル
    var addDeviceExplain: UILabel!
    
    // 選択した端末名を表示する
    var nameTextField: UITextField!
    
    /******************** iBeacon ********************/
    // 受信(距離を測る)
    var locationManager:CLLocationManager?
    var proximityUUID:NSUUID?
    var beaconRegion:CLBeaconRegion?
    var nearestBeacon:CLBeacon?
    var str:NSString?
    
    
    var iPhoneImage: UIButton!
    
    
    /************************* デザイン画像 *************************/
    //背景のアニメーション用画像//
    var ImgLostBac1 : UIImage!
    var ImgLostBac2 : UIImage!
    var ImgLostBac3 : UIImage!
    var ImgLostBac4 : UIImage!
    var ImgLostBac5 : UIImage!
    var ImgLostBac6 : UIImage!
    var ImgLostBac7 : UIImage!
    var ImgLostBac8 : UIImage!
    var ImgLostBac9 : UIImage!
    var ImgLostBac10 : UIImage!
    var ImgLostBac11 : UIImage!
    var ImgLostBacListArray :Array<UIImage> = []
    var ImgLostChangeView : UIImageView!
    //背景のアニメーション用画像//
    
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
    
    //テキスト表示用のラベル//
    var ImgViewStateDisplay : UIImageView!
    var ImgStateDisplay : UIImage!
    var LblStateDisplay : UILabel!
    
    var ImgViewConnectionState : UIImageView!
    var LblConnectionState : UILabel!
    var ImgConnectionState : UIImage!
    //テキスト表示用のラベル//
    
    //追加ボタンのwindow用アニメーション//
    var ImgAddWindow1 : UIImage!
    var ImgAddWindow2 : UIImage!
    var ImgAddWindow3 : UIImage!
    var ImgAddWindowView : UIImageView!
    var ImgAddWindowArray :Array<UIImage> = []
    var ImgEndWindowArray :Array<UIImage> = []
    //追加ボタンのwindow用アニメーション//
    
    //レーダーの表示用//
    var ImgLeader : UIImage!
    
    var ImgViewLeader : UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        x = self.view.frame.width
        y = self.view.frame.height
        
        
        wx = view.frame.width/1.3
        wy = view.frame.height/1.5
        
        NotificationCenter.default.addObserver(self, selector: #selector(leaderViewController.viewWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(leaderViewController.viewDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        /************************* デザイン画像の設定 *************************/
        
        ImgLostBac1 = UIImage(named:"紛失モード（背景1）.png")
        ImgLostBac2 = UIImage(named:"紛失モード（背景2）.png")
        ImgLostBac3 = UIImage(named:"紛失モード（背景3）.png")
        ImgLostBac4 = UIImage(named:"紛失モード（背景4）.png")
        ImgLostBac5 = UIImage(named:"紛失モード（背景5）.png")
        ImgLostBac6 = UIImage(named:"紛失モード（背景6）.png")
        ImgLostBac7 = UIImage(named:"紛失モード（背景7）.png")
        ImgLostBac8 = UIImage(named:"紛失モード（背景8）.png")
        ImgLostBac9 = UIImage(named:"紛失モード（背景9）.png")
        ImgLostBac10 = UIImage(named:"紛失モード（背景10）.png")
        ImgLostBac11 = UIImage(named:"紛失モード（背景11）.png")
        
        ImgLostBacListArray.append(ImgLostBac1)
        ImgLostBacListArray.append(ImgLostBac2)
        ImgLostBacListArray.append(ImgLostBac3)
        ImgLostBacListArray.append(ImgLostBac4)
        ImgLostBacListArray.append(ImgLostBac5)
        ImgLostBacListArray.append(ImgLostBac6)
        ImgLostBacListArray.append(ImgLostBac7)
        ImgLostBacListArray.append(ImgLostBac8)
        ImgLostBacListArray.append(ImgLostBac9)
        ImgLostBacListArray.append(ImgLostBac10)
        ImgLostBacListArray.append(ImgLostBac11)
        
        var rect = CGRect(x:0,y:0,width:self.view.bounds.width,height:self.view.bounds.height)
        
        ImgLostChangeView  = UIImageView()
        
        ImgLostChangeView.frame = rect
        
        ImgLostChangeView.center = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/2)
        
        self.view.addSubview(ImgLostChangeView)
        
        ImgLostChangeView.animationImages = ImgLostBacListArray
        
        ImgLostChangeView.animationDuration = 0.8
        
        ImgLostChangeView.animationRepeatCount = 1
        
        ImgLostChangeView.image = ImgLostBacListArray[0]
        
        ImgAddButton1 = UIImage(named:"紛失モード（選択1）.png")
        ImgAddButton2 = UIImage(named:"紛失モード（選択2）.png")
        ImgAddButton3 = UIImage(named:"紛失モード（選択3）.png")
        ImgLastButton = UIImage(named:"紛失モード（ボタン）.png")
        
        ImgAddButtonArray.append(ImgAddButton1)
        ImgAddButtonArray.append(ImgAddButton2)
        ImgAddButtonArray.append(ImgAddButton3)
        ImgAddButtonArray.append(ImgLastButton)
        
        
        /**********************端末登録ボタン処理*********************/
        
        
        // 追加ボタン
        BtnAdd = UIButton()
        BtnAdd.frame = CGRect(x:0,y:0,width:self.view.bounds.width/2,height:self.view.bounds.height/7)
        BtnAdd.setImage(ImgAddButtonArray[0], for:.normal)
        BtnAdd.setImage(ImgAddButtonArray[0], for:.highlighted)
        BtnAdd.layer.position = CGPoint(x:self.view.bounds.width/1.3,y:self.view.bounds.height/1.1)
        BtnAdd.addTarget(self, action: #selector(leaderViewController.SearchaddiPhone(sender:)), for: .touchUpInside)
        
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
        BtnLost.frame = CGRect(x:0,y:0,width:self.view.bounds.width/2,height:self.view.bounds.height/7)
        BtnLost.setImage(ImgLostButtonArray[0], for:.normal)
        BtnLost.setImage(ImgLostButtonArray[0], for:.highlighted)
        BtnLost.layer.position = CGPoint(x:self.view.bounds.width/1.3,y:self.view.bounds.height/1.1)
        BtnLost.addTarget(self, action: #selector(leaderViewController.SearchaddiPhone(sender:)), for: .touchUpInside)
        
        BtnLost.imageView?.animationImages = ImgLostButtonArray
        BtnLost.imageView?.animationDuration = 0.5
        BtnLost.imageView?.animationRepeatCount = 1
        
        self.view.addSubview(BtnLost)
        
        BtnLost.isHidden = true
        
        
        ImgSearchStartButton1 = UIImage(named:"紛失モード（ボタン7）.png")
        ImgSearchStartButton2 = UIImage(named:"紛失モード（ボタン8）.png")
        ImgSearchStartButton3 = UIImage(named:"紛失モード（ボタン9）.png")
        
        ImgSearchStartButtonArray.append(ImgSearchStartButton1)
        ImgSearchStartButtonArray.append(ImgSearchStartButton2)
        ImgSearchStartButtonArray.append(ImgSearchStartButton3)
        ImgSearchStartButtonArray.append(ImgLastButton)
        
        BtnSearchStart = UIButton()
        BtnSearchStart.frame = CGRect(x:0,y:0,width:self.view.bounds.width/2,height:self.view.bounds.height/7)
        BtnSearchStart.setImage(ImgSearchStartButtonArray[0], for:.normal)
        BtnSearchStart.setImage(ImgSearchStartButtonArray[0], for:.highlighted)
        BtnSearchStart.layer.position = CGPoint(x:self.view.bounds.width/4,y:self.view.bounds.height/1.1)
        BtnSearchStart.addTarget(self, action: #selector(leaderViewController.clickButton(sender:)), for: .touchUpInside)
        BtnSearchStart.tag = 1
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
        BtnSearchStop.frame = CGRect(x:0,y:0,width:self.view.bounds.width/2,height:self.view.bounds.height/7)
        BtnSearchStop.setImage(ImgSearchStopButtonArray[0], for:.normal)
        BtnSearchStop.setImage(ImgSearchStopButtonArray[0], for:.highlighted)
        BtnSearchStop.layer.position = CGPoint(x:self.view.bounds.width/4,y:self.view.bounds.height/1.1)
        BtnSearchStop.addTarget(self, action: #selector(leaderViewController.clickButton(sender:)), for: .touchUpInside)
        BtnSearchStop.tag = 1
        BtnSearchStop.imageView?.animationImages = ImgSearchStopButtonArray
        BtnSearchStop.imageView?.animationDuration = 0.5
        BtnSearchStop.imageView?.animationRepeatCount = 1
        
        self.view.addSubview(BtnSearchStop)
        
        BtnSearchStop.isHidden = true
        
        ImgViewConnectionState = UIImageView()
        ImgViewConnectionState.frame = CGRect(x:0,y:0,width:self.view.bounds.width/1.1,height:self.view.bounds.height/8)
        ImgViewConnectionState.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/1.6)
        ImgConnectionState = UIImage(named:"紛失モード（ネームプレート）.png")
        ImgViewConnectionState.image = ImgConnectionState
        self.view.addSubview(ImgViewConnectionState)
        //LblConnectionState = UILabel()
        ImgViewStateDisplay = UIImageView()
        ImgViewStateDisplay.frame = CGRect(x:0,y:0,width:self.view.bounds.width/1.1,height:self.view.bounds.height/5)
        ImgViewStateDisplay.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/1.29)
        ImgStateDisplay = UIImage(named:"紛失モード（ラベル）.png")
        ImgViewStateDisplay.image = ImgStateDisplay
        self.view.addSubview(ImgViewStateDisplay)
        //LblStateDisplay = UILabel()
        
        ImgViewLeader = UIImageView()
        ImgViewLeader.frame = CGRect(x:0,y:0,width:self.view.bounds.width/1.1,height:self.view.bounds.width/1.1)
        ImgViewLeader.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/2 - self.view.bounds.width / 2.75)
        ImgLeader = UIImage(named:"紛失モード（レーダー）.png")
        ImgViewLeader.image = ImgLeader
        self.view.addSubview(ImgViewLeader)
        
        ImgAddWindow1 = UIImage(named:"紛失モード（端末選択の背景1）.png")
        ImgAddWindow2 = UIImage(named:"紛失モード（端末選択の背景2）.png")
        ImgAddWindow3 = UIImage(named:"紛失モード（端末選択の背景3）.png")
        
        ImgAddWindowArray.append(ImgAddWindow1)
        ImgAddWindowArray.append(ImgAddWindow2)
        ImgAddWindowArray.append(ImgAddWindow3)
        
        ImgEndWindowArray.append(ImgAddWindow3)
        ImgEndWindowArray.append(ImgAddWindow2)
        ImgEndWindowArray.append(ImgAddWindow1)
        
        ImgAddWindowView  = UIImageView()
        
        rect = CGRect(x:0,y:0,width:self.view.bounds.height/1.4,height:self.view.bounds.height/1.4)
        
        ImgAddWindowView.frame = rect
        
        ImgAddWindowView.layer.zPosition = 2
        
        ImgAddWindowView.center = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/2)
        
        self.view.addSubview(ImgAddWindowView)
        
        ImgAddWindowView.animationImages = ImgAddWindowArray
        
        ImgAddWindowView.animationDuration = 0.4
        
        ImgAddWindowView.animationRepeatCount = 1
        
        ImgAddWindowView.image = ImgAddWindowArray[2]
        
        ImgAddWindowView.alpha = 0.0
        
        
        selectWindow = UIWindow()
        
        print("SELECT")
        let db = FMDatabase(path: DatabaseClass().table7)
        // 登録した人のデバイス名
        let db2 = FMDatabase(path: DatabaseClass().table2)
        // 登録した人の接続キー
        let db3 = FMDatabase(path: DatabaseClass().table3)
        
        let sql = "SELECT * FROM sample2"
        let sql2 = "SELECT * FROM device2"
        let sql3 = "SELECT * FROM device3"
        
        db?.open()
        db2?.open()
        db3?.open()
        
        let results = db?.executeQuery(sql, withArgumentsIn: nil)
        let results2 = db2?.executeQuery(sql2, withArgumentsIn: nil)
        let results3 = db3?.executeQuery(sql3, withArgumentsIn: nil)
        
        while (results?.next())! {
            
            // カラム名を指定して値を取得する方法
            let user_id = results?.int(forColumn: "user_id")
            
            // カラムのインデックスを指定して取得する方法
            let user_name = results?.string(forColumnIndex: 1)
            
            print("user_id = \(user_id), user_name = \(user_name)")
            
            if(user_id == 1){
                print("きてます")
                DateCount = Int32(user_name!)
                print("DateCount = \(DateCount)")
                
            }
        }
        
        while (results2?.next())! {
            
            // カラム名を指定して値を取得する方法
            let user_id = results2?.int(forColumn: "user_id")
            
            // カラムのインデックスを指定して取得する方法
            let user_name = results2?.string(forColumnIndex: 1)
            
            dataArray.add(user_name!)
            
        }
        
        while (results3?.next())! {
            
            // カラムのインデックスを指定して取得する方法
            let user_name = results3?.string(forColumnIndex: 1)
            
            keyArray.add(user_name!)
            
            
            arrayLength += 1
        }
        
        
        db?.close()
        db2?.close()
        db3?.close()
        
        
        
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
        
        
        // バックグラウンドでも実行を続けるために用意したmyLocationManager
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = 1
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        if(status != CLAuthorizationStatus.authorizedAlways) {
            
            print("GPS認証")
            // まだ承認が得られていない場合は、認証ダイアログを表示
            myLocationManager.requestAlwaysAuthorization()
        }
        
        myLocationManager.allowsBackgroundLocationUpdates = true
        self.myLocationManager.startUpdatingLocation()
        
        
        
        //録音に関する処理//
        self.audioFilePlayer = AVAudioPlayerNode()
        self.audioEngine = AVAudioEngine()
        self.audioEngine.attach(audioFilePlayer)
        self.input = audioEngine.inputNode
        self.mixer = audioEngine.mainMixerNode
        
        let soundFilePath : String = Bundle.main.path(forResource:"サンプル1", ofType: "mp3")!
        
        let fileURL = URL(fileURLWithPath: soundFilePath)
        
        //AVAudioPlayerのインスタンス化.
        myAudioPlayer = try! AVAudioPlayer(contentsOf: fileURL)
        print("DateCount = \(DateCount)")
        if(DateCount <= 5 && DateCount > 0){
            
            let soundFilePath : String = Bundle.main.path(forResource:"サンプル"+String(DateCount) , ofType: "mp3")!
            
            let fileURL = URL(fileURLWithPath: soundFilePath)
            
            //AVAudioPlayerのインスタンス化.
            myAudioPlayer = try! AVAudioPlayer(contentsOf: fileURL)
            
            //AVAudioPlayerのデリゲートをセット.
            myAudioPlayer.delegate = self
            
        }
        
        
        /**********************レーダー処理*********************/
        
        tmpH = self.view!.frame.width/10
        tmpW = self.view!.frame.width/10
        
        myimageview = UIImageView()
        myimageview = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width/13, height: self.view.bounds.height/30))
        myimageview.layer.position = CGPoint(x:ImgViewLeader.layer.position.x,y:ImgViewLeader.layer.position.y)
        //ImgLeader
        let sizeX = x/3
        
        let iPhoneImage = UIImage(named:"iPhone画像.png")!
        let resizeiPhoneImage = iPhoneImage.ResizeÜIImage(width: sizeX/2, height: sizeX)
        
        myimageview = UIImageView(image: resizeiPhoneImage)
        myimageview.layer.position = CGPoint(x: ImgViewLeader.layer.position.x, y: ImgViewLeader.layer.position.y)
        
        self.view.addSubview(myimageview)

        /**********************ここまで*********************/
        
        
        
        
        /**********************ここまで*********************/
        // 端末リストを表示するdatabasePicker
        databasePicker = UIPickerView()
        databasePicker.frame = CGRect(x: wx/2 - wx/2.5, y: wy/30, width: wx/1.5, height: wy/4)
        databasePicker.delegate = self
        databasePicker.layer.borderWidth = x/300
        databasePicker.dataSource = self
        databasePicker.tag = 1
        databasePicker.isHidden = true
        selectWindow.addSubview(databasePicker)
        
        
        
        /**********************探索端末ラベル処理*********************/
        SearchLabel = UILabel()
        SearchLabel.frame = CGRect(x:0,y:0,width:self.view.bounds.width/1.2,height:self.view.bounds.height/10)
        //！！！！！！⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️！！！！！
        
        //探索する端末の名前をテキストに代入
        SearchLabel.text = "探す端末を追加してください"
        SearchLabel.layer.masksToBounds = true
        SearchLabel.layer.cornerRadius = SearchLabel.frame.width/10
        SearchLabel.textColor = UIColor.black
        SearchLabel.textAlignment = .center
        SearchLabel.layer.position = CGPoint(x:x/2,y:ImgViewStateDisplay.layer.position.y)
        self.view.addSubview(SearchLabel)
        
        
        
        distanceLabel = LTMorphingLabel(frame: CGRect(x: x/2 - x/12, y: y/2 + y/12, width: x/1.5, height: y/10))
        distanceLabel.textColor = UIColor.black
        distanceLabel.font = UIFont.systemFont(ofSize: x/20)
        distanceLabel.text = "未探索"
        distanceLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(distanceLabel)
        
        /**********************ここまで*********************/
        
        appDelegate.receveTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(leaderViewController.receveStart(_:)), userInfo: nil, repeats: true)
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio) != .authorized {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio,
                                          completionHandler: { (granted: Bool) in
            })
        }
        
        if(appDelegate.receveTimer.isValid == false){
            
            
            if(CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)) {
                
                self.locationManager = CLLocationManager()
                self.locationManager?.delegate = self
                
                // 取得制度を最高にする！！！
                self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                
                // 取得頻度の設定(1mごとに位置情報取得)
                self.locationManager?.distanceFilter = 0.1
                
                // UUIDの指定
                self.proximityUUID = NSUUID(uuidString: "C7B7070C-2F91-44A4-9EB1-50F970C21FA1")
                
                self.beaconRegion = CLBeaconRegion(proximityUUID: self.proximityUUID! as UUID, major: CLBeaconMajorValue(1), minor: CLBeaconMinorValue(1), identifier: userDefault.string(forKey: "myConnectKey")!)
                
                self.beaconRegion?.notifyOnEntry = true
                
                // 退域通知の設定.
                self.beaconRegion?.notifyOnExit = true
                
                let status = CLLocationManager.authorizationStatus()
                if status == CLAuthorizationStatus.notDetermined {
                    self.locationManager?.requestAlwaysAuthorization()
                } else {
                    
                    // 指定された領域の監視を開始します
                    self.locationManager?.startMonitoring(for: self.beaconRegion!)
                    
                    print("監視を開始")
                }
                
                
            }
            else {
                
                let alert:UIAlertView? = UIAlertView(title: "確認",message: "お使いの端末ではiBeaconを利用できません。", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                alert?.show()
            }
        }
        
        /************************* UIButtonやUILabelの状態 *************************/
        
        if(appDelegate.SearchButtonBool == false && appDelegate.SelectiPhone != ""){
            
            self.SearchLabel.text = appDelegate.SelectiPhone + "さんの端末を探しています"
            BtnSearchStart.isHidden = true
            BtnSearchStop.isHidden = false
        }
        
        
        
        /************************* UIView(レーダーの色) *************************/
        
        // 赤
        // 0.5
        clickActionR = UIView()
        clickActionR.frame = CGRect(x:0,y:0,width:tmpW,height:tmpH)
        clickActionR.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
        clickActionR.layer.cornerRadius = clickActionR.frame.width/2
        clickActionR.layer.backgroundColor = UIColor(red: 2.0, green: 0, blue: 0.5, alpha: 1.0).cgColor
        clickActionR.alpha = 1
        if(appDelegate.viewLeader == 1){
            
            clickActionR.isHidden = false
        }
        else{
            
            clickActionR.isHidden = true
        }
        self.view.addSubview(clickActionR)
        
        UIView.animate(withDuration: 0.5, delay: 0.1, options: [.repeat],animations: {
            self.clickActionR.transform = CGAffineTransform(scaleX: 9, y: 9)
            self.clickActionR.alpha = 0
        })
        
        // 0.4
        clickActionR4 = UIView()
        clickActionR4.frame = CGRect(x:0,y:0,width:tmpW,height:tmpH)
        clickActionR4.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
        clickActionR4.layer.cornerRadius = clickActionR4.frame.width/2
        clickActionR4.layer.backgroundColor = UIColor(red: 2.0, green: 0, blue: 0.5, alpha: 1.0).cgColor
        clickActionR4.alpha = 1
        if(appDelegate.viewLeader == 1){
            
            clickActionR4.isHidden = false
        }
        else{
            
            clickActionR4.isHidden = true
        }
        self.view.addSubview(clickActionR4)
        
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.repeat],animations: {
            self.clickActionR4.transform = CGAffineTransform(scaleX: 9, y: 9)
            self.clickActionR4.alpha = 0
        })
        
        
        // 0.3
        clickActionR3 = UIView()
        clickActionR3.frame = CGRect(x:0,y:0,width:tmpW,height:tmpH)
        clickActionR3.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
        clickActionR3.layer.cornerRadius = clickActionR3.frame.width/2
        clickActionR3.layer.backgroundColor = UIColor(red: 2.0, green: 0, blue: 0.5, alpha: 1.0).cgColor
        clickActionR3.alpha = 1
        if(appDelegate.viewLeader == 1){
            
            clickActionR3.isHidden = false
        }
        else{
            
            clickActionR3.isHidden = true
        }
        self.view.addSubview(clickActionR3)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: [.repeat],animations: {
            self.clickActionR3.transform = CGAffineTransform(scaleX: 9, y: 9)
            self.clickActionR3.alpha = 0
        })
        
        
        // 0.2
        clickActionR2 = UIView()
        clickActionR2.frame = CGRect(x:0,y:0,width:tmpW,height:tmpH)
        clickActionR2.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
        clickActionR2.layer.cornerRadius = clickActionR2.frame.width/2
        clickActionR2.layer.backgroundColor = UIColor(red: 2.0, green: 0, blue: 0.5, alpha: 1.0).cgColor
        clickActionR2.alpha = 1
        if(appDelegate.viewLeader == 1){
            
            clickActionR2.isHidden = false
        }
        else{
            
            clickActionR2.isHidden = true
        }
        self.view.addSubview(clickActionR2)
        
        UIView.animate(withDuration: 0.2, delay: 0.1, options: [.repeat],animations: {
            self.clickActionR2.transform = CGAffineTransform(scaleX: 9, y: 9)
            self.clickActionR2.alpha = 0
        })
        
        // 0.1
        clickActionR1 = UIView()
        clickActionR1.frame = CGRect(x:0,y:0,width:tmpW,height:tmpH)
        clickActionR1.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
        clickActionR1.layer.cornerRadius = clickActionR1.frame.width/2
        clickActionR1.layer.backgroundColor = UIColor(red: 2.0, green: 0, blue: 0.5, alpha: 1.0).cgColor
        clickActionR1.alpha = 1
        if(appDelegate.viewLeader == 1){
            
            clickActionR1.isHidden = false
        }
        else{
            
            clickActionR1.isHidden = true
        }
        self.view.addSubview(clickActionR1)
        
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [.repeat],animations: {
            self.clickActionR1.transform = CGAffineTransform(scaleX: 9, y: 9)
            self.clickActionR1.alpha = 0
        })
        
        // オレンジ
        clickActionO = UIView()
        clickActionO.frame = CGRect(x:0,y:0,width:tmpW,height:tmpH)
        clickActionO.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
        clickActionO.layer.cornerRadius = clickActionO.frame.width/2
        clickActionO.layer.backgroundColor = UIColor.orange.cgColor
        clickActionO.isHidden = true
        clickActionO.alpha = 1
        if(appDelegate.viewLeader == 2){
            
            clickActionO.isHidden = false
        }
        else{
            
            clickActionO.isHidden = true
        }
        self.view.addSubview(clickActionO)
        UIView.animate(withDuration: 1, delay: 0.1, options: [.repeat],animations: {
            self.clickActionO.transform = CGAffineTransform(scaleX: 9, y: 9)
            self.clickActionO.alpha = 0
        })
        
        // 黄色
        clickActionY = UIView()
        clickActionY.frame = CGRect(x:0,y:0,width:tmpW,height:tmpH)
        clickActionY.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
        clickActionY.layer.cornerRadius = clickActionY.frame.width/2
        clickActionY.layer.backgroundColor = UIColor(red: 100, green: 100, blue: 0, alpha: 1.0).cgColor
        clickActionY.alpha = 1
        clickActionY.isHidden = true
        if(appDelegate.viewLeader == 3){
            
            clickActionY.isHidden = false
        }
        else{
            
            clickActionY.isHidden = true
        }
        self.view.addSubview(clickActionY)
        UIView.animate(withDuration: 1.5, delay: 0.1, options: [.repeat],animations: {
            self.clickActionY.transform = CGAffineTransform(scaleX: 9, y: 9)
            self.clickActionY.alpha = 0
        })
        
        // 緑
        clickActionGr = UIView()
        clickActionGr.frame = CGRect(x:2,y:0,width:tmpW,height:tmpH)
        clickActionGr.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
        clickActionGr.layer.cornerRadius = clickActionGr.frame.width/2
        clickActionGr.layer.backgroundColor = UIColor(red: 0, green: 2.0, blue: 0, alpha: 1.0).cgColor
        clickActionGr.alpha = 1
        clickActionGr.isHidden = true
        if(appDelegate.viewLeader == 4){
            
            clickActionGr.isHidden = false
        }
        else{
            
            clickActionGr.isHidden = true
        }
        self.view.addSubview(clickActionGr)
        UIView.animate(withDuration: 2, delay: 0.1, options: [.repeat],animations: {
            self.clickActionGr.transform = CGAffineTransform(scaleX: 9, y: 9)
            self.clickActionGr.alpha = 0
        })
        
        // 青
        clickActionB = UIView()
        clickActionB.frame = CGRect(x:2.5,y:0,width:tmpW,height:tmpH)
        clickActionB.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
        clickActionB.layer.cornerRadius = clickActionB.frame.width/2
        clickActionB.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 2.0, alpha: 1.0).cgColor
        clickActionB.alpha = 1
        clickActionB.isHidden = true
        if(appDelegate.viewLeader == 5){
            
            clickActionB.isHidden = false
        }
        else{
            
            clickActionB.isHidden = true
        }
        self.view.addSubview(clickActionB)
        UIView.animate(withDuration: 2.5, delay: 0.1, options: [.repeat],animations: {
            self.clickActionB.transform = CGAffineTransform(scaleX: 9, y: 9)
            self.clickActionB.alpha = 0
        })
        
        // 灰色
        clickActionG = UIView()
        clickActionG.frame = CGRect(x:3,y:0,width:tmpW,height:tmpH)
        clickActionG.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
        clickActionG.layer.cornerRadius = clickActionG.frame.width/2
        clickActionG.layer.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
        clickActionG.alpha = 1
        clickActionG.isHidden = true
        if(appDelegate.viewLeader == 6){
            
            clickActionG.isHidden = false
        }
        else{
            
            clickActionG.isHidden = true
        }
        self.view.addSubview(clickActionG)
        UIView.animate(withDuration: 2.5, delay: 0.1, options: [.repeat],animations: {
            self.clickActionG.transform = CGAffineTransform(scaleX: 9, y: 9)
            self.clickActionG.alpha = 0
        })
    }
    
    // フォアグラウンド
    func viewWillEnterForeground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            
            // 探索開始しているなら
            if(appDelegate.SearchButtonBool == false){
                
                // タイマーが起動していないなら
                if(appDelegate.niftyTimer.isValid == false){
                    
                    appDelegate.niftyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(leaderViewController.distance(_:)), userInfo: nil, repeats: true)
                    appDelegate.backNiftyTime = true
                    
                }
            }
            
            // 赤
            clickActionR = UIView()
            clickActionR.frame = CGRect(x:0,y:0,width:tmpW,height:tmpH)
            clickActionR.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
            clickActionR.layer.cornerRadius = clickActionR.frame.width/2
            clickActionR.layer.backgroundColor = UIColor(red: 2.0, green: 0, blue: 0.5, alpha: 1.0).cgColor
            clickActionR.alpha = 1
            if(appDelegate.viewLeader == 1){
                
                clickActionR.isHidden = false
            }
            else{
                
                clickActionR.isHidden = true
            }
            self.view.addSubview(clickActionR)
            
            UIView.animate(withDuration: 0.5, delay: 0.1, options: [.repeat],animations: {
                self.clickActionR.transform = CGAffineTransform(scaleX: 9, y: 9)
                self.clickActionR.alpha = 0
            })
            
            
            // 0.4
            clickActionR4 = UIView()
            clickActionR4.frame = CGRect(x:0,y:0,width:tmpW,height:tmpH)
            clickActionR4.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
            clickActionR4.layer.cornerRadius = clickActionR4.frame.width/2
            clickActionR4.layer.backgroundColor = UIColor(red: 2.0, green: 0, blue: 0.5, alpha: 1.0).cgColor
            clickActionR4.alpha = 1
            if(appDelegate.viewLeader == 10){
                
                clickActionR4.isHidden = false
            }
            else{
                
                clickActionR4.isHidden = true
            }
            self.view.addSubview(clickActionR4)
            
            UIView.animate(withDuration: 0.4, delay: 0.1, options: [.repeat],animations: {
                self.clickActionR4.transform = CGAffineTransform(scaleX: 9, y: 9)
                self.clickActionR4.alpha = 0
            })
            
            
            // 0.3
            clickActionR3 = UIView()
            clickActionR3.frame = CGRect(x:0,y:0,width:tmpW,height:tmpH)
            clickActionR3.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
            clickActionR3.layer.cornerRadius = clickActionR3.frame.width/2
            clickActionR3.layer.backgroundColor = UIColor(red: 2.0, green: 0, blue: 0.5, alpha: 1.0).cgColor
            clickActionR3.alpha = 1
            if(appDelegate.viewLeader == 9){
                
                clickActionR3.isHidden = false
            }
            else{
                
                clickActionR3.isHidden = true
            }
            self.view.addSubview(clickActionR3)
            
            UIView.animate(withDuration: 0.3, delay: 0.1, options: [.repeat],animations: {
                self.clickActionR3.transform = CGAffineTransform(scaleX: 9, y: 9)
                self.clickActionR3.alpha = 0
            })
            
            
            // 0.2
            clickActionR2 = UIView()
            clickActionR2.frame = CGRect(x:0,y:0,width:tmpW,height:tmpH)
            clickActionR2.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
            clickActionR2.layer.cornerRadius = clickActionR2.frame.width/2
            clickActionR2.layer.backgroundColor = UIColor(red: 2.0, green: 0, blue: 0.5, alpha: 1.0).cgColor
            clickActionR2.alpha = 1
            if(appDelegate.viewLeader == 8){
                
                clickActionR2.isHidden = false
            }
            else{
                
                clickActionR2.isHidden = true
            }
            self.view.addSubview(clickActionR2)
            
            UIView.animate(withDuration: 0.2, delay: 0.1, options: [.repeat],animations: {
                self.clickActionR2.transform = CGAffineTransform(scaleX: 9, y: 9)
                self.clickActionR2.alpha = 0
            })
            
            // 0.1
            clickActionR1 = UIView()
            clickActionR1.frame = CGRect(x:0,y:0,width:tmpW,height:tmpH)
            clickActionR1.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
            
            clickActionR1.layer.cornerRadius = clickActionR1.frame.width/2
            clickActionR1.layer.backgroundColor = UIColor(red: 2.0, green: 0, blue: 0.5, alpha: 1.0).cgColor
            clickActionR1.alpha = 1
            if(appDelegate.viewLeader == 7){
                
                clickActionR1.isHidden = false
            }
            else{
                
                clickActionR1.isHidden = true
            }
            self.view.addSubview(clickActionR1)
            
            UIView.animate(withDuration: 0.1, delay: 0.1, options: [.repeat],animations: {
                self.clickActionR1.transform = CGAffineTransform(scaleX: 9, y: 9)
                self.clickActionR1.alpha = 0
            })
            
            // オレンジ
            clickActionO = UIView()
            clickActionO.frame = CGRect(x:0,y:0,width:tmpW,height:tmpH)
            clickActionO.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
            clickActionO.layer.cornerRadius = clickActionO.frame.width/2
            clickActionO.layer.backgroundColor = UIColor.orange.cgColor
            clickActionO.isHidden = true
            clickActionO.alpha = 1
            if(appDelegate.viewLeader == 2){
                
                clickActionO.isHidden = false
            }
            else{
                
                clickActionO.isHidden = true
            }
            self.view.addSubview(clickActionO)
            UIView.animate(withDuration: 1, delay: 0.1, options: [.repeat],animations: {
                self.clickActionO.transform = CGAffineTransform(scaleX: 9, y: 9)
                self.clickActionO.alpha = 0
            })
            
            // 黄色
            clickActionY = UIView()
            clickActionY.frame = CGRect(x:0,y:0,width:tmpW,height:tmpH)
            clickActionY.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
            clickActionY.layer.cornerRadius = clickActionY.frame.width/2
            clickActionY.layer.backgroundColor = UIColor(red: 100, green: 100, blue: 0, alpha: 1.0).cgColor
            clickActionY.alpha = 1
            clickActionY.isHidden = true
            if(appDelegate.viewLeader == 3){
                
                clickActionY.isHidden = false
            }
            else{
                
                clickActionY.isHidden = true
            }
            self.view.addSubview(clickActionY)
            UIView.animate(withDuration: 1.5, delay: 0.1, options: [.repeat],animations: {
                self.clickActionY.transform = CGAffineTransform(scaleX: 9, y: 9)
                self.clickActionY.alpha = 0
            })
            
            // 緑
            clickActionGr = UIView()
            clickActionGr.frame = CGRect(x:2,y:0,width:tmpW,height:tmpH)
            clickActionGr.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
            clickActionGr.layer.cornerRadius = clickActionGr.frame.width/2
            clickActionGr.layer.backgroundColor = UIColor(red: 0, green: 2.0, blue: 0, alpha: 1.0).cgColor
            clickActionGr.alpha = 1
            clickActionGr.isHidden = true
            if(appDelegate.viewLeader == 4){
                
                clickActionGr.isHidden = false
            }
            else{
                
                clickActionGr.isHidden = true
            }
            self.view.addSubview(clickActionGr)
            UIView.animate(withDuration: 2, delay: 0.1, options: [.repeat],animations: {
                self.clickActionGr.transform = CGAffineTransform(scaleX: 9, y: 9)
                self.clickActionGr.alpha = 0
            })
            
            // 青
            clickActionB = UIView()
            clickActionB.frame = CGRect(x:2.5,y:0,width:tmpW,height:tmpH)
            clickActionB.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
            clickActionB.layer.cornerRadius = clickActionB.frame.width/2
            clickActionB.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 2.0, alpha: 1.0).cgColor
            clickActionB.alpha = 1
            clickActionB.isHidden = true
            if(appDelegate.viewLeader == 5){
                
                clickActionB.isHidden = false
            }
            else{
                
                clickActionB.isHidden = true
            }
            self.view.addSubview(clickActionB)
            UIView.animate(withDuration: 2.5, delay: 0.1, options: [.repeat],animations: {
                self.clickActionB.transform = CGAffineTransform(scaleX: 9, y: 9)
                self.clickActionB.alpha = 0
            })
            
            // 灰色
            clickActionG = UIView()
            clickActionG.frame = CGRect(x:3,y:0,width:tmpW,height:tmpH)
            clickActionG.layer.position = CGPoint(x:self.view.bounds.width/2,y:ImgViewLeader.layer.position.y)
            clickActionG.layer.cornerRadius = clickActionG.frame.width/2
            clickActionG.layer.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
            clickActionG.alpha = 1
            clickActionG.isHidden = true
            if(appDelegate.viewLeader == 6){
                
                clickActionG.isHidden = false
            }
            else{
                
                clickActionG.isHidden = true
            }
            self.view.addSubview(clickActionG)
            UIView.animate(withDuration: 2.5, delay: 0.1, options: [.repeat],animations: {
                self.clickActionG.transform = CGAffineTransform(scaleX: 9, y: 9)
                self.clickActionG.alpha = 0
            })
            
            
        }
    }
    
    // バックグラウンド
    func viewDidEnterBackground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            print("バックグラウンド")
            if(appDelegate.backNiftyTime == true){
                print("niftyTimerを削除")
                
                if(appDelegate.niftyTimer.isValid == true){
                    
                    appDelegate.niftyTimer.invalidate()
                    appDelegate.backNiftyTime = false
                    
                }
            }
            else{
                
                print("まだniftyTimerは作動していない")
            }
            
        }
    }
    
    
    // バーガーボタンが押された時の処理
    @IBAction func menuClick(_ sender: UIButton) {
        
        guard let rootViewController = rootViewController() else { return }
        rootViewController.presentMenuViewController()
    }
    
    
    // 追加ボタンのクリック処理
    func SearchaddiPhone(sender:UIButton){
        
        // データがあるなら
        if(dataArray.count > 0){
            
            
            if(SearchiPhoneBool == true){
                
                // はじめは0要素目の値を入れる
                if(appDelegate.SelectiPhone == "" && dataArray != nil){
                    appDelegate.SelectiPhone = dataArray[0] as! String
                    appDelegate.keyValue = keyArray[0] as! String
                }
                
                SearchiPhoneBool = false
                
                
                ImgAddWindowView.animationImages = ImgAddWindowArray
                BtnAdd.imageView?.startAnimating()
                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
                    self.ImgAddWindowView.alpha = 1.0
                    
                }) { _ in
                    self.ImgAddWindowView.startAnimating()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.BtnLost.isHidden = false
                    self.BtnAdd.isHidden = true
                }
                
                /************************* 端末選択UIWindow *************************/
                selectWindow.backgroundColor = UIColor.clear
                selectWindow.frame = CGRect(x:0, y:0, width:x/1.5, height:y/2.5)
                selectWindow.layer.position = CGPoint(x:self.view.frame.width/2, y:self.view.frame.height/2)
                selectWindow.alpha = 0
                selectWindow.layer.cornerRadius = x/10
                selectWindow.makeKey()
                self.selectWindow.makeKeyAndVisible()
                
                
                // 端末を追加するUIWindowを表示
                UIWindow.animate(withDuration: 1.0, delay: 0, options: [.curveEaseIn], animations: {
                    self.selectWindow.alpha = 1.0
                }, completion: nil)
                
                let wx = selectWindow.frame.width
                let wy = selectWindow.frame.height
                
                databasePicker.isHidden = false
                
                // 閉じるボタンで選択することを教えるラベル
                addDeviceExplain = LTMorphingLabel(frame: CGRect(x: wx/2 - wx/2.3, y: wy/1.2, width: wx, height: wy/20))
                addDeviceExplain.textColor = UIColor.black
                addDeviceExplain.font = UIFont.systemFont(ofSize: wx/20)
                addDeviceExplain.text = "選択したら閉じるボタンを押してください"
                addDeviceExplain.shadowColor = UIColor.gray
                addDeviceExplain.textAlignment = NSTextAlignment.center
                self.selectWindow.addSubview(addDeviceExplain)
                
                // 相手の名前を入力するtextField
                nameTextField = UITextField(frame: CGRect(x: wx/2 - wx/3, y: wy/1.7, width: wx/1.5, height: wy/8))
                nameTextField.tag = 1
                nameTextField.text = "\(dataArray[0])"
                nameTextField.delegate = self
                nameTextField.isEnabled = false
                nameTextField.textAlignment = .center
                nameTextField.borderStyle = .roundedRect
                nameTextField.clearButtonMode = .whileEditing
                self.selectWindow.addSubview(nameTextField)
                
                
            }
            else if(SearchiPhoneBool == false){
                
                SearchiPhoneBool = true
                
                ImgAddWindowView.animationImages = ImgEndWindowArray
                self.ImgAddWindowView.startAnimating()
                BtnLost.imageView?.startAnimating()
                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
                    self.ImgAddWindowView.alpha = 0.0
                }, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.BtnLost.isHidden = true
                    self.BtnAdd.isHidden = false
                }
                
                appDelegate.viewLeader = 0
                
                SearchLabel.text = appDelegate.SelectiPhone + "さんを選択しました。"
                
                UIWindow.animate(withDuration: 1.0, delay: 0, options: [.curveEaseIn], animations: {
                    self.selectWindow.alpha = 0
                }, completion: nil)
                
                
                print("接続キー = \(appDelegate.keyValue)")
                
                // ここに選択した端末をラベルに表示する
                
                databasePicker.isHidden = true
                
            }
            
        }
            // データが空なら
        else{
            
            let alert:UIAlertView? = UIAlertView(title: "端末が登録されていません",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
            alert?.show()
        }
        
    }
    
    /*********************************** ボタン ***********************************/
    func clickButton(sender:UIButton){
        
        // 探索開始
        if(sender.tag == 1){
            print("SelectiPhone = \(appDelegate.SelectiPhone)")
            
            if(appDelegate.SearchButtonBool == true && appDelegate.SelectiPhone != ""){
                
                // 発信開始のデリゲート
                appDelegate.myPheripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                
                
                
            }
                
                // 探索開始を終了するボタンをクリックした処理
            else if(appDelegate.SearchButtonBool == false){
                print("探索終了")
                //探索or発信終了とアニメーションなどのアクションを終了する
                SearchLabel.text = ""
                appDelegate.SearchButtonBool = true
                onlyoneBool = true
                
                
                if(myimageview.isHidden == true){
                    myimageview.isHidden = false
                }
                
                // レーダーの色を隠す
                //clickAction.isHidden = true
                
                clickActionR.isHidden = true
                clickActionR1.isHidden = true
                clickActionR2.isHidden = true
                clickActionR3.isHidden = true
                clickActionR4.isHidden = true
                clickActionB.isHidden = true
                clickActionO.isHidden = true
                clickActionY.isHidden = true
                clickActionGr.isHidden = true
                clickActionB.isHidden = true
                clickActionG.isHidden = true
                
                BtnSearchStop.imageView?.startAnimating()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.BtnSearchStop.isHidden = true
                    self.BtnSearchStart.isHidden = false
                }
                
                stopPlay()
                
                if(appDelegate.niftyTimer.isValid == true){
                    
                    appDelegate.niftyTimer.invalidate()
                    appDelegate.backNiftyTime = false
                }
                
                if(appDelegate.iPhoneTimer.isValid == true){
                    
                    appDelegate.iPhoneTimer.invalidate()
                }
                
                distanceLabel.text = "未接続"
                distanceLabel.textColor = UIColor.black
                distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
                appDelegate.findBool = false
                
                appDelegate.myPheripheralManager.stopAdvertising()
                
                appDelegate.viewLeader = 0
                
            }
                
            else if(appDelegate.SelectiPhone == ""){
                SearchLabel.text = "⚠️端末を追加してください⚠️"
                
            }
            
        }
        
    }
    
    // 画面遷移完了時に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.locationManager?.stopMonitoring(for: self.beaconRegion!)
        clickActionR1.isHidden = true
        clickActionR2.isHidden = true
        clickActionR3.isHidden = true
        clickActionR4.isHidden = true
        clickActionR.isHidden = true
        clickActionO.isHidden = true
        clickActionY.isHidden = true
        clickActionGr.isHidden = true
        clickActionB.isHidden = true
        clickActionG.isHidden = true
    }
    
    /*
     改行ボタンが押された際に呼ばれる
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        print("textFieldShouldReturn \(textField.text!)")
        
        if(textField.tag == 1){
            
        }
        
        if(textField.tag == 2){
            
        }
        
        if(textField.tag == 3){
            
        }
        
        // 改行ボタンが押されたらKeyboardを閉じる処理.
        textField.resignFirstResponder()
        
        return true
    }
    
    
    
    
    
    
    // GPSから値を取得した際に呼び出されるメソッド.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        print("GPS!")
        
        // 配列から現在座標を取得
        let myLocations: NSArray = locations as NSArray
        let myLastLocation: CLLocation = myLocations.lastObject as! CLLocation
        var myLocation:CLLocationCoordinate2D = myLastLocation.coordinate
        
        print("現在地 = \(myLocation.latitude), \(myLocation.longitude)")
        print("相手 = \(appDelegate.mylatitude), \(appDelegate.mylongitude)")
        
        myLatitude = myLocation.latitude
        myLongitude = myLocation.longitude
        /*
        userDefault.set(myLocation.latitude, forKey: "myLatitude")
        userDefault.set(myLocation.longitude, forKey: "myLongitude")
        
        if(appDelegate.firstBool == false){
            
            // 端末情報を扱うNCMBInstallationのインスタンスを作成
            let installation = NCMBInstallation.current()
            
            // 自分の緯度・経度を保存
            installation?.setObject(myLocation.latitude, forKey: "latitude")
            installation?.setObject(myLocation.longitude, forKey: "longitude")
            
            // 端末情報をデータストアに登録
            installation?.saveInBackground({ (error) in
                if error != nil {
                    // 登録に失敗した時の処理
                    print("登録に失敗")
                    
                } else {
                    // 端末情報の登録に成功した時の処理
                    print("登録に成功")
                    self.appDelegate.firstBool = true
                }
            })
        }
        
        */
        
    }
    
    
    // 認証が変更された時に呼び出されるメソッド.
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status{
        case .authorizedWhenInUse:
            print("AuthorizedWhenInUse")
        case .authorized:
            print("Authorized")
        case .denied:
            print("Denied")
        case .restricted:
            print("Restricted")
        case .notDetermined:
            print("NotDetermined")
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // pickerに表示する行数を返すデータソースメソッド
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    
    // pickerに表示する値を返すデリゲートメソッド
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataArray[row] as? String
    }
    
    
    // pickerが選択された際に呼ばれるデリゲートメソッド.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        print("row: \(row)")
        print("value: \(dataArray[row])")
        
        // databasePickerView
        if(pickerView.tag == 1){
            
            nameTextField.text = dataArray[row] as! String
            appDelegate.SelectiPhone = "\(dataArray[row] as! String)"
            appDelegate.keyValue = keyArray[row] as! String
            
        }
        
        
    }
    
    
    
    // 音を再生
    func startPlay() {
        print("DateCount = \(DateCount)")
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        // 音を再生する
        if(DateCount <= 5){
            
            
            if(AudioRate != 0){
                print("AudioRate = \(AudioRate)")
                print("パンパン")
                myAudioPlayer.delegate = self
                
                myAudioPlayer.enableRate = true
                
                myAudioPlayer.rate = AudioRate
                
                
                myAudioPlayer.play()
            }
            
        }
        else if(DateCount >= 6){
            
            if(AudioRate != 0){
                
                audioUnitTimePitch = AVAudioUnitTimePitch()
                audioEngine.attach(audioUnitTimePitch)
                
                print("Selectvalue = \(DateCount - 5)")
                print("ohono-")
                let file_name = "music" + "\(String(DateCount - 5))" + ".wav"
                
                if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask).first {
                    
                    let path_file_name = dir.appendingPathComponent( file_name )
                    
                    print(path_file_name)
                    do {
                        let text = try AVAudioFile(forReading: path_file_name)
                        print(text)
                        self.audioFile = text
                        print("清水")
                    } catch let error{
                        print(error)
                        //エラー処理
                    }
                }
                
                
                
                audioUnitTimePitch.rate = AudioRate
                self.audioEngine.connect(audioFilePlayer, to: audioUnitTimePitch, format: audioFile.processingFormat)
                self.audioEngine.connect(audioUnitTimePitch, to: mixer, format: audioFile.processingFormat)
                self.audioFilePlayer.scheduleSegment(audioFile,
                                                     startingFrame: AVAudioFramePosition(0),
                                                     frameCount: AVAudioFrameCount(self.audioFile.length),
                                                     at: nil,
                                                     completionHandler: nil)
                
                let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
                
                do {
                    print("read")
                    try audioFile.read(into: buffer)
                } catch _ {
                }
                
                self.audioFilePlayer.scheduleBuffer(buffer, completionHandler: {
                    print("Complete")
                    self.recordBool = false
                })
                
                
                //completionHandlerは完全に再生されたか停止した後に呼ばれる
                try! self.audioEngine.start()
                self.audioFilePlayer.play()
            }
            
            
        }
        
    }
    
    
    func stopPlay() {
        
        recordBool = false
        if(DateCount <= 5){
            
            if (myAudioPlayer.isPlaying) {
                // サウンドの停止
                print("isPlaying = \(myAudioPlayer)")
                myAudioPlayer.stop()
               // try! AVAudioSession.sharedInstance().setActive(false)
                //     niftyTimer.invalidate()
            }
            else{
                
            }
        }
            
        else if(DateCount >= 6){
            if self.audioFilePlayer != nil && self.audioFilePlayer.isPlaying {
                self.audioFilePlayer.stop()
            }
            self.audioEngine.stop()
            try! AVAudioSession.sharedInstance().setActive(false)
            //niftyTimer.invalidate()
            
        }
    }
    
    
    // 発信デリゲードメソッド
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
            
            // iBeaconのUUID.
            let myProximityUUID = NSUUID(uuidString: "C7B7070C-2F91-44A4-9EB1-50F970C21FA1")
            
            // 追加で選んだIdentifierを入れる
            let myIdentifier = appDelegate.keyValue
            print("keyValue = \(myIdentifier)")
            
            // Major.
            let myMajor : CLBeaconMajorValue = 1
            
            // Minor.
            let myMinor : CLBeaconMinorValue = 1
            
            // BeaconRegionを定義.
            let myBeaconRegion = CLBeaconRegion(proximityUUID: myProximityUUID! as UUID, major: myMajor, minor: myMinor, identifier: myIdentifier!)
            
            // Advertisingのフォーマットを作成.
            let myBeaconPeripheralData = NSDictionary(dictionary: myBeaconRegion.peripheralData(withMeasuredPower: nil))
            
            // Advertisingを発信.
            appDelegate.myPheripheralManager.startAdvertising(myBeaconPeripheralData as? [String : Any])
            
            
            appDelegate.iPhoneTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector:#selector(leaderViewController.moveFindiPhone(_:)), userInfo: nil, repeats: true)
            
            // niftyからデータを読み込むタイマー
            appDelegate.niftyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(leaderViewController.distance(_:)), userInfo: nil, repeats: true)
            appDelegate.backNiftyTime = true
            
            //bluetooth通信について（bluetoothで通信を開始して、これで通信ができない場合はプッシュ通知を使ってmapで表示をして探索するようにする）
            //最初にプッシュ通知で相手に探索開始というプッシュ通知が送信されて相手の位置情報送信する
            
            BtnSearchStart.imageView?.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.BtnSearchStop.isHidden = false
                self.BtnSearchStart.isHidden = true
            }
            
            clickActionR.isHidden=true
            clickActionB.isHidden=true
            clickActionO.isHidden=true
            clickActionY.isHidden=true
            clickActionGr.isHidden=true
            clickActionB.isHidden=true
            clickActionG.isHidden=true
            appDelegate.SearchButtonBool = false
            
            self.SearchLabel.text = appDelegate.SelectiPhone + "さんの端末を探しています"
            
            
            
        }
        
    }
    
    
    /****************************** iBeacon ******************************/
    // 領域観測が開始した場合
    func locationManager(_ manager: CLLocationManager!, didStartMonitoringFor region: CLRegion!) {
        
        print("監視開始")
        
    }
    
    // 領域に侵入した場合
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if(region is CLBeaconRegion && CLLocationManager.isRangingAvailable()) {
            print("侵入!開始")
            
            // iBeaconを開始する
            self.locationManager?.startRangingBeacons(in: region as! CLBeaconRegion)
            
        }
    }
    
    // 領域から退出した場合
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        print("領域から出たよ")
        
        if(region is CLBeaconRegion && CLLocationManager.isRangingAvailable()) {
            self.locationManager?.stopRangingBeacons(in: region as! CLBeaconRegion)
        }
    }
    
    // 領域内にいるかどうかの判断
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        switch(state) {
        case .inside:
            if(region is CLBeaconRegion && CLLocationManager.isRangingAvailable()) {
                
                self.locationManager?.startRangingBeacons(in: region as! CLBeaconRegion)
                print("配信開始！")
                
                // 端末情報を扱うNCMBInstallationのインスタンスを作成
                let installation = NCMBInstallation.current()
                
                // 探索開始を合図
                installation?.setObject("探索開始", forKey: "start")
                
                
                // 端末情報をデータストアに登録
                installation?.saveInBackground({ (error) in
                    
                    if error != nil {
                        print("保存成功")
                    }
                    else{
                        print("保存失敗 = \(error)")
                    }
                })
                
            }
            break
        case .outside:
            print("領域の外にいる")
            
            // 領域の外にいることを表す
            
            
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
            }
            else if(proximity == CLProximity.near) {
                rangeMessage = "ビーコンが比較的近くにある！"
            }
            else if(proximity == CLProximity.far) {
                rangeMessage = "ビーコンは遠くにあります。"
            }
            else if(proximity == CLProximity.unknown) {
                rangeMessage = "ビーコンが判定できなかった"
            }
            
            //self.str = "\(bAccuracy!) [m]" as NSString
            
            //self.userDefault.set(self.userNameTextField.text!, forKey: "userName")
            
            
            let distance = Double(bAccuracy!)
            print("distance == \(distance)")
            
            let installation = NCMBInstallation.current()
            // deviceTokenプロパティを設定
            installation?.deviceToken = userDefault.string(forKey: "myDeviceToken")
            // 設定されたdeviceTokenを元にデータストアからデータを取得
            installation?.fetchInBackground({ (error) in
                if error != nil {
                    // 取得に失敗した場合の処理
                    print("取得失敗")
                    self.distanceLabel.text = "データを読み込めません"
                    print("取得失敗 = \(error)")
                    self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
                }else{
                    // 取得に成功した場合の処理
                    // 指定フィールドの値をインクリメントする
                    
                    installation?.setObject(distance, forKey: "distance")
                    
                    installation?.saveInBackground({ (error) in
                        if error != nil {
                            // 更新に失敗した場合の処理
                            print("更新失敗")
                            
                            self.distanceLabel.text = "保存に失敗"
                            print("保存失敗 = \(error)")
                            self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
                        }else{
                            // 更新に成功した場合の処理
                            print("更新成功")
                            
                        }
                    })
                }
            })
            
            print("距離 = \(distance)")
            
            
        }
    }
    
    // 領域観測に失敗した場合
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        
        print("観測失敗")
        
    }
    
    // 位置情報の許可設定
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        print("位置情報の許可認定")
        if(status == .notDetermined) {
        } else if(status == .authorized) {
            
            beaconRegion?.notifyEntryStateOnDisplay = true
            self.locationManager?.startMonitoring(for: self.beaconRegion!)
            self.locationManager?.startRangingBeacons(in: self.beaconRegion!)
            print("監視開始")
            
        } else if(status == .authorizedWhenInUse) {
            
            beaconRegion?.notifyEntryStateOnDisplay = true
            // 指定された地域のビーコンの通知の配信を開始します。
            self.locationManager?.startMonitoring(for: self.beaconRegion!)
            self.locationManager?.startRangingBeacons(in: self.beaconRegion!)
            print("通知の配信開始")
            
        }
    }
    
    
    // niftyに保存された距離を読み込む
    func distance(_ timer: Timer) {
        
        // installationクラスを検索するNCMBQueryを作成
        let query = NCMBInstallation.query()
        
        // 接続キーが格納されているconnectを条件に入れる
        query?.whereKeyExists("connect")
        
        // データストアの検索を実施
        do {
            let points = try query?.findObjects()
            for point in points as! [installation] {
                
                // 選択した端末の接続キーと同じところの距離を取得する
                if(point.connection! == appDelegate.keyValue){
                    // 距離を取得
                    self.deviceDistance = point.distance!
                    print("deviceDistance = \(deviceDistance)")
                    
                    // 四捨五入して入れる
                    numRound = (round((deviceDistance)*100)/100)
                    
                    
                    
                    if(numRound != -1){
                        
                        
                        
                        //distanceLabel.text = "距離:\(numRound * 100) [cm]"
                        //self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/12)
                        appDelegate.findBool = true
                        
                    }
                    else{
                        
                        appDelegate.findBool = false
                    }
                    
                    if(self.deviceDistance * 100 >= 1000) {
                        
                        clickActionR.isHidden=true
                        clickActionR1.isHidden = true
                        clickActionR2.isHidden = true
                        clickActionR3.isHidden = true
                        clickActionR4.isHidden = true
                        clickActionO.isHidden=true
                        clickActionY.isHidden=true
                        clickActionGr.isHidden=true
                        clickActionB.isHidden=true
                        clickActionG.isHidden=false
                        self.appDelegate.viewLeader = 6
                        self.AudioRate = 1.0
                        
                        
                        distanceLabel.text = "離れすぎています"
                        distanceLabel.textColor = UIColor.darkGray
                        self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
                        
                    }
                    else if(self.deviceDistance * 100 < 1000 && self.deviceDistance * 100 >= 700){
                        
                        clickActionR.isHidden=true
                        clickActionR1.isHidden = true
                        clickActionR2.isHidden = true
                        clickActionR3.isHidden = true
                        clickActionR4.isHidden = true
                        clickActionO.isHidden=true
                        clickActionY.isHidden=true
                        clickActionGr.isHidden=true
                        clickActionB.isHidden=false
                        clickActionG.isHidden=true
                        self.appDelegate.viewLeader = 5
                        self.AudioRate = 2.0
                        distanceLabel.text = "すごく遠いです"
                        distanceLabel.textColor = UIColor.blue
                        self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
                    }
                    else if(self.deviceDistance * 100 < 700 && self.deviceDistance * 100 >= 500){
                        clickActionR.isHidden=true
                        clickActionR1.isHidden = true
                        clickActionR2.isHidden = true
                        clickActionR3.isHidden = true
                        clickActionR4.isHidden = true
                        clickActionO.isHidden=true
                        clickActionY.isHidden=true
                        clickActionGr.isHidden=false
                        clickActionB.isHidden=true
                        clickActionG.isHidden=true
                        self.appDelegate.viewLeader = 4
                        self.AudioRate = 3.5
                        distanceLabel.text = "まあまあ遠いです"
                        distanceLabel.textColor = UIColor.green
                        self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
                    }
                    else if(self.deviceDistance * 100 < 500 && self.deviceDistance * 100 >= 300){
                        
                        clickActionR.isHidden=true
                        clickActionR1.isHidden = true
                        clickActionR2.isHidden = true
                        clickActionR3.isHidden = true
                        clickActionR4.isHidden = true
                        clickActionO.isHidden=true
                        clickActionY.isHidden=false
                        clickActionGr.isHidden=true
                        clickActionB.isHidden=true
                        clickActionG.isHidden=true
                        self.appDelegate.viewLeader = 3
                        self.AudioRate = 5.0
                        distanceLabel.text = "少し遠いです"
                        distanceLabel.textColor = UIColor.yellow
                        self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
                    }
                    else if(self.deviceDistance * 100 < 300 && self.deviceDistance * 100 >= 100){
                        
                        clickActionR.isHidden=true
                        clickActionR1.isHidden = true
                        clickActionR2.isHidden = true
                        clickActionR3.isHidden = true
                        clickActionR4.isHidden = true
                        clickActionO.isHidden=false
                        clickActionY.isHidden=true
                        clickActionGr.isHidden=true
                        clickActionB.isHidden=true
                        clickActionG.isHidden=true
                        self.appDelegate.viewLeader = 2
                        self.AudioRate = 7.5
                        distanceLabel.text = "少し近いです"
                        distanceLabel.textColor = UIColor.orange
                        self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
                    }
                    else if(self.deviceDistance * 100 < 100 && self.deviceDistance * 100 >= 0){
                        
                        
                        if(self.deviceDistance * 100 > 80){
                            clickActionR.isHidden = false
                            clickActionR1.isHidden = true
                            clickActionR2.isHidden = true
                            clickActionR3.isHidden = true
                            clickActionR4.isHidden = true
                            distanceLabel.text = "近いです"
                            distanceLabel.textColor = UIColor.red
                            self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
                            //self.clickActionR.layer.duration = 0.5
                            self.AudioRate = 8.0
                        }
                        else if(self.deviceDistance * 100 > 60){
                            
                            clickActionR.isHidden = true
                            clickActionR1.isHidden = true
                            clickActionR2.isHidden = true
                            clickActionR3.isHidden = true
                            clickActionR4.isHidden = false
                            distanceLabel.text = "結構近いです！"
                            distanceLabel.textColor = UIColor.red
                            self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
                            self.AudioRate = 9.0
                        }
                        else if(self.deviceDistance * 100 > 40){
                            
                            clickActionR.isHidden = true
                            clickActionR1.isHidden = true
                            clickActionR2.isHidden = true
                            clickActionR3.isHidden = false
                            clickActionR4.isHidden = true
                            distanceLabel.text = "すごく近いです！！"
                            distanceLabel.textColor = UIColor.red
                            self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
                            self.AudioRate = 10.0
                        }
                        else if(self.deviceDistance * 100 > 20){
                            
                            clickActionR.isHidden = true
                            clickActionR1.isHidden = true
                            clickActionR2.isHidden = false
                            clickActionR3.isHidden = true
                            clickActionR4.isHidden = true
                            distanceLabel.text = "めちゃくちゃ近いです！！！"
                            distanceLabel.textColor = UIColor.red
                            self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
                            self.AudioRate = 11.0
                            
                        }
                        else{
                            
                            clickActionR.isHidden = true
                            clickActionR1.isHidden = false
                            clickActionR2.isHidden = true
                            clickActionR3.isHidden = true
                            clickActionR4.isHidden = true
                            distanceLabel.text = "もう目の前にあります！！！"
                            distanceLabel.textColor = UIColor.red
                            self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
                            self.AudioRate = 12.0
                        }
                        
                        clickActionO.isHidden=true
                        clickActionY.isHidden=true
                        clickActionGr.isHidden=true
                        clickActionB.isHidden=true
                        clickActionG.isHidden=true
                        self.appDelegate.viewLeader = 1
                        
                    }
                        
                    else if(self.deviceDistance == -1.0){
                        clickActionR.isHidden=true
                        clickActionR1.isHidden = true
                        clickActionR2.isHidden = true
                        clickActionR3.isHidden = true
                        clickActionR4.isHidden = true
                        clickActionO.isHidden=true
                        clickActionY.isHidden=true
                        clickActionGr.isHidden=true
                        clickActionB.isHidden=true
                        clickActionG.isHidden=true
                        self.AudioRate = 0
                        
                        distanceLabel.text = "受信中です"
                        distanceLabel.textColor = UIColor.black
                        distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
                        
                    }
                    
                    print("AudioRate = \(AudioRate)")
                    print("recordBool = \(recordBool)")
                    if(recordBool == false){
                        print("再生")
                        if(AudioRate != 0){
                            
                            startPlay()
                            recordBool = true
                        }
                    }
                    
                    
                }
                else{
                    print("ない")
                }
            }
            
            
            
        }
        catch {
            print("失敗: \(error)")
            distanceLabel.text = "読み取りに失敗しました"
            self.distanceLabel.layer.position = CGPoint(x: self.x/2, y: self.y/2 + self.y/8)
            
        }
        
        
        
    }
    
    
    func receveStart(_ time: Timer){
        
        if self.userDefault.bool(forKey: "deviceTokenFirst") != true {
            
            if(CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)) {
                
                self.locationManager = CLLocationManager()
                self.locationManager?.delegate = self
                
                // 取得制度を最高にする！！！
                self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                
                // 取得頻度の設定(1mごとに位置情報取得)
                self.locationManager?.distanceFilter = 0.1
                
                // UUIDの指定
                self.proximityUUID = NSUUID(uuidString: "C7B7070C-2F91-44A4-9EB1-50F970C21FA1")
                
                self.beaconRegion = CLBeaconRegion(proximityUUID: self.proximityUUID! as UUID, major: CLBeaconMajorValue(1), minor: CLBeaconMinorValue(1), identifier: userDefault.string(forKey: "myConnectKey")!)
                
                self.beaconRegion?.notifyOnEntry = true
                
                // 退域通知の設定.
                self.beaconRegion?.notifyOnExit = true
                
                let status = CLLocationManager.authorizationStatus()
                if status == CLAuthorizationStatus.notDetermined {
                    self.locationManager?.requestAlwaysAuthorization()
                } else {
                    
                    // 指定された領域の監視を開始します
                    self.locationManager?.startMonitoring(for: self.beaconRegion!)
                    print("監視を開始")
                    time.invalidate()
                }
                
                
            }
            else {
                
                let alert:UIAlertView? = UIAlertView(title: "確認",message: "お使いの端末ではiBeaconを利用できません。", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                alert?.show()
            }
            
        }
        else{
            print("登録できなかった")
        }
        
    }
    
    // 20秒待っても繋がらないならiPhoneを探すでiPhone探す
    func moveFindiPhone(_ timer:Timer){
        
        
        if(appDelegate.findBool != true){
            
            //        ① コントローラーの実装
            let alertController = UIAlertController(title: "iPhoneを検知できません",message: "iPhoneを探すを開きますか？", preferredStyle: UIAlertControllerStyle.alert)
            
            //        ②-1 OKボタンの実装
            let okAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
                
                //        ②-2 OKがクリックされた時の処理
                // iPhoneTimerを消す
                if(self.appDelegate.iPhoneTimer.isValid == true){
                    print("iPhoneTimerを削除")
                    self.appDelegate.iPhoneTimer.invalidate()
                }
                
                let url = URL(string: "fmip1://")!
                if UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: {
                            (success) in
                            print("Open \(success)")
                        })
                    }else{
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            //        CANCELボタンの実装
            let cancelButton = UIAlertAction(title: "いいえ", style: UIAlertActionStyle.cancel, handler: nil)
            
            //        ③-1 ボタンに追加
            alertController.addAction(okAction)
            //        ③-2 CANCELボタンの追加
            alertController.addAction(cancelButton)
            
            //        ④ アラートの表示
            present(alertController,animated: true,completion: nil)
            
        }
    }
    
    
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("再生秋雨量")
        recordBool = false
        startPlay()
    }
    
}

extension UIImage{
    
    // Resizeするクラスメソッド.
    func ResizeÜIImage(width : CGFloat, height : CGFloat)-> UIImage!{
        
        // 指定された画像の大きさのコンテキストを用意.
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        
        // コンテキストに自身に設定された画像を描画する.
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // コンテキストからUIImageを作る.
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // コンテキストを閉じる.
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

