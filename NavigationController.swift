//
//  NavigationController.swift
//  Core Bluetooth
//
//  Created by 清水直輝 on 2017/07/04.
//  Copyright © 2017年 清水直輝. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import LTMorphingLabel
import CoreBluetooth
import AVFoundation
import AudioToolbox


class navigationLeaderView: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,AVAudioPlayerDelegate  {
    
    var x: CGFloat!
    var y: CGFloat!
    
    // Tableで使用する配列を設定する
    var myItems : NSMutableArray! = []
    var FirstItems : NSMutableArray! = ["サンプル１","サンプル２","サンプル３","サンプル４","サンプル５"]
    let FileName : NSMutableArray! = ["サンプル1","サンプル2","サンプル3","サンプル4","サンプル5"]
    var myTableView : UITableView!
    var RegistrationButton : UIButton!
    var RegistrationBool : Bool! = true
    var SoundField : UITextField!
    var myWindow : UIWindow!
    var RecordingButton : UIButton!
    var RecordingLabel : UILabel!
    
    var indicatorView: UIActivityIndicatorView!
    var myAudioPlayer : AVAudioPlayer!
    var audioEngine : AVAudioEngine!
    var audioFile : AVAudioFile!
    var audioFilePlayer: AVAudioPlayerNode!
    var mixer : AVAudioMixerNode!
    var input : AVAudioInputNode!
    var filePath : NSURL? = nil
    var SelectValue : Int! = 0
    var SelectString : String! = ""
    var DateCount : Int! = 1
    var i : Int! = 5
    
    var SelectMusic : Int32! = 0
    var SelectMusicID : Int32! = 0
    var SelectMusicName : String! = ""
    
    var NoDate : Bool! = true
    
    // tableViewにチェックマークをつけるための変数
    var checkMarks : [Bool] = [false]
    
    // 保存変数
    let userDefault = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        x = self.view.frame.width
        y = self.view.frame.height
        
        self.title = "レーダーの音"
        
        self.view.backgroundColor = UIColor.lightGray
        
        //データベースの取得//
        
        /*プッシュ通知の使用一覧
         ①相手の端末の位置情報を得る
         ②送られてきた通知のメッセージの取得
         ③探索ボタンを押したら発信を通知送り受け取ったら開始する（相手の位置情報も送る）
         ④プッシュ通知の端末絞り込み
         */
        // Override point for customization after application launch.
        // ここに初期化処理を書く
        // UserDefaultsを使ってフラグを保持する
        // "firstSet"をキーに、Bool型の値を保持する
        let dict = ["firstSet": true]
        // デフォルト値登録
        // ※すでに値が更新されていた場合は、更新後の値のままになる
        userDefault.register(defaults: dict)
        
        // "firstSet"に紐づく値がtrueなら(=初回起動)、値をfalseに更新して処理を行う
        if userDefault.bool(forKey: "firstSet") {
            
            userDefault.set(false, forKey: "firstSet")
            
            print("初回起動の時だけ呼ばれるよ")
            print("INSERT")
            let db = FMDatabase(path: DatabaseClass().table6)
            let sql = "INSERT INTO sample (name) VALUES (?);"
            
            db?.open()
            for i in 0..<5{
                // ?で記述したパラメータの値を渡す場合
                db?.executeUpdate(sql, withArgumentsIn: [FirstItems[i]])
            }
            db?.close()
        }
        
        print("SELECT")
        let db = FMDatabase(path: DatabaseClass().table6)
        
        //let sql = "SELECT * FROM sample"
        let sql = "SELECT * FROM sample"
        // let sql = "SELECT user_name FROM sample ORDER BY user_id;"
        db?.open()
        
        let results = db?.executeQuery(sql, withArgumentsIn: nil)
        
        while (results?.next())! {
            
            // カラム名を指定して値を取得する方法
            let user_id = results?.int(forColumn: "user_id")
            
            // カラムのインデックスを指定して取得する方法
            let user_name = results?.string(forColumnIndex: 1)
            
            
            print("user_id = \(user_id!), user_name = \(user_name!)")
            
            myItems.add(user_name!)
            
            DateCount = Int(user_id!) - 4
            
        }
        
        db?.close()
        
        
        // 配列の要素数
        var arrayCount = myItems.count + FirstItems.count
        
        // 配列の要素分falseを追加する（チェックマークを保存するため）
        for i in 1..<arrayCount {
            
            checkMarks.append(false)
        }
        
        
        //データベースについて終わり//
        
        //録音に関する処理//
        self.audioFilePlayer = AVAudioPlayerNode()
        self.audioEngine = AVAudioEngine()
        self.audioEngine.attach(audioFilePlayer)
        self.input = audioEngine.inputNode
        self.mixer = audioEngine.mainMixerNode
        
        //ドメイン内の保存してあるデータの取得（すべてのデータ）
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        var fileNames: [String] {
            do {
                return try FileManager.default.contentsOfDirectory(atPath: documentPath)
            } catch {
                return []
            }
        }
        
        print(fileNames)
        
