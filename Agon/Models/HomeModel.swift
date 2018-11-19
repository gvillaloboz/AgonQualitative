//
//  HomeModel.swift
//  Agon
//
//  Created by Gabriela Villalobos on 09.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import RealmSwift

protocol HomeModelProtocol: class {
    func itemsDownloaded(items : NSArray)
}

class HomeModel: NSObject, URLSessionDataDelegate {
    
    //properties
    
    weak var delegate : HomeModelProtocol!
    
    var data = Data()
    
    let urlPath : String = "https://pow.unil.ch/agon/phpScripts/service.php"
    
    func downloadItems(){
        
        let url: URL = URL(string :  urlPath)!
        let defaultSession = Foundation.URLSession(configuration : URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil{
                print("Failed to download data")
            }else {
                print("Data downloaded")
                self.parseJSON(data!)
            }
        }
        
        task.resume();
    }
    
    func parseJSON(_ data : Data){
        
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
        } catch let error as NSError{
            print(error)
        }
        
        var jsonElement = NSDictionary()
        let users = NSMutableArray()
//        let realm = try! Realm()
        
        for i in 0 ..< jsonResult.count{
            jsonElement = jsonResult[i] as! NSDictionary
            
            let user = UserModel()
            //let realmUser = RealmUserModel()
            
            // To make sure non of the JSON values are nil by optional binding
            if  let name = jsonElement["name"] as? String,
                let email = jsonElement["email"] as? String

            {
                user.name = name
                user.email = email
               
//                try! realm.write{
//                    realm.add(realmUser)
//                }
            }
            
            users.add(user)
            
        }
        DispatchQueue.main.async(execute: { () -> Void  in
        
            self.delegate.itemsDownloaded(items: users)
        })
    }
    
}
