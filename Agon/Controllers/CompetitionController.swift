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
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(competition)
        }
        completion(true)
        //return true
    }
}
