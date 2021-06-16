//
//  AppDelegate.swift
//  iPhoneレーダー
//
//  Created by 清水直輝 on 2017/07/24.
//  Copyright © 2017年 平子英樹. All rights reserved.
//

import UIKit
import NCMB
import UserNotifications
import CoreLocation
import CoreBluetooth
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    
    // バックグラウンド処理に使う
    var backgroundTaskID : UIBackgroundTaskIdentifier = 0
    
    // アプリケーションキー
    var applicationKey = "ed3cd360e6c20123babdd4a6db5201c74f5517dc88e087b19e38fd46dbf2e8dc"
    
    // クライアントキー
    var clientKey = "dd610fce9ff2e9f72e138951f4b99dfa0c44010d379463bbe1cded65b4d30d1b"
    
    // 保存変数
    let saveVariable = UserDefaults.standard
    
    var firstBool : Bool = false
    
    
    /******************** leaderView ********************/
    var timer: Timer!
    var niftyTimer: Timer!
    var receveTimer: Timer!
    var iPhoneTimer: Timer!
    
    // 発信
    var myPheripheralManager : CBPeripheralManager!
    
    var SearchButtonBool : Bool! = true
    
    // 端末の名前を入れる変数
    var SelectiPhone : String! = ""
    
    // デバイストークンを入れる変数
    var iPhoneToken : String! = ""
    var keyValue: String! = ""
    
    var findBool: Bool = false
    var backNiftyTime: Bool = false
    
    /******************** childView ********************/
    
    var addButtonM: Bool = true
    var dispatchBool: Bool = true
    var receveBool: Bool = true
    
    var ble1: Bool = true
    var ble2: Bool = true
    
    var connectW: Bool = true
    
    var childPheripheralManager : CBPeripheralManager!
    
    /******************** 位置情報 ********************/
    
    //プッシュ通知から送られてきた座標の代入
    var mylatitude : Double!
    //プッシュ通知から送られてきた座標の代入
    var mylongitude : Double!
    
    // 位置情報を取得してからプッシュ通知を送るための変数
    var searchBool : Bool = false
    // プッシュ通知の内容が「探索開始」、「緯度経度かを分けるための変数」
    var puchCount : Bool = true
    // 探索開始を合図する変数
    var searchStart : Bool = false
    
    var myLocationManager: CLLocationManager!
    
    var SelectMusic : String! = nil
    
    var viewLeader:Int = 0
    
    
    
    // アプリ起動時に呼ばれる
    // アプリ未起動時にプッシュ通知をタップしたら呼ばれる
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        createTable()
        
        //********** SDKの初期化 **********
        NCMB.setApplicationKey(applicationKey, clientKey: clientKey)
        
        installation.registerSubclass()
        
        
        // デバイストークンを初回起動時に作れたらそれ以降は作らないようにするためのuserdefault
        let dic = ["deviceTokenFirst": true]
        self.saveVariable.register(defaults: dic)
        
        // デバイストークンの要求
        if #available(iOS 10.0, *){
            
            UNUserNotificationCenter.current().delegate = self
            
            /** iOS10以上 **/
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .badge, .sound]) {granted, error in
                if error != nil {
                    // エラー時の処理
                    return
                }
                if granted {
                    
                    // デバイストークンの要求
                    if self.saveVariable.bool(forKey: "deviceTokenFirst") {
                        
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    else{
                        
                        let installation = NCMBInstallation.current()
                        // deviceTokenプロパティを設定
                        installation?.deviceToken = self.saveVariable.string(forKey: "myDeviceToken")
                        // 設定されたdeviceTokenを元にデータストアからデータを取得
                        installation?.fetchInBackground({ (error) in
                            if error != nil {
                                // 取得に失敗した場合の処理
                                print("取得失敗")
                            }else{
                                // 取得に成功した場合の処理
                                // 指定フィールドの値をインクリメントする
                                
                                installation?.setObject("未探索", forKey: "start")
                                installation?.setObject(-1, forKey: "distance")
                                
                                installation?.saveInBackground({ (error) in
                                    if error != nil {
                                        // 更新に失敗した場合の処理
                                        print("失敗しました")
                                        
                                    }else{
                                        // 更新に成功した場合の処理
                                        print("また未探索に戻しておく")
                                    }
                                })
                            }
                        })
                    }
                    
                }
            }
        } else {
            /** iOS8以上iOS10未満 **/
            //通知のタイプを設定したsettingを用意
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            //通知のタイプを設定
            application.registerUserNotificationSettings(setting)
            //DevoceTokenを要求
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        // LocationManagerの生成
        myLocationManager = CLLocationManager()
        
        // Delegateの設定
        myLocationManager.delegate = self
        
        // 距離のフィルタ
        myLocationManager.distanceFilter = 100.0
        
        // 精度
        myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示
        if(status != CLAuthorizationStatus.authorizedAlways) {
            
            // まだ承認が得られていない場合は、認証ダイアログを表示
            myLocationManager.requestAlwaysAuthorization()
            myLocationManager?.allowsBackgroundLocationUpdates = true
        }
        
        // 位置情報起因で起動した場合
        if launchOptions?[UIApplicationLaunchOptionsKey.location] != nil {
            
            myLocationManager.startMonitoringSignificantLocationChanges()
        }
        
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        return true
    }
    
    // デバイストークンが取得されたら呼び出されるメソッド
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        
        
        // 端末情報を扱うNCMBInstallationのインスタンスを作成
        let installation = NCMBInstallation.current()
        // デバイストークンの設定
        installation?.setDeviceTokenFrom(deviceToken)
        
        
        // 誰の端末かを保存
        installation?.setObject(UIDevice.current.name, forKey: "device")
        installation?.setObject(-1, forKey: "distance")
        installation?.setObject("未探索", forKey: "start")
        
        
        var randomKey : String = self.generate(length: 2)
        var overlap : Bool = false
        
        // installationクラスを検索するNCMBQueryを作成
        let query = NCMBInstallation.query()
        
        // 接続キーが格納されているconnectを条件に入れる
        query?.whereKeyExists("connect")
        
        // ランダムで生成した接続キーが被ればループする
        while true {
            
            // データストアの検索を実施
            do {
                let points = try query?.findObjects()
                for point in points as! [installation] {
                    
                    // ランダムで生成したキーがデータストアにあったら読み込まれる
                    if(point.connection! == randomKey){
                        // 既にキーが存在します
                        overlap = true
                    }
                    else{
                        // まだキーは存在してません
                        overlap = false
                    }
                    
                    print("データ：\(point.connection!)")
                    
                }
                
            } catch {
                print("失敗: \(error)")
            }
            
            // キーが重複しない時の処理
            if(overlap != true){
                
                // 接続キーの保存
                installation?.setObject(randomKey, forKey: "connect")
                
                break
            }
                // キーが重複した時の処理
            else{
                // ランダムキーを再生成する
                randomKey = self.generate(length: 2)
            }
        }
        
        // 端末情報をデータストアに登録
        installation?.saveInBackground({ (error) in
            if error != nil {
                // 端末情報の登録に失敗した時の処理
                let err = error! as NSError
                if (err.code == 409001){
                    // 失敗した原因がデバイストークンの重複だった場合
                    // 端末情報を上書き保存する
                    self.updateExistInstallation(currentInstallation: installation!)
                    print("重複しているため、上書き")
                    self.saveVariable.set(false, forKey: "deviceTokenFirst")
                    print("端末情報を上書き保存する")
                }else{
                    // デバイストークンの重複以外のエラーが返ってきた場合
                    print("重複じゃないエラー = \(String(describing: error))")
                    
                    
                    let alert:UIAlertView? = UIAlertView(title: "端末情報が登録できていません",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                    alert?.show()
                    
                }
            } else {
                // 端末情報の登録に成功した時の処理
                print("端末情報の登録に成功")
                
                /** 保存に成功したらuserdefaultで保存する **/
                // 次から起動してもデバイストークンを要求しないようにfalseにする
                self.saveVariable.set(false, forKey: "deviceTokenFirst")
                
                // 接続キーを保存
                self.saveVariable.set(randomKey, forKey: "myConnectKey")
                
                // 自分のデバイストークンを保存する
                self.saveVariable.set(installation?.deviceToken, forKey: "myDeviceToken")
                
            }
        })
        
        
        
    }
    
    // ランダムな文字列を作る関数(接続キーの生成に使う)
    func generate(length: Int) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            //randomString += "\(base[base.startIndex.advancedBy(Int(randomValue))])"
            
            /*
             return alphabet[alphabet.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(upperBound)))]
             */
            
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(arc4random_uniform(randomValue)))])"
            
            randomString += "\(base[base.startIndex])"
            
        }
        return randomString
    }
    
    // 端末情報を上書き保存するupdateExistInstallationメソッドを用意
    func updateExistInstallation(currentInstallation : NCMBInstallation){
        print("上書きメソッド")
        let installationQuery = NCMBInstallation.query()
        installationQuery?.whereKey("deviceToken", equalTo:currentInstallation.deviceToken)
        do {
            let searchDevice = try installationQuery?.getFirstObject() as! NCMBInstallation
            // 端末情報の検索に成功した場合
            // 上書き保存する
            currentInstallation.objectId = searchDevice.objectId
            currentInstallation.saveInBackground({ (error) in
                if (error != nil){
                    // 端末情報の登録に失敗した時の処理
                    print("端末の情報の登録に失敗")
                }else{
                    // 端末情報の登録に成功した時の処理
                    print("端末情報の登録に成功")
                }
            })
        } catch let searchErr as NSError {
            // 端末情報の検索に失敗した場合の処理
            print("端末情報の検索に失敗")
        }
    }
    
    
    // アプリがバックグラウンドになる直前に呼ばれる
    func applicationWillResignActive(_ application: UIApplication) {
        
        self.backgroundTaskID = application.beginBackgroundTask(){
            [weak self] in
            application.endBackgroundTask((self?.backgroundTaskID)!)
            self?.backgroundTaskID = UIBackgroundTaskInvalid
        }
    }
    
    // アプリがバックグラウンドになった時に呼ばれる
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            myLocationManager.startMonitoringSignificantLocationChanges()
        }
        print("バックグラウンドになる直後")
    }
    
    // アプリがフォアグラウンドになった時に呼ばれる
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        print("フォアグラウンド")
    }
    
    // アプリがアクティブになった時に呼ばれる
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        application.endBackgroundTask(self.backgroundTaskID)
    }
    
    // アプリが終了する直前に呼ばれる
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    // テーブルを作成する関数
    func createTable(){
        
        
        // DatabaseClassのtableに書いてる
        let db = FMDatabase(path: DatabaseClass().table)
        let db2 = FMDatabase(path: DatabaseClass().table2)
        let db3 = FMDatabase(path: DatabaseClass().table3)
        let db6 = FMDatabase(path: DatabaseClass().table6)
        let db7 = FMDatabase(path: DatabaseClass().table7)
        let db8 = FMDatabase(path: DatabaseClass().table8)
        
        let sql = "CREATE TABLE IF NOT EXISTS device (user_id INTEGER PRIMARY KEY, name TEXT, description TEXT);"
        let sql2 = "CREATE TABLE IF NOT EXISTS device2 (user_id INTEGER PRIMARY KEY, name TEXT, description TEXT);"
        let sql3 = "CREATE TABLE IF NOT EXISTS device3 (user_id INTEGER PRIMARY KEY, name TEXT, description TEXT);"
        let sql6 = "CREATE TABLE IF NOT EXISTS sample (user_id INTEGER PRIMARY KEY, name TEXT, description TEXT);"
        let sql7 = "CREATE TABLE IF NOT EXISTS sample2 (user_id INTEGER PRIMARY KEY, name TEXT, description TEXT);"
        let sql8 = "CREATE TABLE IF NOT EXISTS device8 (user_id INTEGER PRIMARY KEY, name TEXT, description TEXT);"
        
        db?.open()
        db2?.open()
        db3?.open()
        db6?.open()
        db7?.open()
        db8?.open()
        
        // SQL文を実行
        let ret = db?.executeUpdate(sql, withArgumentsIn: nil)
        let ret2 = db2?.executeUpdate(sql2, withArgumentsIn: nil)
        let ret3 = db3?.executeUpdate(sql3, withArgumentsIn: nil)
        let ret6 = db6?.executeUpdate(sql6, withArgumentsIn: nil)
        let ret7 = db7?.executeUpdate(sql7, withArgumentsIn: nil)
        let ret8 = db8?.executeUpdate(sql8, withArgumentsIn: nil)
        
        if ret! {
            print("テーブルの作成に成功")
        } else {
            print("テーブル作成に失敗")
        }
        
        if ret2! {
            print("テーブルの作成に成功")
        } else {
            print("テーブル作成に失敗")
        }
        
        if ret3! {
            print("テーブルの作成に成功")
        } else {
            print("テーブル作成に失敗")
        }
        
        if ret6! {
            print("テーブルの作成に成功")
        } else {
            print("テーブル作成に失敗")
        }
        
        if ret7! {
            print("テーブルの作成に成功")
        } else {
            print("テーブル作成に失敗")
        }
        
        if ret8! {
            print("テーブルの作成に成功")
        } else {
            print("テーブル作成に失敗")
        }
        
        db?.close()
        db2?.close()
        db3?.close()
        db6?.close()
        db7?.close()
        db8?.close()
    }
    
    
}

