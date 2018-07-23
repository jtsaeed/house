//
//  NewDataService.swift
//  house
//
//  Created by James Saeed on 23/07/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import Foundation
import Firebase

let NEW_DB_REF = Firestore.firestore()
let settings = NEW_DB_REF.settings

class NewDataService {
    
    static let instance = NewDataService()
    let userDefaults = UserDefaults.standard
    
    init() {
        settings.isPersistenceEnabled = true
        settings.areTimestampsInSnapshotsEnabled = true
        NEW_DB_REF.settings = settings
    }
    
    private func getUserId() -> String {
        return userDefaults.object(forKey: "userId") as? String ?? ""
    }
    
    private func getHouseId() -> String {
        return userDefaults.object(forKey: "houseId") as? String ?? ""
    }
}

// MARK: - House

extension NewDataService {
    
    private func getHousesRef() -> CollectionReference {
        return NEW_DB_REF.collection("houses")
    }
    
    private func validateHouseRequest(withName name: String, andCode code: String, completion: @escaping (_ houseId: String?) -> ()) {
        
        getHousesRef().getDocuments { (snapshot, error) in
            for document in snapshot!.documents {
                if name == document.data()["name"] as? String && code == document.data()["code"] as? String {
                    completion(document.documentID)
                    return
                }
            }
            completion(nil)
        }
    }
    
    func joinHouse(_ name: String, _ code: String, _ nickname: String, completion: @escaping () -> ()) {
        validateHouseRequest(withName: name, andCode: code) { (houseId) in
            if let houseId = houseId {
                guard let user = Auth.auth().currentUser else { return }
                let userId = user.uid
                
                self.getUsersRef().document(userId).setData(["houseId": houseId, "email": user.email!, "name": user.displayName!, "nickname": nickname])
                completion()
            }
        }
    }
    
