//
//  Numerical.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 10.12.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation


extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}


class Numerical{
    
    
    func convertDateToString(date : Date) -> String{
        var myStringafd : String
        
        let locale = NSLocale.current
        let f : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
        if f.contains("a") {
            //phone is set to 12 hours
            print("12hr")
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date
            formatter.dateFormat = "yyyy-MM-dd H:mm:ss a"
            //formatter.timeZone = TimeZone(identifier: "UTC")!
            formatter.timeZone = NSTimeZone.local
            let myString = formatter.string(from: date)
            // convert your string to date
            let yourDate = formatter.date(from: myString)
            formatter.locale = Locale(identifier: "en_US_POSIX") //ARG
            //then again set the date format whhich type of output you need
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            // again convert your date to string
            myStringafd = formatter.string(from: yourDate!)
            
            
        } else {
            //phone is set to 24 hours
            print("24hr")
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //formatter.timeZone = TimeZone(identifier: "UTC")!
            formatter.timeZone = NSTimeZone.local
            let myString = formatter.string(from: date)
            // convert your string to date
            let yourDate = formatter.date(from: myString)
            //then again set the date format whhich type of output you need
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            // again convert your date to string
            myStringafd = formatter.string(from: yourDate!)
            
            //print(myStringafd)
        }
        
        return myStringafd
    }
}

