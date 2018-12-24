//
//  RealmCompetitionStatusModel.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 10.12.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCompetitionStatusModel : Object{
    /// 0: not on competition
    /// 1: weekly competition started
    ///
    
    // Properties
    @objc dynamic var statusCode = 0
    @objc dynamic var statusName = ""
    
    // Init
    convenience init(statusCode: String) {
        self.init()
    }
    
//    override static func primaryKey() ->Int? {
//        return statusCode
//    }

    
//    override static func primaryKey() ->String? {
//        return statusCode
//    }
    
    
    
    func storeCompetitionStatus(statusCode: Int, statusname : String){
        let competitionStatus = RealmCompetitionStatusModel()
        competitionStatus.statusCode = statusCode
        competitionStatus.statusName = statusName
        
        let realm = try! Realm()
        
//        if let existingCompetitionStatus = realm.objects(ofType: RealmCompetitionStatusModel, forPrimaryKey: statusCode){
//            print("Competition Status Code already exists on disc")
//        }
        
        try! realm.write {
            realm.add(competitionStatus)
        }
    }

}
