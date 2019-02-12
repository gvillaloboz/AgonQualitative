//
//  UserController.swift
//  Agon
//
//  Created by Gabriela Villalobos on 13.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import RealmSwift

protocol UserContollerProtocol: class {
    func userDataDownloaded(data : String)
}

class UserController: NSObject, URLSessionDataDelegate {
    
    //properties
    weak var delegate : UserContollerProtocol!
    var data = Data()
    let urlPath : String = "https://pow.unil.ch/agon/phpScripts/selectUserId.php"
    var pseudonym = String()
    
    /// Downloads from agon db in pow.unil.ch the user data
    ///
    /// - Parameter email: email imput on the login screen
    func downloadUserData(email : String){
        
        let url: URL = URL(string :  urlPath)!
        let defaultSession = Foundation.URLSession(configuration : URLSessionConfiguration.default)
        
        var urlRequest : URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let postString = "a=\(email)"
        urlRequest.httpBody = postString.data(using: .utf8)
        
        let postTask = defaultSession.dataTask(with: urlRequest){data, response, error in
            guard let data = data, error == nil else {  // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)!
            print("responseString = \(String(describing: responseString))")
            
            // Sends user data to the delegate function on the Login View
            DispatchQueue.main.async(execute: { () -> Void  in
                
                self.delegate.userDataDownloaded(data: responseString)
            })
        }
        
        postTask.resume();
    
    }
    
    
    /// Stores a Realm User Object locally
    ///
    /// - Parameters:
    ///   - id: user id
    ///   - name: user name
    ///   - lastName: user last name
    ///   - pseudonym: user pseudonym
    ///   - email: user email
    /// - Returns: returns true if Realm User Object created successfully
    func storeRealmUser(id : String, name : String, lastName : String, pseudonym : String, email : String, expCondition : String) -> Bool{
        let user = RealmUserModel()
        user.id = id
        user.name = name
        user.lastName = lastName
        user.pseudonym = pseudonym
        user.email = email
        user.expCondition = expCondition
        
        
        let realm = try! Realm()
        // 12.02.19 I removed this to insert N number of users with updated experimental conditions
//        if let existingUser = realm.object(ofType: RealmUserModel.self, forPrimaryKey: id){
//            print("User already exists on disc")
//            return false
//        }
        
        try! realm.write {
            realm.add(user)
        }
        return true
    }
    
    
    /// Checks if the response string from the server contains User Data
    /// if yes then stores it locally
    ///
    /// - Parameter data: User data from the server or "0 results" message
    func storeUserLocally(data : String, pseudonym : String, completion: (Bool) -> Void){

        var splitString = [String]()
        splitString = (data.components(separatedBy: " "))
        let id = splitString[0]
        let name = splitString[1]
        let lastName = splitString[2]
        //let pseudonym = splitString[3]
        let email = splitString[4]
        let expCondition = splitString[5]
        if(storeRealmUser(id: id, name: name, lastName: lastName, pseudonym: pseudonym, email: email, expCondition: expCondition)){
            completion(true)
        }
    }
    
    func storeUserLocally(id : String, name : String, lastName : String, pseudonym : String, email : String, expCondition : String, completion: (Bool) -> Void){
        
        if(storeRealmUser(id: id, name: name, lastName: lastName, pseudonym: pseudonym, email: email, expCondition: expCondition))
        {
            completion(true)
        }
        
    }
    
    
    
    
    /// Sets the value of the pseudonym property in the controller
    ///
    /// - Parameter pseudonym: String with the pseudonym
    func setPseudonym(pseudonym : String){
        self.pseudonym = pseudonym
    }
    
    
    /// Checks if the user data is already stored in the device disk
    ///
    /// - Returns: true if the user exists on device disk, false otherwise
    func checkIfUserExistsLocally() -> Bool{
        let realm = try! Realm()
        var matchedUsers = realm.objects(RealmUserModel.self)
        if (!matchedUsers.isEmpty){
            return true
        }
        else{
            return false
        }
    }
}
