//
//  DataService.swift
//  house
//
//  Created by James Saeed on 19/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import Foundation
import Firebase

public class DataService {
    
    public static let instance = DataService()
    
    private var REF_BASE: DatabaseReference { return Database.database().reference() }
    private var REF_HOUSES: DatabaseReference { return Database.database().reference().child("houses") }
    private var REF_USERS: DatabaseReference { return Database.database().reference().child("users") }
    private var REF_CHORES: DatabaseReference { return Database.database().reference().child("chores") }
    private var REF_SHOPPING: DatabaseReference { return Database.database().reference().child("shopping") }
    private var REF_DEBTS: DatabaseReference { return Database.database().reference().child("debts") }
    
    public func configure() {
        FirebaseApp.configure()
    }
    
    /// Accesses the database and pulls the User ID and their respective house ID
    private func attemptDatabaseAccess(completion: @escaping (_ userId: String, _ houseId: String) -> ()) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            guard let houseId = snapshot.childSnapshot(forPath: "houseId").value as? String else { return }
            
            completion(userId, houseId)
        }
    }
}

// MARK: - House

extension DataService {

    /// Makes sure that the user is requesting a house that exists with a valid code
    private func validateHouseRequest(withName name: String, andCode code: String, completion: @escaping (_ houseId: String?) -> ()) {
        REF_HOUSES.observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for house in snapshot {
                if (name == house.childSnapshot(forPath: "name").value as? String) {
                    if (code == house.childSnapshot(forPath: "code").value as? String) {
                        completion(house.key)
                        return
                    }
                }
            }
            
            completion(nil)
        }
    }
    
    /// Returns whether or not the requested house already exists
    public func checkIfHouseExists(_ name: String, completion: @escaping (_ exists: Bool) -> ()) {
        self.REF_HOUSES.observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for house in snapshot {
                guard let pulledName = house.childSnapshot(forPath: "name").value as? String else { return }
                if name == pulledName {
                    completion(true)
                    return
                }
            }
            
            completion(false)
        }
    }
    
    /// Creates a new house with a specified unique name and code
    public func createHouse(_ name: String, _ code: String, completion: @escaping () -> ()) {
        self.REF_HOUSES.childByAutoId().updateChildValues(["name": name, "code": code])
        
        completion()
    }
    
    /// Returns the name and code for the user's house
    public func getHouseInfo(completion: @escaping (_ name: String, _ code: String) -> ()) {
        attemptDatabaseAccess { (_, houseId) in
            self.REF_HOUSES.child(houseId).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let name = snapshot.childSnapshot(forPath: "name").value as? String else { return }
                guard let code = snapshot.childSnapshot(forPath: "code").value as? String else { return }
                
                completion(name, code)
            })
        }
    }
}

// MARK: - Users

extension DataService {
    
