//
//  Places.swift
//  toVisitPlaces_Jyothi_C0775696
//
//  Created by user176475 on 6/15/20.
//  Copyright © 2020 user176475. All rights reserved.
//

class Places{
    
    var placeLat: Double
    var placeLong: Double
    var placeName :String
    var city :String
    var postalCode : String
    var country : String
    
    init(placeLat:Double , placeLong: Double, placeName:String, city:String, postalCode: String, country:String) {
        self.placeLat = placeLat
        self.placeLong = placeLong
        self.placeName = placeName
        self.city = city
        self.postalCode = postalCode
        self.country = country
    }
    
    
}
