//
//  BlackBox.swift
//  aivision-ios
//
//  Created by Chris Parsons on 05/04/2018.
//  Copyright © 2018 Chris Parsons. All rights reserved.
//

import Foundation

//Neat threads yo...
func performUIUpdatesOnMain(_ updates: @escaping ()-> Void){
    DispatchQueue.main.async {
        updates()
    }
}

func generateBoundaryString() -> String {
    return "Boundary-\(NSUUID().uuidString)"
}
