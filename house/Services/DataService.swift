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
    var REF_HOUSES = DB_BASE.child("houses")
    var REF_USERS = DB_BASE.child("users")
    var REF_CHORES = DB_BASE.child("chores")
    var REF_SHOPPING = DB_BASE.child("shopping")
    var REF_DEBTS = DB_BASE.child("debts")
    
    private func attemptDatabaseAccess(handler: @escaping (_ userId: String, _ houseId: String) -> ()) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            guard let houseId = snapshot.childSnapshot(forPath: "houseId").value as? String else { return }
            
            handler(userId, houseId)
        }
    }
    
    
}

/*
 REGISTRATION RELATED
 OPERATIONS
 */
extension DataService {

    private func validateHouseRequest(withName name: String, andCode code: String, handler: @escaping (_ houseId: String?) -> ()) {
        REF_HOUSES.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for house in snapshot {
                    if (name == house.childSnapshot(forPath: "name").value as? String) {
                        if (code == house.childSnapshot(forPath: "code").value as? String) {
                            handler(house.key)
                        }
                    }
                }
            }
            
            handler(nil)
        }
    }
    
    func checkIfHouseExists(forName name: String, handler: @escaping (_ exists: Bool) -> ()) {
        self.REF_HOUSES.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for house in snapshot {
                    if (name == house.childSnapshot(forPath: "name").value as? String) {
                        handler(true)
                    } else {
                        handler(false)
                    }
                }
            }
        }
    }
    
    func createHouse(withName name: String, code: String, andNickname nickname: String, handler: @escaping () -> ()) {
        self.REF_HOUSES.childByAutoId().updateChildValues(["name": name, "code": code])
        
        handler()
    }
}

/*
 USER RELATED
 OPERATIONS
 */
extension DataService {
    
    func checkIfUserRegistered(handler: @escaping (_ registered: Bool) -> ()) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.childSnapshot(forPath: "houseId").value as? String  {
                handler(true)
            } else {
                handler(false)
            }
        }
    }
    
    func joinHouse(withName name: String, code: String, andNickname nickname: String, handler: @escaping () -> ()) {
        validateHouseRequest(withName: name, andCode: code) { (houseId) in
            if let houseId = houseId {
                guard let user = Auth.auth().currentUser else { return }
                let userId = user.uid
                
                self.REF_USERS.child(userId).updateChildValues(["houseId": houseId, "email": user.email!, "name": user.displayName!, "nickname": nickname])
                
                handler()
            }
        }
    }
    
    func saveToken(_ token: String) {
        attemptDatabaseAccess { (userId, houseId) in
            self.REF_USERS.child(userId).updateChildValues(["fcmToken": token])
            Messaging.messaging().subscribe(toTopic: houseId)
        }
    }
    
    func getUserData(handler: @escaping (_ user: User) -> ()) {
        attemptDatabaseAccess { (userId, houseId) in
            self.REF_USERS.child(houseId).child(userId).observeSingleEvent(of: .value) { (snapshot) in
                guard let name = snapshot.childSnapshot(forPath: "name").value as? String else { return }
                guard let nickname = snapshot.childSnapshot(forPath: "nickname").value as? String else { return }
                guard let email = snapshot.childSnapshot(forPath: "email").value as? String else { return }
                
                handler(User(userId: userId, name: name, nickname: nickname, email: email))
            }
        }
    }
    
    func getUsersNicknameIdPair(handler: @escaping (_ pairs: [String: String]) -> ()) {
        var pairs = [String: String]()
        
        attemptDatabaseAccess { (userId, houseId) in
            self.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for user in snapshot {
                        let id = user.key
                        guard let nickname = user.childSnapshot(forPath: "nickname").value as? String else { return }
                        guard let pulledHouseId = user.childSnapshot(forPath: "houseId").value as? String else { return }
                        
                        if pulledHouseId == houseId && id != userId {
                            pairs[nickname] = id
                        }
                    }
                    
                    handler(pairs)
                } else {
                    // TODO: Comprehensive error handler
                }
            }
        }
    }
    
    func getUserNickname(for Id: String, handler: @escaping (_ name: String) -> ()) {
        REF_USERS.child(Id).observeSingleEvent(of: .value) { (snapshot) in
            guard let nickname = snapshot.childSnapshot(forPath: "nickname").value as? String else { return }
            
            handler(nickname)
        }
    }
    
    func getCurrentUserNickname(handler: @escaping (_ nickname: String) -> ()) {
        attemptDatabaseAccess { (userId, _) in
            self.getUserNickname(for: userId, handler: { (nickname) in
                handler(nickname)
            })
        }
    }
    
    func getCurrentUserName(handler: @escaping (_ name: String) -> ()) {
        attemptDatabaseAccess { (userId, _) in
            self.REF_USERS.child(userId).observeSingleEvent(of: .value) { (snapshot) in
                guard let name = snapshot.childSnapshot(forPath: "name").value as? String else { return }
                
                handler(name)
            }
        }
    }
}

/*
 CHORE RELATED
 OPERATIONS
 */
extension DataService {
    
    func createChore(with content: String) {
        attemptDatabaseAccess { (userId, houseId) in
            self.REF_CHORES.child(houseId).childByAutoId().updateChildValues(["content": content, "author": userId, "date": Date().description])
        }
    }
    
