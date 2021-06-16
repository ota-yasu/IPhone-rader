//
//  database.swift
//  iPhoneレーダー
//
//  Created by 清水直輝 on 2017/07/27.
//  Copyright © 2017年 平子英樹. All rights reserved.
//

import Foundation

class DatabaseClass {
    
    // 端末追加table(迷子モード)を保存するtable
    var table : String {
        
        get{
            let paths = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask, true)
            let path = paths[0].stringByAppendingPathComponent(path: "device.db")
            return path
        }
    }
    
    // 端末登録table(名前)を保存するtable
    var table2 : String {
        
        get{
            let paths = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask, true)
            let path = paths[0].stringByAppendingPathComponent(path: "device2.db")
            return path
        }
    }
    
    // 端末登録table(接続キー及びパスワード)を保存するtable
    var table3 : String {
        
        get{
            let paths = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask, true)
            let path = paths[0].stringByAppendingPathComponent(path: "device3.db")
            return path
        }
    }
    
    // 音を保存するtable
    var table6 : String {
        
        get{
            let paths = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask, true)
            let path = paths[0].stringByAppendingPathComponent(path: "sample.db")
            return path
        }
    
    }
    
    // 音を選択したものを保存するtable
    var table7 : String {
        
        get{
            let paths = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask, true)
            let path = paths[0].stringByAppendingPathComponent(path: "sample2.db")
            return path
        }
        
    }
    
    // 迷子モードの接続キーを保存するtable
    var table8 : String {
        
        get{
            let paths = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask, true)
            let path = paths[0].stringByAppendingPathComponent(path: "device8.db")
            return path
        }
        
    }
    
}