        //録音に関する処理（終了）//
        myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height:self.view.bounds.height / 1.3))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.layer.position = CGPoint(x:self.view.bounds.width / 2,y:self.view.bounds.height / 2.6)
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        
        // 録音した音を登録する保存
        RegistrationButton = UIButton()
        
        RegistrationButton.frame = CGRect(x:0,y:0,width:x/8,height:x/8)
        //RegistrationButton.layer.masksToBounds = true
        //RegistrationButton.layer.cornerRadius = 20
        RegistrationButton.layer.position = CGPoint(x:x/2,y:y + y / 12)
        //RegistrationButton.setTitle("登録", for: .normal)
        RegistrationButton.setTitleColor(UIColor.white, for: .normal)
        let resizeCloseImage = UIImage(named: "録音画像.png")!.ResizeUIImage(width: x/8, height: x/8)
        RegistrationButton.setImage(resizeCloseImage, for: UIControlState())
        //RegistrationButton.backgroundColor = UIColor.orange
        RegistrationButton.addTarget(self, action: #selector(navigationLeaderView.registrationClick(sender:)), for: .touchUpInside)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
            self.RegistrationButton.center.y -= self.view.bounds.width / 8 * 2
        }, completion: nil)
        self.view.addSubview(RegistrationButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio) != .authorized {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio,
                                          completionHandler: { (granted: Bool) in
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startRecord() {
        
        indicatorView.startAnimating()
        
        self.filePath = nil
        
        //self.isRec = true
        
        //録音と再生をできるように許可を出す
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        //録音と再生をできるように許可を出す
        try! AVAudioSession.sharedInstance().setActive(true)
        //形式に関わらずaudioファイルを読み書きするクラス（再生や録音したい音などを保存する場合に使う）
        //今回は再生したいファイルの指定
        //		self.audioFile = try! AVAudioFile(forReading: Bundle.main.url(forResource: "1K", withExtension: "mp3")!)
        
        //録音する際の詳細設定(共通フォーマットやサンプルレート、チャンネル数、読み書きの際にデータをランダムに並べて送りミスを少なくするinterleave)
        let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16,
                                   sampleRate: 44100.0,
                                   channels: 1,
                                   interleaved: true)
        
        audioEngine.connect(input!, to: mixer, format: input!.inputFormat(forBus: 0))
        
        //音声データをドメイン内にwav形式で保存する
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        print("\(myItems.count)")
        
        // 保存するファイルパス
        print("DateCount=\(DateCount)")
        filePath = NSURL(fileURLWithPath: dir + "/music" + "\(DateCount!)"+".wav")
        
        DateCount = DateCount + 1
        
        print("\(String(describing: filePath))")
        
        audioFile = try! AVAudioFile(forWriting: filePath! as URL, settings: format.settings)
        
        input!.volume = 0
        
        input!.installTap(onBus: 0, bufferSize: 4096, format: input?.inputFormat(forBus: 0)) { (buffer, when) in
            try! self.audioFile.write(from: buffer)
        }
        
        try! self.audioEngine.start()
    }
    
    func stopRecord() {
        
        indicatorView.stopAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // 2.0秒後に実行したい処理
            // self.isRec = false
            self.audioEngine.stop()
            self.input.removeTap(onBus: 0)
            self.mixer.removeTap(onBus: 0)
            self.audioEngine.inputNode?.removeTap(onBus: 0)
            self.audioFile = nil
            //try! AVAudioSession.sharedInstance().setActive(false)
        }
        
    }
    
    func registrationClick(sender:UIButton){
        
        if(RegistrationBool == true){
            
            sender.alpha = 1.0
            RegistrationButton.alpha = 1.0
            UIView.animate(withDuration: 0.5, delay: 0.1, options: [.curveEaseIn], animations: {
                sender.alpha = 0.0
                self.RegistrationButton.alpha = 0.0
            }, completion: { (Bool) in
                
                self.view.addSubview(self.RegistrationButton)
                UIView.animate(withDuration: 0.5, delay: 0.1, options: [.curveEaseIn], animations: {
                    self.RegistrationButton.alpha = 1.0
                    self.RegistrationButton.alpha = 1.0
                }, completion: nil)
                
            })
            
            UIView.transition(with: RegistrationButton, duration: 1.0, options: [.transitionFlipFromTop], animations: nil, completion: nil)
            
            // 背景をオレンジに設定する.
            myWindow = UIWindow()
            myWindow.frame = CGRect(x:0,y:0,width:self.view.bounds.width,height:self.view.bounds.height)
            myWindow.layer.position = CGPoint(x:self.view.frame.width/2, y:0 - self.view.frame.height/2)
            myWindow.alpha = 0.8
            myWindow.backgroundColor = UIColor.orange
            myWindow.layer.cornerRadius = 20
            myWindow.makeKey()
            self.myWindow.makeKeyAndVisible()
            
            // 上から降ってくるアニメーション
            UIWindow.animate(withDuration: 1.0, delay: 0.0, options: . transitionCrossDissolve, animations: {
                self.myWindow.center.y = self.myWindow.bounds.height/2
            }, completion: nil)
            
            // 録音開始するボタン
            RecordingButton = UIButton()
            RecordingButton.frame = CGRect(x:0,y:0,width:self.view.bounds.width / 2,height:self.view.bounds.height / 8)
            RecordingButton.layer.masksToBounds = true
            RecordingButton.layer.cornerRadius = 20
            RecordingButton.layer.position = CGPoint(x:self.view.bounds.width / 2,y:self.view.bounds.height / 1.5)
            RecordingButton.setTitle("録音", for: .normal)
            RecordingButton.setTitleColor(UIColor.white, for: .normal)
            RecordingButton.backgroundColor = UIColor.red
            RegistrationButton.isHidden = true
            RecordingButton.tag = 1
            RecordingButton.addTarget(self, action: #selector(navigationLeaderView.onClickMyButton(sender:)), for: .touchUpInside)
            myWindow.addSubview(RecordingButton)
            
            // 録音ボタンの説明ラベル
            RecordingLabel = UILabel()
            RecordingLabel.font = UIFont.boldSystemFont(ofSize: x/20)
            RecordingLabel.frame = CGRect(x:0,y:0,width:self.view.bounds.width / 1.1,height:self.view.bounds.height / 10)
            RecordingLabel.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height / 3)
            RecordingLabel.text = "再生ボタンを押すと録音が開始されます"
            //RecordingLabel.backgroundColor = UIColor.gray
            RecordingLabel.textColor = UIColor.white
            myWindow.addSubview(RecordingLabel)
            
            
            var closeButton = ZFRippleButton()
            closeButton.setTitle("閉じる",for: .normal)
            closeButton.setTitleColor(UIColor.white, for: .normal)
            closeButton.setTitleColor(UIColor.gray, for: .highlighted)
            let topColor = UIColorFromRGB(rgbValue: 0xff0000)
            let bottomColor = UIColorFromRGB(rgbValue: 0xff8c00)
            let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
            let gradientLayer: CAGradientLayer = CAGradientLayer()
            gradientLayer.colors = gradientColors
            gradientLayer.frame = closeButton.bounds
            closeButton.layer.insertSublayer(gradientLayer, at: 0)
            closeButton.layer.cornerRadius = x/15
            closeButton.titleLabel?.font = UIFont.systemFont(ofSize: x/15)
            closeButton.frame = CGRect(x:0,y:0,width:x/2,height:y/10)
            closeButton.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/1.1)
            closeButton.tag = 2
            closeButton.addTarget(self, action: #selector(navigationLeaderView.onClickMyButton(sender:)), for: .touchUpInside)
            myWindow.addSubview(closeButton)
            
            
            RegistrationBool = false
            
            // インジケータを作成する.
            indicatorView = UIActivityIndicatorView()
            indicatorView.frame = CGRect(x:0, y:0, width:self.view.bounds.width/4, height:self.view.bounds.width/4)
            indicatorView.center = self.view.center
            indicatorView.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/3)
            // アニメーションが停止している時はインジケータを表示させない.
            indicatorView.hidesWhenStopped = true
            indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
            
            // インジケータをViewに追加する.
            myWindow.addSubview(indicatorView)
            
        }else{
            
            sender.alpha = 1.0
            RegistrationButton.alpha = 1.0
            UIView.animate(withDuration: 0.5, delay: 0.1, options: [.curveEaseIn], animations: {
                sender.alpha = 0.0
                self.RegistrationButton.alpha = 0.0
                
            }, completion: { (Bool) in
                
                self.view.addSubview(self.RegistrationButton)
                UIView.animate(withDuration: 0.5, delay: 0.1, options: [.curveEaseIn], animations: {
                    self.RegistrationButton.alpha = 1.0
                }, completion: nil)
                
            })
            
            //データの追加
            print("INSERT")
            let db = FMDatabase(path: DatabaseClass().table6)
            let sql = "INSERT INTO sample (name) VALUES (?);"
            
            db?.open()
            
            // ?で記述したパラメータの値を渡す場合
            db?.executeUpdate(sql, withArgumentsIn: ["📀"+SoundField.text!])
            // print("データベース　＝　\(db!)")
            db?.close()
            
            myItems.add("📀" + SoundField.text!)
            
            print("\(myItems.count)")
            
            SelectString = "📀" + SoundField.text!
            
            print("SelectString:::\(SelectString)")
            
            // チェックマークを保存するために保存された分の要素を付け足す
            checkMarks.append(false)
            
            myTableView.reloadData()
            
            RegistrationButton.setTitleColor(UIColor.lightGray, for: .normal)
            RegistrationButton.backgroundColor = UIColor.orange
            self.view.addSubview(RegistrationButton)
            
            SoundField.removeFromSuperview()
            RegistrationBool = true
            
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: . transitionCrossDissolve, animations: {
                self.myWindow.center.y = 0 - self.myWindow.bounds.height/2
            }){ _ in
                self.myWindow.removeFromSuperview()
            }
        }
    }
    
    
    
    func onClickMyButton(sender:UIButton){
        //　録音ボタンが押された処理
        if(sender.tag == 1){
            
            print("録音ボタンが押された")
            if(RegistrationBool == false){
                //登録ボタンが押された時にfalseが入っている
                //録音する
                UIView.transition(with: RecordingButton, duration: 1.0, options: [.transitionFlipFromBottom], animations: nil, completion: nil)
                
                startRecord()
                
                RecordingButton.setTitle("録音終了", for: .normal)
                RecordingButton.setTitleColor(UIColor.white, for: .normal)
                RegistrationBool = true
                RecordingLabel.removeFromSuperview()
                
            }else{
                
                UIView.transition(with: RecordingButton, duration: 1.0, options: [.transitionFlipFromTop], animations: nil, completion: nil)
                
                //終了ボタンが押されたらtrueが入る
                //録音の終了が押された
                stopRecord()
                
                RecordingButton.removeFromSuperview()
                
                // UITextFieldを作成する.
                SoundField = UITextField(frame: CGRect(x: 0, y: 0, width: self.myWindow.bounds.width/1.2, height: self.myWindow.bounds.height/10))
                
                // 表示する文字を代入する.
                SoundField.placeholder = "サウンド(音)の名前を入力して下さい"
                
                // 表示位置
                SoundField.layer.position = CGPoint(x:self.myWindow.bounds.width/2,y:self.myWindow.bounds.height/2.5)
                
                // Delegateを自身に設定する
                SoundField.delegate = self
                
                // 枠を表示する.
                SoundField.borderStyle = .roundedRect
                
                // クリアボタンを追加.
                SoundField.clearButtonMode = .whileEditing
                
                // Viewに追加する
                myWindow.addSubview(SoundField)
                
                RegistrationButton.setTitle("ＯＫ", for: .normal)
                RegistrationButton.setTitleColor(UIColor.white, for: .normal)
                RegistrationButton.backgroundColor = UIColor.lightGray
                RegistrationButton.isHidden = false
                myWindow.addSubview(RegistrationButton)
                RegistrationButton.alpha = 0.0
                UIView.animate(withDuration: 2.0, delay: 1.0, options: [.curveEaseIn], animations: {
                    self.RegistrationButton.alpha = 1.0
                }, completion: nil)
                RegistrationBool = false
                
            }
        }
        //　閉じる
        else if(sender.tag == 2){
            
            // 上から降ってくるアニメーション
            RegistrationButton.isHidden = false
            UIView.animate(withDuration: 1.0, delay: 0.0, options: . transitionCrossDissolve, animations: {
                self.myWindow.center.y = 0 - self.myWindow.bounds.height/2
                self.RegistrationButton.alpha = 1.0
            }){ _ in
                self.myWindow.removeFromSuperview()
            }
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
                self.RegistrationButton.center.y = self.y/1.1
            }, completion: nil)
            
            RegistrationBool = true
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // スクロール中の処理
        print("didScroll")
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // ドラッグ開始時の処理
        print("beginDragging")
    }
    
    /*
     Cellが選択された際に呼び出される
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        i = 0
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegateのインスタンスを取得
        appDelegate.SelectMusic = String(describing: myItems[indexPath.row])//appDelegateの変数を操作
        
        print("SELECT")
        let db = FMDatabase(path: DatabaseClass().table6)
        
        //let sql = "SELECT * FROM sample"
        let sql = "SELECT * FROM sample"
        // let sql = "SELECT user_name FROM sample ORDER BY user_id;"
        db?.open()
        
        let results = db?.executeQuery(sql, withArgumentsIn: nil)
        
        while (results?.next())! {
            
            // カラム名を指定して値を取得する方法
            let user_id = results?.int(forColumn: "user_id")
            
            // カラムのインデックスを指定して取得する方法
            let user_name = results?.string(forColumnIndex: 1)
            
            print("user_id = \(user_id!), user_name = \(user_name!)")
            
            if(user_name! == String(describing: myItems[indexPath.row]) && indexPath.row == i){
                SelectMusicID = user_id
                print("SelectMusicID = \(SelectMusicID)")
                SelectMusicName = user_name
            }
            
            i = i + 1
            
        }
        
        db?.close()
        
        print("SELECT")
        let db2 = FMDatabase(path: DatabaseClass().table7)
        
        //let sql = "SELECT * FROM sample"
        let sqll = "SELECT * FROM sample2"
        // let sql = "SELECT user_name FROM sample ORDER BY user_id;"
        db2?.open()
        
        let resultss = db2?.executeQuery(sqll, withArgumentsIn: nil)
        
        while (resultss?.next())! {
            
            NoDate = false
            
        }
        
        db2?.close()
        
        if(NoDate == false){
            //リムーブ処理
            let sqll = "DELETE FROM sample2 WHERE user_id = ?"
            
            db2?.open()
            db2?.executeUpdate(sqll, withArgumentsIn: [1])
            db2?.executeUpdate(sqll, withArgumentsIn: [2])
            db2?.close()
            
        }
        
        //データの追加
        print("INSERT")
        
        let sqli = "INSERT INTO sample2 (name) VALUES (?);"
        
        db2?.open()
        // ?で記述したパラメータの値を渡す場合
        db2?.executeUpdate(sqli, withArgumentsIn: [SelectMusicID])
        db2?.executeUpdate(sqli, withArgumentsIn: [SelectMusicName])
        // print("データベース　＝　\(db!)")
        db2?.close()
        
        let cell = tableView.cellForRow(at:indexPath)
        
        
        
        i = 0
        
        print("Num: \(indexPath.row)")
        print("Value: \(myItems[indexPath.row])")
        
        let selectmusic : String!
        if(indexPath.row <= 4){
            
            selectmusic = FileName[indexPath.row] as! String
            
            let soundFilePath : String = Bundle.main.path(forResource: selectmusic, ofType: "mp3")!
            
            let fileURL = URL(fileURLWithPath: soundFilePath)
            
            // 音量を大きくする
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try! AVAudioSession.sharedInstance().setActive(true)
            
            //AVAudioPlayerのインスタンス化.
            myAudioPlayer = try! AVAudioPlayer(contentsOf: fileURL)
            
            //AVAudioPlayerのデリゲートをセット.
            myAudioPlayer.delegate = self
            
            
            myAudioPlayer.play()
        }else{
            
            print("SelectString:::\(SelectString)\nmyItems:::\(myItems[indexPath.row])")
            
            print("DateCount==\(DateCount)\n i=\(i) indexpath.row==\(indexPath.row)")
            
            let db = FMDatabase(path: DatabaseClass().table6)
            
            //let sql = "SELECT * FROM sample"
            let sql = "SELECT * FROM sample"
            
            // let sql = "SELECT user_name FROM sample ORDER BY user_id;"
            db?.open()
            
            let results = db?.executeQuery(sql, withArgumentsIn: nil)
            
            while (results?.next())! {
                
                // カラム名を指定して値を取得する方法
                let user_id = results?.int(forColumn: "user_id")
                
                // カラムのインデックスを指定して取得する方法
                let user_name = results?.string(forColumnIndex: 1)
                
                print("user_id = \(user_id!), user_name = \(user_name!),myItems:::\(myItems[indexPath.row])")
                
                if(user_name! == String(describing: myItems[indexPath.row]) && indexPath.row == i){
                    SelectValue = Int(user_id!)
                    SelectString = ""
                    db?.close()
                    startPlay()
                }
                
                i = i + 1
            }
        }
        
        
        
        if indexPath.section > 0 { return }
        
        userDefault.set(indexPath.row, forKey: "leaderChoose")
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if (cell.accessoryType == .none) {
                cell.accessoryType = .checkmark
                cell.textLabel!.font = UIFont(name: "Arial", size: self.view.frame.width/20)
                cell.textLabel?.textColor = UIColor.blue
                
                checkMarks = checkMarks.enumerated().flatMap { (elem: (Int, Bool)) -> Bool in
                    if (indexPath.row != elem.0) {
                        let otherCellIndexPath = NSIndexPath(row: elem.0, section: 0)
                        
                        if let otherCell = tableView.cellForRow(at: otherCellIndexPath as IndexPath) {
                            otherCell.accessoryType = .none
                            otherCell.textLabel?.font = UIFont(name: "Arial", size: self.view.frame.width/20)
                            otherCell.textLabel?.textColor = UIColor.black
                        }
                    }
                    return indexPath.row == elem.0
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)

        
    }
    
    /*
     Cellの総数を返す.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }
    
    /*
     Cellに値を設定する
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        
        cell.textLabel!.text = "\(myItems[indexPath.row])"
        
        cell.backgroundColor = UIColor.white
        
        cell.textLabel?.textColor = UIColor.black
        
        
        if (userDefault.object(forKey: "leaderChoose") != nil) {
            
            if(indexPath.row == userDefault.integer(forKey: "leaderChoose")){
                
                
                if cell.accessoryType == .none {
                    cell.accessoryType = .checkmark
                    cell.textLabel!.font = UIFont(name: "Arial", size: self.view.frame.width/20)
                    cell.textLabel?.textColor = UIColor.blue
                    
                    checkMarks = checkMarks.enumerated().flatMap { (elem: (Int, Bool)) -> Bool in
                        if indexPath.row != elem.0 {
                            print("elem.0 = \(elem.0)\nelem.1 = \(elem.1)")
                            let otherCellIndexPath = NSIndexPath(row: elem.0, section: 0)
                            if let otherCell = tableView.cellForRow(at: otherCellIndexPath as IndexPath) {
                                otherCell.accessoryType = .none
                                otherCell.textLabel?.font = UIFont(name: "Arial", size:self.view.frame.width/20)
                                otherCell.textLabel?.textColor = UIColor.black
                            }
                        }
                        return indexPath.row == elem.0
                    }
                }
                
            }
        }
        
        cell.textLabel!.font = UIFont(name: "Arial", size: self.view.frame.width/20)
        
        
        
        
        return cell
        
    }
    
    // セルの選択が外れた時に呼び出される
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        
        // チェックマークを外す
        cell?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        var value : Int32!
        
        i = 0
        
        // 削除のとき.
        if(indexPath.row <= 4){
            
            let alert:UIAlertView? = UIAlertView(title: "削除不可",message: "サンプルなので消すことができません", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
            alert?.show()
            
        }
            
        else if editingStyle == UITableViewCellEditingStyle.delete {
            
            print("削除")
            
            print("Value: \(myItems[indexPath.row])")
            
            let db = FMDatabase(path: DatabaseClass().table6)
            
            // let sql = "SELECT * FROM sample"
            let sql = "SELECT * FROM sample"
            
            // let sql = "SELECT user_name FROM sample ORDER BY user_id;"
            db?.open()
            
            var results = db?.executeQuery(sql, withArgumentsIn: nil)
            
            while (results?.next())! {
                
                // カラム名を指定して値を取得する方法
                let user_id = results?.int(forColumn: "user_id")
                
                // カラムのインデックスを指定して取得する方法
                let user_name = results?.string(forColumnIndex: 1)
                
                print("user_id = \(user_id!), user_name = \(user_name!)")
                
                if(indexPath.row == i && user_name == String(describing: myItems[indexPath.row])){
                    
                    value = user_id
                    break
                    
                }
                
                i = i + 1
                
            }
            
            db?.close()
            
            //リムーブ処理
            let sqll = "DELETE FROM sample WHERE user_id = ?"
            
            db?.open()
            db?.executeUpdate(sqll, withArgumentsIn: [value])
            db?.close()
            
            // ドキュメントのパス
            let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            
            // 削除先のパス
            let filePath = docDir + "/music" + "\(value - 5)"+".wav"
            
            // 削除処理
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                // 削除に失敗
            }
            
            // let sql = "SELECT user_name FROM sample ORDER BY user_id;"
            db?.open()
            
            results = db?.executeQuery(sql, withArgumentsIn: nil)
            
            while (results?.next())! {
                
                // カラム名を指定して値を取得する方法
                let user_id = results?.int(forColumn: "user_id")
                
                // カラムのインデックスを指定して取得する方法
                let user_name = results?.string(forColumnIndex: 1)
                
                print("user_id = \(user_id!), user_name = \(user_name!)")
                
                DateCount = Int(user_id!) - 4
                
            }
            
            db?.close()
            
            //選択したセルの内容と保存してある内容が一致した場合のIDを削除するようにしゅるんでちゅ
            
            // 指定されたセルのオブジェクトをmyItemsから削除する.
            myItems.removeObject(at: indexPath.row)
            
            // TableViewを再読み込み.
            myTableView.reloadData()
            
        }
    }
    
    /*
     改行ボタンが押された際に呼ばれる
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn \(textField.text!)")
        
        // 改行ボタンが押されたらKeyboardを閉じる処理.
        textField.resignFirstResponder()
        
        if(textField.text == ""){
            textField.placeholder = "名前を入力して下さい！！"
        }
        
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
    
    func startPlay() {
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        print("Selectvalue = \(SelectValue - 5)")
        print("ohono-")
        let file_name = "music" + "\(String(SelectValue! - 5))" + ".wav"
        
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
        
        self.audioEngine.connect(self.audioFilePlayer, to: mixer, format: audioFile.processingFormat)
        self.audioFilePlayer.scheduleSegment(audioFile,
                                             startingFrame: AVAudioFramePosition(0),
                                             frameCount: AVAudioFrameCount(self.audioFile.length),
                                             at: nil,
                                             completionHandler: nil)
        
        self.audioFilePlayer.volume = 1
        
        //completionHandlerは完全に再生されたか停止した後に呼ばれる
        try! self.audioEngine.start()
        self.audioFilePlayer.play()
        
    }
    
    func stopPlay() {
        
        if self.audioFilePlayer != nil && self.audioFilePlayer.isPlaying {
            self.audioFilePlayer.stop()
        }
        self.audioEngine.stop()
        try! AVAudioSession.sharedInstance().setActive(false)
        
    }
    
}



// 端末登録クラス
class navigationDeviceView : UIViewController, UITextFieldDelegate, UIAlertViewDelegate {
    
    var x: CGFloat!
    var y: CGFloat!
    
    var sx: CGFloat!
    var sy: CGFloat!
    
    let saveVariable = UserDefaults.standard
    
    
    /******************************* bluetooth接続関連 *******************************/
    // serviceType(接続キー)の値を設定
    var connectServiceType = ""
    
    var myPeerId: MCPeerID!
    
    var serviceAdvertiser : MCNearbyServiceAdvertiser!
    var serviceBrowser : MCNearbyServiceBrowser!
    
    var session : MCSession!
    
    // bluetoothがOnになっているかを確認する変数
    var bluetoothOn : Bool = false
    
    // デバイストークンと端末名を受け取ることを切り替える変数
    var receveChange : Bool = true
    
    // Bluetoothの状態を確認するために用意した変数
    var myPheripheralManager:CBPeripheralManager!
    
    /******************************* label関連 *******************************/
    // identifierTextFieldの説明ラベル
    var identifierLabel: LTMorphingLabel!
    
    // nameTextFieldの説明ラベル
    var nameLabel: LTMorphingLabel!
    
    
    var connectLabel: LTMorphingLabel!
    
    
    /****************************** button関連 ******************************/
    // 端末追加ボタン
    var deviceAddButton: ZFRippleButton!
    
    
    /******************************* textField関連 *******************************/
    // identifierを入力するtextField
    var identifierTextField: UITextField!
    
    
    // 名前を入力するtextField
    var nameTextField: UITextField!
    
    
    /******************************* textView関連 *******************************/
    // 自分の接続キーを表示するtextView
    var keyTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "端末登録"
        
        self.view.backgroundColor = UIColor.lightGray
        
        x = self.view.frame.width
        y = self.view.frame.height
        
        /****************************** Label ******************************/
        
        let lWidth: CGFloat = x - x/4
        let lHeight: CGFloat = y/20
        let lposX: CGFloat = (self.view.bounds.width - lWidth)/2
        let lposY: CGFloat = (self.view.bounds.height - lHeight)/2
        
        
        connectLabel = LTMorphingLabel(frame: CGRect(x: x/2 - x/5, y: y/2 - y/3, width: x, height: y/20))
        connectLabel.textColor = UIColor.white
        connectLabel.font = UIFont.systemFont(ofSize: x/20)
        connectLabel.text = "あなたの接続キー"
        connectLabel.shadowColor = UIColor.gray
        connectLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(connectLabel)
        
        nameLabel = LTMorphingLabel(frame: CGRect(x: lposX, y: y/2 + y/30, width: lWidth, height: lHeight))
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.systemFont(ofSize: x/20)
        nameLabel.text = "端末の所有者を入力してください"
        nameLabel.shadowColor = UIColor.gray
        nameLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(nameLabel)
        
        identifierLabel = LTMorphingLabel(frame: CGRect(x: x/2 - x/3, y: y/2 - y/6, width: lWidth, height: lHeight))
        identifierLabel.textColor = UIColor.white
        identifierLabel.font = UIFont.systemFont(ofSize: x/20)
        identifierLabel.text = "接続キーを入力してください"
        identifierLabel.shadowColor = UIColor.gray
        identifierLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(identifierLabel)
        
        /****************************** Button ******************************/
        
        deviceAddButton = ZFRippleButton()
        deviceAddButton.setTitle("端末追加",for: .normal)
        deviceAddButton.titleLabel?.font = UIFont(name: "TimesNewRomanPSMT", size: x/15)
        deviceAddButton.setTitleColor(UIColor.white, for: .normal)
        deviceAddButton.setTitleColor(UIColor.gray, for: .highlighted)
        deviceAddButton.frame = CGRect(x:0,y:0,width: x/2.5, height: y/15)
        deviceAddButton.layer.position = CGPoint(x: x/2, y: y/2 + y/3)
        deviceAddButton.addTarget(self, action: #selector(navigationDeviceView.onclickbutton(sender:)), for: .touchUpInside)
        
        //グラデーションの開始色(頂点)
        let topColor = UIColorFromRGB(rgbValue: 0xff0000)
        //グラデーションの開始色(底辺)
        let bottomColor = UIColorFromRGB(rgbValue: 0xff8c00)
        
        //グラデーションの色を配列で管理
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        
        //グラデーションレイヤーを作成
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        //グラデーションレイヤーをスクリーンサイズにする
        gradientLayer.frame = self.deviceAddButton.bounds
        
        //グラデーションレイヤーをビューの一番下に配置
        self.deviceAddButton.layer.insertSublayer(gradientLayer, at: 0)
        
        self.view.addSubview(deviceAddButton)
        
        
        /*************** 自分の接続キーを表示するkeyTextViewの生成 ***************/
        keyTextView = UITextView(frame: CGRect(x: x/2 - x/3, y: y/2 - y/3.5, width: x/1.5, height: y/15))
        keyTextView.backgroundColor = UIColor.white
        keyTextView.text = ""
        
        if (saveVariable.object(forKey: "myConnectKey") != nil) {
            
            keyTextView.text = saveVariable.string(forKey: "myConnectKey")!
        }
        
        keyTextView.layer.borderWidth = 1
        keyTextView.layer.borderColor = UIColor.black.cgColor
        keyTextView.font = UIFont.systemFont(ofSize: x/20)
        keyTextView.textColor = UIColor.black
        keyTextView.textAlignment = NSTextAlignment.center
        keyTextView.isEditable = false
        keyTextView.isSelectable = false
        keyTextView.isScrollEnabled = false
        keyTextView.adjustsFontForContentSizeCategory = false
        self.view.addSubview(keyTextView)
        
        /****************************** TextField ******************************/
        
        // UITextFieldの配置するx,yと幅と高さを設定
        let tWidth: CGFloat = x - x/4
        let tHeight: CGFloat = y/20
        let tposX: CGFloat = (self.view.bounds.width - tWidth)/2
        let tposY: CGFloat = (self.view.bounds.height - tHeight)/2
        
        // UITextFieldを作成する
        identifierTextField = UITextField(frame: CGRect(x: tposX, y: y/2 - y/10, width: tWidth, height: tHeight))
        identifierTextField.placeholder = "半角英字で15文字以内"
        identifierTextField.tag = 1
        identifierTextField.delegate = self
        identifierTextField.borderStyle = .roundedRect
        identifierTextField.clearButtonMode = .whileEditing
        self.view.addSubview(identifierTextField)
        
        
        nameTextField = UITextField(frame: CGRect(x: tposX, y: y/2 + y/10, width: tWidth, height: tHeight))
        nameTextField.placeholder = "端末の所有者"
        nameTextField.tag = 2
        nameTextField.delegate = self
        nameTextField.borderStyle = .roundedRect
        nameTextField.clearButtonMode = .whileEditing
        self.view.addSubview(nameTextField)
        
        
        
    }
    
    
    // 端末追加ボタンが押された時に呼ばれるメソッド
    func onclickbutton(sender: UIButton){
        
        // 改行ボタンが押されたらKeyboardを閉じる処理
        identifierTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        
        // textFieldの値が空なら
        if(identifierTextField.text == "" || nameTextField.text == ""){
            
            let alert: UIAlertView? = UIAlertView(title: "入力してください",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
            alert?.show()
            
        }
            // textFieldの値が空じゃないなら
        else if(identifierTextField.text != "" && nameTextField.text != ""){
            
            
            // identifierTextFieldのtextをitext変数に代入
            let itext : String = identifierTextField.text!
            
            // 半角英字のみなら
            if itext.isValidNickName {
                
                // 15文字以下なら
                if(itext.characters.count <= 15){
                    
                    // bluetoothで接続してデバイストークンを取得！
                    // 受信するまでクルクル円を回す
                    let infoView = navigationInformationView()
                    
                    infoView.deviceList.add(nameTextField.text!)
                    infoView.deviceSubList.add(identifierTextField.text!)
                    
                    
                    let db = FMDatabase(path: DatabaseClass().table2)
                    let db2 = FMDatabase(path: DatabaseClass().table3)
                    let sql = "INSERT INTO device2 (name) VALUES (?);"
                    let sql2 = "INSERT INTO device3 (name) VALUES (?);"
                    
                    db?.open()
                    db2?.open()
                    
                    // ?で記述したパラメータの値を渡す場合
                    db?.executeUpdate(sql, withArgumentsIn: [nameTextField.text!])
                    db2?.executeUpdate(sql2, withArgumentsIn: [identifierTextField.text!])
                    
                    db?.close()
                    db2?.close()
                    
                    identifierTextField.text = ""
                    nameTextField.text = ""
                    
                    let alert: UIAlertView? = UIAlertView(title: "登録しました",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                    alert?.show()
                    
                    
                }
                    
                else{
                    
                    let alert: UIAlertView? = UIAlertView(title: "15文字以内で入力してください",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                    alert?.show()
                    
                    identifierTextField.text = ""
                }
                
            }
                
                // 全角が含まれているなら
            else {
                
                // 15文字以上なら
                if(itext.characters.count > 15){
                    
                    let alert: UIAlertView? = UIAlertView(title: "15文字以内で入力してください",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                    alert?.show()
                    
                    identifierTextField.text = ""
                }
                    
                else{
                    
                    let alert: UIAlertView? = UIAlertView(title: "半角英字のみで入力してください",message: "", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: nil, otherButtonTitles: "OK")
                    alert?.show()
                    
                    identifierTextField.text = ""
                }
                
                
            }
            
        }
        
    }

    
    /******************** UITextField関連メソッド ********************/
    
    // UITextFieldが編集された直前に呼ばれる
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
    }
    
    // UITextFieldが編集された直後に呼ばれる
    func textFieldDidEndEditing(_ textField: UITextField) {
        
       
        
    }
    
    // 改行ボタンが押された際に呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // 改行ボタンが押されたらKeyboardを閉じる処理
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
    
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if(alertView.title == "受信しました"){
            print("alertView = \(alertView.title)")
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
}

// 自分の端末の情報を表示しているクラス
class navigationInformationView : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let saveVariable = UserDefaults.standard
    
    var x: CGFloat!
    var y: CGFloat!
    
    /******************************* label関連 *******************************/
    var connectLabel: LTMorphingLabel!
    
    // listTableViewの説明ラベル
    var listLabel: LTMorphingLabel!

    
    /******************************* textView関連 *******************************/
    // 自分の接続キーを表示するtextView
    var keyTextView: UITextView!
    
    
    /******************************* tableView関連 *******************************/
    // Tableで使用する配列を設定する
    let deviceList: NSMutableArray = []
    let deviceSubList: NSMutableArray = []
    
    // 端末名のリストtableView
    var listTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "あなたの端末情報"
        
        self.view.backgroundColor = UIColor.lightGray
        
        x = self.view.frame.width
        y = self.view.frame.height
        
        // tableViewのレイアウトに使う変数
        let lWidth: CGFloat = x - x/4
        let lHeight: CGFloat = y/20
        let lposX: CGFloat = (self.view.bounds.width - lWidth)/2
        let lposY: CGFloat = (self.view.bounds.height - lHeight)/2
        
        
        /******************* データベースから登録された端末の名前と接続キーを呼び出す *******************/
        let db = FMDatabase(path: DatabaseClass().table2)
        let db2 = FMDatabase(path: DatabaseClass().table3)
        
        let sql = "SELECT * FROM device2"
        let sql2 = "SELECT * FROM device3"
        
        db?.open()
        db2?.open()
        
        let results = db?.executeQuery(sql, withArgumentsIn: nil)
        let results2 = db2?.executeQuery(sql2, withArgumentsIn: nil)
        
        while (results?.next())! {
            
            // カラムのインデックスを指定して取得する方法
            let user_name = results?.string(forColumnIndex: 1)
            
            deviceList.add(user_name!)
        }
        
        while (results2?.next())! {
            
            // カラムのインデックスを指定して取得する方法
            let user_name = results2?.string(forColumnIndex: 1)
            
            deviceSubList.add(user_name!)
        }
        
        db?.close()
        db2?.close()

        
        
        connectLabel = LTMorphingLabel(frame: CGRect(x: x/2 - x/5, y: y/2 - y/3, width: x, height: y/20))
        connectLabel.textColor = UIColor.white
        connectLabel.font = UIFont.systemFont(ofSize: x/20)
        connectLabel.text = "あなたの接続キー"
        connectLabel.shadowColor = UIColor.gray
        connectLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(connectLabel)
        
        
        listLabel = LTMorphingLabel(frame: CGRect(x: x/2 - x/5, y: y/2 - y/6, width: lWidth, height: lHeight))
        listLabel.textColor = UIColor.white
        listLabel.font = UIFont.systemFont(ofSize: x/20)
        listLabel.text = "登録端末リスト"
        listLabel.shadowColor = UIColor.gray
        listLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(listLabel)
        
        /*************** 自分の接続キーを表示するkeyTextViewの生成 ***************/
        keyTextView = UITextView(frame: CGRect(x: x/2 - x/3, y: y/2 - y/3.7, width: x/1.5, height: y/15))
        keyTextView.backgroundColor = UIColor.white
        keyTextView.text = ""
        
        if (saveVariable.object(forKey: "myConnectKey") != nil) {
            
            keyTextView.text = saveVariable.string(forKey: "myConnectKey")!
        }
        
        keyTextView.layer.borderWidth = 1
        keyTextView.layer.borderColor = UIColor.black.cgColor
        keyTextView.font = UIFont.systemFont(ofSize: x/20)
        keyTextView.textColor = UIColor.black
        keyTextView.textAlignment = NSTextAlignment.left
        keyTextView.isEditable = false
        keyTextView.isSelectable = false
        keyTextView.isScrollEnabled = false
        keyTextView.adjustsFontForContentSizeCategory = false
        self.view.addSubview(keyTextView)
        
        
        /****************************** TableView ******************************/
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        
        
        let tc = floor(y/90)
        
        // leaderTableViewを生成
        let cellHeight = barHeight * tc * 2.5
        listTableView = UITableView(frame: CGRect(x: 0, y: y/2.5, width: x, height: cellHeight))
        listTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        listTableView.dataSource = self
        listTableView.delegate = self
        listTableView.tag = 1
        listTableView.rowHeight = y/15
        self.view.addSubview(listTableView)
        
        
        
    }
    
    // レイアウトの処理が終了したら呼ばれる
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        keyTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    
    /******************** UITableView関連メソッド ********************/
    
    // Cellが選択された際に呼び出される
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("端末名: \(deviceList[indexPath.row])")
        print("接続キー: \(deviceSubList[indexPath.row])")
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Cellの総数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    // Cellに値を設定する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 再利用するCellを取得する(左にtextLabel、右にdetailLabelを表示するstyleにしている)
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "MyCell")
        
        // Cellに値を設定する
        cell.textLabel!.text = "\(deviceList[indexPath.row])"
        
        
        cell.detailTextLabel?.text = "\(deviceSubList[indexPath.row])"
        
        cell.textLabel!.font = UIFont(name: "Arial", size: x/20)
        
        return cell
    }
    
    // Cellを挿入または削除しようとした際に呼び出される
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        var value : Int32!
        var value2 : Int32!
        
        // 削除のとき.
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // 名前、接続キー、デバイストークンを削除
            let db = FMDatabase(path: DatabaseClass().table2)
            let db2 = FMDatabase(path: DatabaseClass().table3)
            
            let sql = "SELECT * FROM device2"
            let sql2 = "SELECT * FROM device3"
            
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
                
                if(user_name! == String(describing: deviceSubList[indexPath.row])){
                    value2 = user_id!
                }
                
            }
            
            
            db?.close()
            db2?.close()
            
            //リムーブ処理
            let sqll = "DELETE FROM device2 WHERE user_id = ?"
            let sqll2 = "DELETE FROM device3 WHERE user_id = ?"
            
            db?.open()
            db2?.open()
            db?.executeUpdate(sqll, withArgumentsIn: [value])
            db2?.executeUpdate(sqll2, withArgumentsIn: [value2])
            db?.close()
            db2?.close()
            
            //選択したセルの内容と保存してある内容が一致した場合のIDを削除するようにする
            
            // 指定されたセルのオブジェクトをmyItemsから削除する.
            deviceList.removeObject(at: indexPath.row)
            deviceSubList.removeObject(at: indexPath.row)
            
            // TableViewを再読み込み.
            listTableView.reloadData()
        }
        
    }

    
}


