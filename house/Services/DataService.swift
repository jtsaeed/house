//
//  DataService.swift
//  house
//
//  Created by James Saeed on 19/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = Database.database().reference()

class DataService {
    static let instance = DataService()
    
    var REF_BASE = DB_BASE
    var REF_USERS = DB_BASE.child("users")
    var REF_CHORES = DB_BASE.child("chores")
    var REF_DEBTS = DB_BASE.child("debts")
    
    func createChore(withContent content: String, completion: @escaping (_ success: Bool) -> ()) {
        REF_CHORES.childByAutoId().updateChildValues(["content": content])
        completion(true)
    }
    
    func createDebt(from receiverId: String, for payerId: String, withAmount amount: Int) {
        REF_DEBTS.childByAutoId().updateChildValues(["amount": amount, "receiverId": receiverId, "payerId": payerId])
    }
    
    func getUser(handler: @escaping (_ user: User) -> ()) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let nickname = snapshot.childSnapshot(forPath: "nickname").value as! String
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            
            handler(User(userId: userId, name: name, nickname: nickname, email: email))
        }
    }
    
    func getChores(handler: @escaping (_ chores: [Chore]) -> ()) {
        var chores = [Chore]()
        
        REF_CHORES.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for chore in snapshot {
                    let choreId = chore.key
                    let content = chore.childSnapshot(forPath: "content").value as! String
                    
                    chores.append(Chore(choreId: choreId, content: content))
                }
                
                handler(chores)
            } else {
                // TODO: Comprehensive error handler
            }
        }
        
    }
}
