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
    
    func createChore(with content: String) {
        REF_CHORES.childByAutoId().updateChildValues(["content": content])
    }
    
    func createDebt(from receiverId: String, for payerId: String, with amount: Int, and reason: String) {
        REF_DEBTS.childByAutoId().updateChildValues([ "receiverId": receiverId, "payerId": payerId, "amount": amount, "reason": reason ])
    }
    
    func getUserData(handler: @escaping (_ user: User) -> ()) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let nickname = snapshot.childSnapshot(forPath: "nickname").value as! String
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            
            handler(User(userId: userId, name: name, nickname: nickname, email: email))
        }
    }
    
    func getUserNickname(for Id: String, handler: @escaping (_ name: String) -> ()) {
        REF_USERS.child(Id).observeSingleEvent(of: .value) { (snapshot) in
            let nickname = snapshot.childSnapshot(forPath: "nickname").value as! String
            
            handler(nickname)
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