/*********************************** ヘルプ ***********************************/
// アプリについて説明しているクラス
class navigationApplicationView : UIViewController {
    
    var x: CGFloat!
    var y: CGFloat!
    
    var explainWindow: UIWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "アプリについて"
        
        
        self.view.backgroundColor = UIColor.lightGray
        
        x = self.view.frame.width
        y = self.view.frame.height
        
        explainWindow = UIWindow()
        explainWindow.backgroundColor = UIColor.white
        explainWindow.frame = CGRect(x:0, y:0, width:x - x/20, height:y - y/4)
        explainWindow.layer.position = CGPoint(x:self.view.frame.width/2, y:self.view.frame.height/2)
        explainWindow.layer.cornerRadius = 20
        explainWindow.makeKey()
        self.explainWindow.makeKeyAndVisible()
        
        let explainTextView: UITextView = UITextView(frame: CGRect(x:10, y:10, width:self.explainWindow.frame.width - 20, height:self.explainWindow.frame.height - 20))
        explainTextView.backgroundColor = UIColor.clear
        explainTextView.text = "　iPhoneレーダーには「紛失モード」、「迷子モード」があります。起動時にマイク、GPS、Bluetoothの使用を許可してください。端末を探索する際、初めに「端末登録」をしておく必要があります。まず、設定画面から「端末登録」を開いて登録する端末に表示されている接続キーを入力して下さい。入力後、誰のか分かるように端末名を入力してください。入力後、「端末追加」を押せば「設定」の「あなたの端末情報」内の「登録端末リスト」に追加されています。こうすることで、「紛失モード」や「迷子モード」で端末の選択が行えるようになります。"
        explainTextView.font = UIFont.systemFont(ofSize: x/20)
        explainTextView.textColor = UIColor.black
        explainTextView.textAlignment = NSTextAlignment.left
        explainTextView.isEditable = false
        explainTextView.isScrollEnabled = false
        self.explainWindow.addSubview(explainTextView)
        

    }
    
    // 画面が表示される直前に呼び出される
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        explainWindow.isHidden = false
        
    }
    
    // 画面が消える直前に呼び出される
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        explainWindow.isHidden = true
        
    }
    
    
    
}

