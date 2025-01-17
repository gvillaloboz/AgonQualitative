//
//  RealmTrialModel.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 10.12.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import RealmSwift

class RealmTrialModel : Object{
    /// 0: not on trial
    /// 1: weekly trial started
    
    
    // Properties
    @objc dynamic var status = 0
    @objc dynamic var statusName = ""
    @objc dynamic var weeklyGoal = 0.0
    @objc dynamic var timeStamp = Date()
    @objc dynamic var assignment = 0 // number of assignmets to group, this is used to know when there is a first assignment
    @objc dynamic var group = 0
    @objc dynamic var endTimeStamp = Date()
    
    // Init
    convenience init(status: Int) {
        self.init()
    }
    
//    override static func primaryKey() ->Int? {
//        return statusCode
//    }

    
//    override static func primaryKey() ->String? {
//        return statusCode
//    }
    
    
    
//    func storeCompetitionStatus(status: Int, statusname : String){
//        let competitionStatus = RealmCompetitionModel()
//        competitionStatus.status = status
//        competitionStatus.statusName = statusName
//
//        let realm = try! Realm()
//
////        if let existingCompetitionStatus = realm.objects(ofType: RealmCompetitionStatusModel, forPrimaryKey: statusCode){
////            print("Competition Status Code already exists on disc")
////        }
//
//        try! realm.write {
//            realm.add(competitionStatus)
//        }
//    }

}