    func checkIfHouseExists(_ name: String, completion: @escaping (_ exists: Bool) -> ()) {
        getHousesRef().getDocuments { (snapshot, error) in
            for document in snapshot!.documents {
                if name == document.data()["name"] as? String {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func createHouse(_ name: String, _ code: String, _ nickname: String) {
        getHousesRef().addDocument(data: ["name": name, "code": code])
    }
    
    func getHouseInfo(completion: @escaping (_ name: String, _ code: String) -> ()) {
        getHousesRef().document(getHouseId()).getDocument { (snapshot, error) in
            guard let name = snapshot?.data()!["name"] as? String else { return }
            guard let code = snapshot?.data()!["code"] as? String else { return }
            
            completion(name, code)
        }
    }
}

// MARK: - Users

extension NewDataService {
    
    private func getUsersRef() -> CollectionReference {
        return NEW_DB_REF.collection("users")
    }
    
    func checkIfUserRegistered(handler: @escaping (_ registered: Bool) -> ()) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        getUsersRef().document(userId).getDocument { (snapshot, error) in
            if let _ = snapshot?.data()!["houseId"] as? String {
                handler(true)
            } else {
                handler(false)
            }
        }
    }
    
    func saveToken(_ token: String) {
        getUsersRef().document(getUserId()).setData(["fcmToken": token])
        Messaging.messaging().subscribe(toTopic: getHouseId())
    }
    
    func getUserData(completion: @escaping (_ user: User) -> ()) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        getUsersRef().document(getUserId()).getDocument { (snapshot, error) in
            guard let houseId = snapshot?.data()!["houseId"] as? String else { return }
            guard let name = snapshot?.data()!["name"] as? String else { return }
            guard let nickname = snapshot?.data()!["nickname"] as? String else { return }
            guard let email = snapshot?.data()!["email"] as? String else { return }
            
            completion(User(userId: userId, houseId: houseId, name: name, nickname: nickname, email: email))
        }
    }
    
    func getUsersNicknameIdPair(completion: @escaping (_ pairs: [String: String]) -> ()) {
        getUsersRef().getDocuments { (snapshot, error) in
            var pairs = [String : String]()
            for document in snapshot!.documents {
                let userId = document.documentID
                guard let nickname = document.data()["nickname"] as? String else { return }
                guard let houseId = document.data()["houseId"] as? String else { return }
                
                if houseId == self.getHouseId() && userId != self.getUserId() {
                    pairs[nickname] = userId
                }
            }
            completion(pairs)
        }
    }
}

// MARK: - Chores

extension NewDataService {
    
    private func getChoresRef() -> CollectionReference {
        return NEW_DB_REF.collection("chores").document(getHouseId()).collection("chores")
    }
    
    func createChore(with content: String) {
        getChoresRef().addDocument(data: ["content": content, "author": getUserId(), "timestamp": FieldValue.serverTimestamp()])
    }
    
    func getChores(completion: @escaping (_ chores: [Chore]) -> ()) {
        getChoresRef().order(by: "timestamp", descending: false).addSnapshotListener { (snapshot, error) in
            var chores = [Chore]()
            for document in snapshot!.documents {
                let choreId = document.documentID
                guard let content = document.data()["content"] as? String else { break }
                guard let author = document.data()["author"] as? String else { break }
                guard let timestamp = document.data()["timestamp"] as? Timestamp else { break }
                
                chores.append(Chore(choreId: choreId, content: content, author: author, date: timestamp.dateValue()))
            }
            completion(chores)
        }
    }
    
    func getAmountOfChores(completion: @escaping (_ amount: Int) -> ()) {
        getChoresRef().addSnapshotListener { (snapshot, error) in
            var amount = 0
            for _ in snapshot!.documents {
                amount += 1
            }
            completion(amount)
        }
    }
    
    func deleteChore(with choreId: String) {
        getChoresRef().document(choreId).delete()
    }
}

// MARK: - Shopping

extension NewDataService {
    
    private func getShoppingRef() -> CollectionReference {
        return NEW_DB_REF.collection("shopping").document(getHouseId()).collection("shopping")
    }
    
    func createShoppingItem(with content: String) {
        getShoppingRef().addDocument(data: ["content": content, "author": getUserId(), "timestamp": FieldValue.serverTimestamp()])
    }
    
    func getShoppingItems(completion: @escaping (_ chores: [Chore]) -> ()) {
        getShoppingRef().order(by: "timestamp", descending: false).addSnapshotListener { (snapshot, error) in
            var chores = [Chore]()
            for document in snapshot!.documents {
                let choreId = document.documentID
                guard let content = document.data()["content"] as? String else { break }
                guard let author = document.data()["author"] as? String else { break }
                guard let timestamp = document.data()["timestamp"] as? Timestamp else { break }
                
                chores.append(Chore(choreId: choreId, content: content, author: author, date: timestamp.dateValue()))
            }
            completion(chores)
        }
    }
    
    func getAmountOfShoppingItems(completion: @escaping (_ amount: Int) -> ()) {
        getShoppingRef().addSnapshotListener { (snapshot, error) in
            var amount = 0
            for _ in snapshot!.documents {
                amount += 1
            }
            completion(amount)
        }
    }
    
    func deleteShoppingItem(with shoppingId: String) {
        getShoppingRef().document(shoppingId).delete()
    }
}

// MARK: - Debts

extension NewDataService {
    
    private func getDebtsRef() -> CollectionReference {
        return NEW_DB_REF.collection("debts").document(getHouseId()).collection("debts")
    }
    
    func createDebt(for payer: String, with amount: Int, and reason: String) {
        getDebtsRef().addDocument(data: ["receiver": getUserId(), "payer": payer, "amount": amount, "reason": reason])
    }
    
    func getDebts(completion: @escaping (_ debts: [Debt]) -> ()) {
        getDebtsRef().addSnapshotListener { (snapshot, error) in
            var debts = [Debt]()
            for document in snapshot!.documents {
                guard let receiver = document.data()["receiever"] as? String else { return }
                guard let payer = document.data()["payer"] as? String else { return }
                
                if receiver == self.getUserId() || payer == self.getUserId() {
                    let debtId = document.documentID
                    guard let reason = document.data()["reason"] as? String else { return }
                    guard let amount = document.data()["amount"] as? Int else { return }
                    let isPaying = (payer == self.getUserId())
                    
                    debts.append(Debt(debtId: debtId, isPaying: isPaying, receiverId: receiver, payerId: payer, reason: reason, amount: amount))
                }
            }
            completion(debts)
        }
    }
    
    func getAmountOfOutstandingDebts(completion: @escaping (_ amount: Int) -> ()) {
        getDebtsRef().addSnapshotListener { (snapshot, error) in
            var amount = 0
            for document in snapshot!.documents {
                guard let payer = document.data()["payer"] as? String else { return }
                
                if payer == self.getUserId() {
                    amount += 1
                }
            }
            completion(amount)
        }
    }
    
    func changeDebtAmount(for debtId: String, with newAmount: Int) {
        getDebtsRef().document(debtId).setData(["amount": newAmount])
    }
    
    func deleteDebt(with debtId: String) {
        getDebtsRef().document(debtId).delete()
    }
}