// 迷子モードについて説明しているクラス
class navigationChildView : UIViewController {
    
    var x: CGFloat!
    var y: CGFloat!
    
    var explainWindow: UIWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "迷子モードについて"
        
        self.view.backgroundColor = UIColor.lightGray
        
        x = self.view.frame.width
        y = self.view.frame.height
        
        explainWindow = UIWindow()
        explainWindow.backgroundColor = UIColor.white
        explainWindow.frame = CGRect(x:0, y:0, width:x - x/20, height:y - y/4)
        explainWindow.layer.position = CGPoint(x:self.view.frame.width/2, y:self.view.frame.height/2)
        explainWindow.layer.cornerRadius = 20
        explainWindow.makeKey()
        explainWindow.makeKeyAndVisible()
        
        let explainTextView: UITextView = UITextView(frame: CGRect(x:10, y:10, width:explainWindow.frame.width - 20, height:explainWindow.frame.height - 20))
        explainTextView.backgroundColor = UIColor.clear
        explainTextView.text = "　このモードは家族で出かけていて、人混みの中で逸れてしまうのを防ぐモードです。　複数人とどれほど離れているかを確認することではぐれてしまうことを防ぎます。紛失モードと同じく、設定画面で端末登録をする必要があります。この機能ではBluetoothを使用するため、BluetoothをONにしていただく必要があります。接続キー(半角英字15文字以内で接続する端末と同じにするキー)を入力して接続していただきます。\n　迷子モードにはみんなの中心となる「基準」と基準となる人とはぐれないようにする「その他」に分かれています。基準の人はアプリを起動した状態のままでいる必要があります。スリープ状態またはバックグラウンド状態では動きません。"
        explainTextView.font = UIFont.systemFont(ofSize: x/20)
        explainTextView.textColor = UIColor.black
        explainTextView.textAlignment = NSTextAlignment.left
        explainTextView.isEditable = false
        explainTextView.isScrollEnabled = false
        explainWindow.addSubview(explainTextView)
        
    }
    
    // 画面が表示される直前に呼び出される
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        explainWindow.isHidden = false
        
    }
    
    // 画面が消える直前に呼び出される
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        explainWindow.isHidden = true
        
    }
    
    
}