    /// Checks if the user has an associated house
    public func checkIfUserRegistered(completion: @escaping (_ registered: Bool) -> ()) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.childSnapshot(forPath: "houseId").value as? String {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// If the house request is valid, associates the user with the house
    public func joinHouse(_ name: String, _ code: String, _ nickname: String, completion: @escaping (_ success: Bool) -> ()) {
        validateHouseRequest(withName: name, andCode: code) { (houseId) in
            if let houseId = houseId {
                guard let user = Auth.auth().currentUser else { return }
                let userId = user.uid
                
                self.REF_USERS.child(userId).updateChildValues(["houseId": houseId, "email": user.email!, "name": user.displayName!.capitalized, "nickname": nickname.capitalized])
                
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// Removes the user's association with the house they are currently in
    public func leaveHouse() {
        attemptDatabaseAccess { (userId, houseId) in
            self.REF_USERS.child(userId).child("houseId").removeValue()
        }
    }
    
    /// Saves the user's fcm token
    public func saveToken(_ token: String) {
        attemptDatabaseAccess { (userId, houseId) in
            self.REF_USERS.child(userId).updateChildValues(["fcmToken": token])
            Messaging.messaging().subscribe(toTopic: houseId)
        }
    }
    
    /// Pulls the IDs and corresponding names of all the users in the house except the current user
    public func getUsersNameIdPair(completion: @escaping (_ pairs: [String : String]) -> ()) {
        var pairs = [String : String]()
        
        attemptDatabaseAccess { (userId, houseId) in
            self.REF_USERS.observe(.value) { (snapshot) in
                guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                for user in snapshot {
                    let id = user.key
                    guard let name = user.childSnapshot(forPath: "name").value as? String else { return }
                    guard let pulledHouseId = user.childSnapshot(forPath: "houseId").value as? String else { continue }
                        
                    if pulledHouseId == houseId && id != userId {
                        pairs[name] = id
                    }
                }
                    
                completion(pairs)
            }
        }
    }
    
    /// Get a specified user's nickname
    public func getUserNickname(for Id: String, completion: @escaping (_ name: String) -> ()) {
        REF_USERS.child(Id).observeSingleEvent(of: .value) { (snapshot) in
            guard let nickname = snapshot.childSnapshot(forPath: "nickname").value as? String else { return }
            
            completion(nickname)
        }
    }
    
    /// Get the user's nickname
    public func getCurrentUserNickname(completion: @escaping (_ nickname: String) -> ()) {
        attemptDatabaseAccess { (userId, _) in
            self.getUserNickname(for: userId, completion: { (nickname) in
                completion(nickname)
            })
        }
    }
}

// MARK: - Chores

extension DataService {
    
    /// Adds a new chore to the user's house
    public func createChore(with content: String) {
        attemptDatabaseAccess { (userId, houseId) in
            self.REF_CHORES.child(houseId).childByAutoId().updateChildValues(["content": content.lowercased(), "author": userId])
        }
    }
    
    /// Returns all the chores for the user's house
    public func getChores(completion: @escaping (_ chores: [Chore]) -> ()) {
        attemptDatabaseAccess { (_, houseId) in
            self.REF_CHORES.child(houseId).observe(.value) { (snapshot) in
                guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                var chores = [Chore]()
                for chore in snapshot {
                    let choreId = chore.key
                    guard let content = chore.childSnapshot(forPath: "content").value as? String else { return }
                    guard let author = chore.childSnapshot(forPath: "author").value as? String else { return }
                        
                    chores.append(Chore(choreId: choreId, content: content, author: author))
                }
                    
                completion(chores)
            }
        }
    }
    
    /// Returns the amount of chores for the user's house
    public func getAmountOfChores(completion: @escaping (_ amount: Int) -> ()) {
        attemptDatabaseAccess { (_, houseId) in
            self.REF_CHORES.child(houseId).observe(.value, with: { (snapshot) in
                guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                var amount = 0
                for _ in snapshot {
                    amount += 1
                }
                    
                completion(amount)
            })
        }
    }
    
    /// Deletes a specified chore within the user's house
    public func deleteChore(with choreId: String) {
        attemptDatabaseAccess { (_, houseId) in
            self.REF_CHORES.child(houseId).child(choreId).removeValue()
        }
    }
}

// MARK: - Shopping

extension DataService {
    
    /// Adds a new shopping item to the user's house
    public func createShoppingItem(with content: String) {
        attemptDatabaseAccess { (userId, houseId) in
            self.REF_SHOPPING.child(houseId).childByAutoId().updateChildValues(["content": content.lowercased(), "author": userId])
        }
    }
    
    /// Returns all the shopping items for the user's house
    public func getShoppingItems(completion: @escaping (_ shoppingItems: [Shopping]) -> ()) {
        attemptDatabaseAccess { (_, houseId) in
            self.REF_SHOPPING.child(houseId).observe(.value) { (snapshot) in
                guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                var shoppingItems = [Shopping]()
                for shopping in snapshot {
                    let shoppingId = shopping.key
                    guard let content = shopping.childSnapshot(forPath: "content").value as? String else { return }
                    guard let author = shopping.childSnapshot(forPath: "author").value as? String else { return }
                        
                    shoppingItems.append(Shopping(shoppingId: shoppingId, content: content, author: author))
                }
                    
                completion(shoppingItems)
            }
        }
    }
    
    /// Returns the amount of shopping items for the user's house
    public func getAmountOfShoppingItems(completion: @escaping (_ amount: Int) -> ()) {
        attemptDatabaseAccess { (_, houseId) in
            self.REF_SHOPPING.child(houseId).observe(.value, with: { (snapshot) in
                guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                var amount = 0
                for _ in snapshot {
                    amount += 1
                }
                    
                completion(amount)
            })
        }
    }
    
    /// Deletes a specified shopping item within the user's house
    public func deleteShoppingItem(with choreId: String) {
        attemptDatabaseAccess { (_, houseId) in
            self.REF_SHOPPING.child(houseId).child(choreId).removeValue()
        }
    }
}

// MARK: - Debts

extension DataService {
    
    /// Adds a new debt from the user for a specified user in the house
    public func createDebt(for payerId: String, with amount: Int, and reason: String) {
        attemptDatabaseAccess { (userId, houseId) in
            self.REF_DEBTS.child(houseId).childByAutoId().updateChildValues([ "receiverId": userId, "payerId": payerId, "amount": amount, "reason": reason.lowercased()])
        }
    }
    
    /// Returns all the debts involving the user within the house
    public func getDebts(completion: @escaping (_ debts: [Debt]) -> ()) {
        attemptDatabaseAccess { (_, houseId) in
            self.REF_DEBTS.child(houseId).observe(.value) { (snapshot) in
                guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                var debts = [Debt]()
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
                    
                completion(debts)
            }
        }
    }
    
    /// Returns the amount of outstanding debts that the user has within the house
    public func getAmountOfOutstandingDebts(completion: @escaping (_ amount: Int) -> ()) {
        attemptDatabaseAccess { (userId, houseId) in
            self.REF_DEBTS.child(houseId).observe(.value, with: { (snapshot) in
                guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                var amount = 0
                for debt in snapshot {
                    guard let payerId = debt.childSnapshot(forPath: "payerId").value as? String else { return }
                    
                    if payerId == userId {
                        amount += 1
                    }
                }
                    
                completion(amount)
            })
        }
    }
    
    /// Changes the amount for a specific debt within the user's house
    public func changeDebtAmount(for debtId: String, with newAmount: Int) {
        attemptDatabaseAccess { (_, houseId) in
            self.REF_DEBTS.child(debtId).setValue(["amount", newAmount])
        }
    }
    
    /// Deletes a specified debt within the user's house
    public func deleteDebt(with debtId: String) {
        attemptDatabaseAccess { (_, houseId) in
            self.REF_DEBTS.child(houseId).child(debtId).removeValue()
        }
    }
}