    func getChores(handler: @escaping (_ chores: [Chore]) -> ()) {
        var chores = [Chore]()
        
        attemptDatabaseAccess { (_, houseId) in
            self.REF_CHORES.child(houseId).observeSingleEvent(of: .value) { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for chore in snapshot {
                        let choreId = chore.key
                        guard let content = chore.childSnapshot(forPath: "content").value as? String else { return }
                        guard let author = chore.childSnapshot(forPath: "author").value as? String else { return }
                        guard let date = chore.childSnapshot(forPath: "date").value as? String else { return }
                        
                        chores.append(Chore(choreId: choreId, content: content, author: author, date: date))
                    }
                    
                    handler(chores)
                } else {
                    // TODO: Comprehensive error handler
                }
            }
        }
    }
    
    func getAmountOfChores(handler: @escaping (_ amount: Int) -> ()) {
        var amount = 0
        
        attemptDatabaseAccess { (_, houseId) in
            self.REF_CHORES.child(houseId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for _ in snapshot {
                        amount += 1
                    }
                    
                    handler(amount)
                } else {
                    // TODO: Comprehensive error handler
                }
            })
        }
    }
    
    func deleteChore(with choreId: String) {
        attemptDatabaseAccess { (_, houseId) in
            self.REF_CHORES.child(houseId).child(choreId).removeValue()
        }
    }
}

/*
 SHOPPING RELATED
 OPERATIONS
 */
extension DataService {
    
    func createShoppingItem(with content: String) {
        attemptDatabaseAccess { (userId, houseId) in
            self.REF_SHOPPING.child(houseId).childByAutoId().updateChildValues(["content": content, "author": userId])
        }
    }
    
    func getShoppingItems(handler: @escaping (_ shoppingItems: [Shopping]) -> ()) {
        var shoppingItems = [Shopping]()
        
        attemptDatabaseAccess { (_, houseId) in
            self.REF_SHOPPING.child(houseId).observeSingleEvent(of: .value) { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for shopping in snapshot {
                        let shoppingId = shopping.key
                        guard let content = shopping.childSnapshot(forPath: "content").value as? String else { return }
                        guard let author = shopping.childSnapshot(forPath: "author").value as? String else { return }
                        
                        shoppingItems.append(Shopping(shoppingId: shoppingId, content: content, author: author))
                    }
                    
                    handler(shoppingItems)
                } else {
                    // TODO: Comprehensive error handler
                }
            }
        }
    }
    
    func getAmountOfShoppingItems(handler: @escaping (_ amount: Int) -> ()) {
        var amount = 0
        
        attemptDatabaseAccess { (_, houseId) in
            self.REF_SHOPPING.child(houseId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for _ in snapshot {
                        amount += 1
                    }
                    
                    handler(amount)
                } else {
                    // TODO: Comprehensive error handler
                }
            })
        }
    }
    
    func deleteShoppingItem(with choreId: String) {
        attemptDatabaseAccess { (_, houseId) in
            self.REF_SHOPPING.child(houseId).child(choreId).removeValue()
        }
    }
}

/*
 DEBT RELATED
 OPERATIONS
 */
extension DataService {
    
    func createDebt(from receiverId: String, for payerId: String, with amount: Int, and reason: String) {
        attemptDatabaseAccess { (userId, houseId) in
            self.REF_DEBTS.child(houseId).childByAutoId().updateChildValues([ "receiverId": receiverId, "payerId": payerId, "amount": amount, "reason": reason ])
        }
    }
    
    func getDebts(handler: @escaping (_ debts: [Debt]) -> ()) {
        var debts = [Debt]()
        
        attemptDatabaseAccess { (_, houseId) in
            self.REF_DEBTS.child(houseId).observeSingleEvent(of: .value) { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for debt in snapshot {
                        let userId = Auth.auth().currentUser?.uid
                        
                        guard let receiverId = debt.childSnapshot(forPath: "receiverId").value as? String else { return }
                        guard let payerId = debt.childSnapshot(forPath: "payerId").value as? String else { return }
                        
                        if receiverId == userId || payerId == userId {
                            let debtId = debt.key
                            guard let reason = debt.childSnapshot(forPath: "reason").value as? String else { return }
                            guard let amount = debt.childSnapshot(forPath: "amount").value as? Int else { return }
                            let isPaying = (payerId == userId)
                            
                            debts.append(Debt(debtId: debtId, isPaying: isPaying, receiverId: receiverId, payerId: payerId, reason: reason, amount: amount))
                        }
                    }
                    
                    handler(debts)
                } else {
                    // TODO: Comprehensive error handler
                }
            }
        }
    }
    
    func getAmountOfOutstandingDebts(handler: @escaping (_ amount: Int) -> ()) {
        var amount = 0
        
        attemptDatabaseAccess { (userId, houseId) in
            self.REF_DEBTS.child(houseId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for debt in snapshot {
                        guard let payerId = debt.childSnapshot(forPath: "payerId").value as? String else { return }
                        
                        if payerId == userId {
                            amount += 1
                        }
                    }
                    
                    handler(amount)
                } else {
                    // TODO: Comprehensive error handler
                }
            })
        }
    }
    
    func changeDebtAmount(for debtId: String, with newAmount: Int) {
        attemptDatabaseAccess { (_, houseId) in
            self.REF_DEBTS.child(debtId).setValue(["amount", newAmount])
        }
    }
    
    func deleteDebt(with debtId: String) {
        attemptDatabaseAccess { (_, houseId) in
            self.REF_DEBTS.child(debtId).child(debtId).removeValue()
        }
    }
}