// 紛失モードについて説明しているクラス
class navigationLostView : UIViewController {
    
    var x: CGFloat!
    var y: CGFloat!
    
    var explainWindow: UIWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "紛失モードについて"
        
        self.view.backgroundColor = UIColor.lightGray
        
        x = self.view.frame.width
        y = self.view.frame.height
        
        explainWindow = UIWindow()
        explainWindow.backgroundColor = UIColor.white
        explainWindow.frame = CGRect(x:0, y:0, width:x - x/20, height:y - y/4)
        explainWindow.layer.position = CGPoint(x:self.view.frame.width/2, y:self.view.frame.height/2)
        explainWindow.layer.cornerRadius = 20
        explainWindow.makeKey()
        self.explainWindow.makeKeyAndVisible()
        
        let explainTextView: UITextView = UITextView(frame: CGRect(x:10, y:10, width:self.explainWindow.frame.width - 20, height:self.explainWindow.frame.height - 20))
        explainTextView.backgroundColor = UIColor.clear
        explainTextView.text = "　アプリを起動しスリープ状態にしておくと、iPhoneをなくした際に探索できます。探索する際は設定画面から端末登録をしておく必要があります。追加から探す端末を選択して探索開始をすることでiPhoneの位置を取得します。位置が近くなるにつれてレーダーの色や音の速さが早くなります。"
        explainTextView.font = UIFont.systemFont(ofSize: x/20)
        explainTextView.textColor = UIColor.black
        explainTextView.textAlignment = NSTextAlignment.left
        explainTextView.isEditable = false
        explainTextView.isScrollEnabled = false
        self.explainWindow.addSubview(explainTextView)
        
    }
    
    // 画面が表示される直前に呼び出される
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        explainWindow.isHidden = false
        
    }
    
    // 画面が消える直前に呼び出される
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        explainWindow.isHidden = true
        
    }
    
}


