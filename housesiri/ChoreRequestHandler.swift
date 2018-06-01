//
//  ChoreRequestHandler.swift
//  housesiri
//
//  Created by James Saeed on 01/06/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import Intents

class ChoreRequestHandler: NSObject, INAddTasksIntentHandling {
    
    func handle(intent: INAddTasksIntent, completion: @escaping (INAddTasksIntentResponse) -> Void) {
        let response = INAddTasksIntentResponse(code: .failureRequiringAppLaunch, userActivity: .none)
        completion(response)
    }
    
    
}
