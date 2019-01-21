//
//  CompetitionController.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 24.12.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import RealmSwift

class CompetitionController {
    
    func storeCompetitionStatusLocally(weeklyGoal : Double, status : Int ,completion: (Bool) -> Void){
        let competition = RealmCompetitionModel()
        competition.weeklyGoal = weeklyGoal
        competition.status = status
        competition.timeStamp = Date()
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(competition)
        }
        completion(true)
        //return true
    }
    
    
    
    /// Queries and returns the competition status from realm
    /// Returns 0 if there competition has not started ///check! it was -1 for no status competition
    /// Else, returns the code of the competition
    ///
    /// - Returns: competition status code from Realm
    func getCompetitionStatus() -> Int{
        let realm = try! Realm()
        var competitionStatus = 0
        
        if (!realm.objects(RealmCompetitionModel.self).isEmpty){
            competitionStatus = (realm.objects(RealmCompetitionModel.self).last?.status)!
        }
        return competitionStatus
    }
}