// 接続キーについて説明しているクラス
class navigationKeyView : UIViewController {
    
    var x: CGFloat!
    var y: CGFloat!
    
    var explainWindow: UIWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "接続キーについて"
        
        self.view.backgroundColor = UIColor.lightGray
        
        x = self.view.frame.width
        y = self.view.frame.height
        
        explainWindow = UIWindow()
        explainWindow.backgroundColor = UIColor.white
        explainWindow.frame = CGRect(x:0, y:0, width:x - x/20, height:y - y/4)
        explainWindow.layer.position = CGPoint(x:self.view.frame.width/2, y:self.view.frame.height/2)
        explainWindow.layer.cornerRadius = 20
        explainWindow.makeKey()
        self.explainWindow.makeKeyAndVisible()
        
        let explainTextView: UITextView = UITextView(frame: CGRect(x:10, y:10, width:self.explainWindow.frame.width - 20, height:self.explainWindow.frame.height - 20))
        explainTextView.backgroundColor = UIColor.clear
        explainTextView.text = "　接続キーは、iPhoneを探す際に必要なものです。Bluetooth接続する時と端末を探す時に使用します。設定画面の端末登録で入力するのが端末を探す時に使用する接続キーです。端末情報から自分の接続キーを確認できます。迷子モードで入力する接続キーはBluetooth接続に使用します。半角英字で15文字以内で入力する必要があります。"
        explainTextView.font = UIFont.systemFont(ofSize: x/20)
        explainTextView.textColor = UIColor.black
        explainTextView.textAlignment = NSTextAlignment.left
        explainTextView.isEditable = false
        explainTextView.isScrollEnabled = false
        self.explainWindow.addSubview(explainTextView)
        
    }
    
    // 画面が表示される直前に呼び出される
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        explainWindow.isHidden = false
        
    }
    
    // 画面が消える直前に呼び出される
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        explainWindow.isHidden = true
        
    }

}


