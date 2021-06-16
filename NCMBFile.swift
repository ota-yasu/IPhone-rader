//
//  NCMBFile.swift
//  iPhoneレーダー
//
//  Created by 清水直輝 on 2017/07/30.
//  Copyright © 2017年 平子英樹. All rights reserved.
//

import NCMB

// NSObjectを継承していないクラスをObjective-C側で利用する
// この宣言をしないと、サブクラスの登録時にクラッシュします
@objc(installation)
public class installation: NCMBObject, NCMBSubclassing {
    
    // connectキーの値を読み込むための変数(接続キーが格納されている)
    var connection: String! {
        get {
            return object(forKey: "connect") as! String
        }
        set {
            setObject(newValue, forKey: "connect")
        }
    }
    
    // distanceキーの値を読み込むための変数(距離の値が格納されている)
    var distance: Double! {
        get {
            return object(forKey: "distance") as! Double
        }
        set {
            setObject(newValue, forKey: "distance")
        }
    }
    
    
    
    // MARK: - NCMBSubclassing Protocol
    
    /// mobile backend上のクラス名を返す
    /// - returns: サブクラスのデータストア上でのクラス名
    public static func ncmbClassName() -> String! {
        return "installation" // クラス名と同じ名前であること
    }
    
    
}