// UIColorをRGBで設定できるようにする
extension UIColor{
    class func rgb(r:Int,g:Int,b:Int,alpha: CGFloat)-> UIColor{
        return UIColor(red:CGFloat(r)/255.0,green:CGFloat(g)/255.0,blue:CGFloat(b)/255.0,alpha: alpha)
    }
}

// Stringに機能を追加
extension String {
    var lastPathComponent: String {
        get {
            return (self as NSString).lastPathComponent
        }
    }
    var pathExtension: String {
        get {
            return (self as NSString).pathExtension
        }
    }
    var stringByDeletingLastPathComponent: String {
        get {
            return (self as NSString).deletingLastPathComponent
        }
    }
    var stringByDeletingPathExtension: String {
        get {
            return (self as NSString).deletingPathExtension
        }
    }
    var pathComponents: [String] {
        get {
            return (self as NSString).pathComponents
        }
    }
    func stringByAppendingPathComponent(path: String) -> String {
        return (self as NSString).appendingPathComponent(path)
    }
    func stringByAppendingPathExtension(ext: String) -> String? {
        return (self as NSString).appendingPathExtension(ext)
    }
    
    /************************* 全角と半角を判別できる機能を実装 *************************/
    var isAllHalfWidthCharacter: Bool {
        
        // 半角も全角も1文字でカウント
        let nsStringlen = self.characters.count
        let utf8 = (self as NSString).utf8String
        
        // Cのstrlenは全角を2で判定する
        let cStringlen = Int(bitPattern: strlen(utf8))
        if nsStringlen == cStringlen {
            return true
        }
        
        return false
    }
    
    var isValidNickName: Bool {
        if rangeOfCharacter(from: .letters, options: .literal, range: nil) == nil { return false }
        if rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil { return false }
        
        guard self.isAllHalfWidthCharacter else { return false }
        return true
    }
    
}


// UIImageに画像をリサイズ
extension UIImage {
    
    // 画質を担保したままResizeするクラスメソッド.
    func ResizeUIImage(width : CGFloat, height : CGFloat)-> UIImage!{
        
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        var context = UIGraphicsGetCurrentContext()
        
        self.draw(in: CGRect(x:0, y:0, width:size.width, height:size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
        
        
        // 使い方
        // let resizeSelectedImage = UIImage(named: "hoge.png")!.ResizeUIImage(80, height: 80)
    }
    
}

/*
extension ViewController: CAAnimationDelegate {
    
    func animationDidStart(_ anim: CAAnimation) {
        //開始時
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if flag, let layer = anim.value(forKey: "blueView.layer") as? CALayer {
            layer.backgroundColor = UIColor.black.cgColor
            layer.removeAnimation(forKey: "cornerRadius")
        }
        
    }
    
}
*/