// 設定について説明しているクラス
class navigationSettingView : UIViewController {
    
    var x: CGFloat!
    var y: CGFloat!
    
    var explainWindow: UIWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "設定について"
        
        self.view.backgroundColor = UIColor.lightGray
        
        x = self.view.frame.width
        y = self.view.frame.height
        
        explainWindow = UIWindow()
        explainWindow.backgroundColor = UIColor.white
        explainWindow.frame = CGRect(x:0, y:0, width:x - x/20, height:y - y/4)
        explainWindow.layer.position = CGPoint(x:self.view.frame.width/2, y:self.view.frame.height/2)
        explainWindow.layer.cornerRadius = 20
        explainWindow.makeKey()
        self.explainWindow.makeKeyAndVisible()
        
        let explainTextView: UITextView = UITextView(frame: CGRect(x:10, y:10, width:self.explainWindow.frame.width - 20, height:self.explainWindow.frame.height - 20))
        explainTextView.backgroundColor = UIColor.clear
        explainTextView.text = "　設定では、レーダーの音を選択したりレーダーの音を録音してならすことができます。また、レーダーでiPhoneを探す時に必要な端末情報の登録を行うことができます。登録した端末は確認することができます。端末登録のやり方は、「登録する端末接続キー」と「端末の所持者の名前」を入力して「追加」で登録します。"
        explainTextView.font = UIFont.systemFont(ofSize: x/20)
        explainTextView.textColor = UIColor.black
        explainTextView.textAlignment = NSTextAlignment.left
        explainTextView.isEditable = false
        explainTextView.isScrollEnabled = false
        self.explainWindow.addSubview(explainTextView)
        
    }
    
    // 画面が表示される直前に呼び出される
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        explainWindow.isHidden = false
        
    }
    
    // 画面が消える直前に呼び出される
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        explainWindow.isHidden = true
        
    }
    
}

