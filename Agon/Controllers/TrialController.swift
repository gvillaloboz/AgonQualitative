//
//  TrialController.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 24.12.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import RealmSwift

class TrialController                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                {
    
    func storeTrialObjectLocally(weeklyGoal : Double, status : Int, endTimeStamp : Date ,completion: (Bool) -> Void){
        let trial = RealmTrialModel()
        trial.weeklyGoal = weeklyGoal
        trial.status = status
        trial.timeStamp = Date() // do not know what this is used for
        trial.endTimeStamp = endTimeStamp // determine the date when the trial ends and a new trial should begin
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(trial)
        }
        completion(true)
        //return true
    }
    
    
    /// Queries and returns the weeklyGoal from realm
    /// Returns -1 if there is no weekely goal stored
    /// Else, returns the weekly goal
    ///
    /// - Returns: trial status code from Realm
    func getWeeklyGoal() -> Double{
        let realm = try! Realm()
        var weeklyGoal = -1.0
        
        if (!realm.objects(RealmTrialModel.self).isEmpty){
            weeklyGoal = (realm.objects(RealmTrialModel.self).last?.weeklyGoal)!
        }
        return weeklyGoal
    }
    
    /// Updates the trial status if needed then queries
    /// Queries and returns the trial status from realm
    /// Returns 0 if there trial has not started ///check! it was -1 for no status trial
    /// Else, returns the code of the trial
    ///
    /// - Returns: trial status code from Realm
    func getTrialStatus() -> Int{
        updateTrialStatus()
        
        let realm = try! Realm()
        var trialStatus = 0
        
        if (!realm.objects(RealmTrialModel.self).isEmpty){
            trialStatus = (realm.objects(RealmTrialModel.self).last?.status)!
        }
        return trialStatus
    }
    
    
    /// Queries and returns the trial end timestamp from realm
    ///
    /// - Returns: returns the current date if there is no trial started
    func getTrialEndTimeStamp() -> Date {
        let realm = try! Realm()
        var trialEndTimeStamp = Date()
        
        if(!realm.objects(RealmTrialModel.self).isEmpty){
            trialEndTimeStamp = (realm.objects(RealmTrialModel.self).last?.endTimeStamp)!
        }
        return trialEndTimeStamp
    }
    
    
    /// Queries and returns the last competition assignment
    /// This is used to make the first assignment of groups.
    /// - Returns: the last assignment to group
    func getTrialAssignment() -> Int {
        let realm = try! Realm()
        var trialAssignment = 0
        
        if (!realm.objects(RealmTrialModel.self).isEmpty){
            trialAssignment = (realm.objects(RealmTrialModel.self).last?.assignment)!
        }
        return trialAssignment
    }
    
    
    /// Updates the status of the current trial
    /// If the current date is smaller than the end trial timestamp no update is made
    /// If the current date is larger than the end trial timestamp an update is made
    /// A status of 0 means no running trial
    /// A status of 1 means running trial
    ///
    /// - Returns: 0 if no update was made, 1 if an update was made
    func updateTrialStatus() -> Int{
        if(Date() < getTrialEndTimeStamp()){
            //Still in competition for this week
            return 0
        }
        else{
            storeTrialObjectLocally(weeklyGoal: getWeeklyGoal(), status : 0, endTimeStamp: Date(),  completion: { success in
                print("Trial Status succesfully updated in local realm")
            })
            return 1 // check execution time
        }
    }
}