// 注意事項
class navigationWarningView: UIViewController {
    
    var x: CGFloat!
    var y: CGFloat!
    
    var explainWindow: UIWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "注意事項について"
        
        self.view.backgroundColor = UIColor.lightGray
        
        x = self.view.frame.width
        y = self.view.frame.height
        
        explainWindow = UIWindow()
        explainWindow.backgroundColor = UIColor.white
        explainWindow.frame = CGRect(x:0, y:0, width:x - x/20, height:y - y/4)
        explainWindow.layer.position = CGPoint(x:self.view.frame.width/2, y:self.view.frame.height/2)
        explainWindow.layer.cornerRadius = 20
        explainWindow.makeKey()
        self.explainWindow.makeKeyAndVisible()
        
        let explainTextView: UITextView = UITextView(frame: CGRect(x:10, y:10, width:self.explainWindow.frame.width - 20, height:self.explainWindow.frame.height - 20))
        explainTextView.backgroundColor = UIColor.clear
        explainTextView.text = "・接続キーを間違えて入力して登録してしまうとiPhoneを探すことができません。\n\n・迷子モードで接続する際に入力する接続キーを接続する人と同じにしないと接続することができません。\n\n・なくしたiPhoneが金属付近にあった場合、位置の取得制度が下がることがあります。"
        explainTextView.font = UIFont.systemFont(ofSize: x/20)
        explainTextView.textColor = UIColor.black
        explainTextView.textAlignment = NSTextAlignment.left
        explainTextView.isEditable = false
        explainTextView.isScrollEnabled = false
        self.explainWindow.addSubview(explainTextView)
        
    }
    
    // 画面が表示される直前に呼び出される
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        explainWindow.isHidden = false
        
    }
    
    // 画面が消える直前に呼び出される
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        explainWindow.isHidden = true
        
    }
    
}
