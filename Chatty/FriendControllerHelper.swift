//
//  FriendControllerHelper.swift
//  Chatty
//
//  Created by LiangXiaosheng on 2017/4/22.
//  Copyright © 2017 LiangXiaosheng. All rights reserved.
//

import UIKit
import CoreData

extension FriendsController {
    
    func clearData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            
            do {
                
                let entityNames = ["Friend", "Message"]
                
                for entityName in entityNames {
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    
                    let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
                    
                    for object in objects! {
                        context.delete(object)
                    }
                    
                }
                
                try context.save()
                
            } catch let err {
                print (err)
            }
        }
    }
    
    
    func setupData() {
        
        clearData()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext{
            
            let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            mark.name = "Mark Zuckerburg"
            mark.profileImageName = "zucke"
            
            let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            message.friend = mark
            message.text = "Hello, my name is Zuckerburg. Nice to meet you."
            message.date = NSDate()
            
            let steve = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            steve.name = "Steve Jobs"
            steve.profileImageName = "steve"
            
            FriendsController.createMessageWithText(text: "Good morning...", friend: steve, minsAgo: 13, context: context)
            FriendsController.createMessageWithText(text: "Hello, How are you", friend: steve, minsAgo: 12, context: context, isSender: true)
            FriendsController.createMessageWithText(text: "Are you interested in buying an Apple device? We have wide variety that will suit your needs.", friend: steve, minsAgo: 11, context: context)
            // respond message
            FriendsController.createMessageWithText(text: "Yes, I'm looking for an iPhone 7", friend: steve, minsAgo: 10, context: context, isSender: true)
            FriendsController.createMessageWithText(text: "Totally understand that you want a new iPhone, but you'll have to wait until September for new release. Sorry for that.", friend: steve, minsAgo: 9, context: context)
            FriendsController.createMessageWithText(text: "Absolutely, I'll just use my old one until then.", friend: steve, minsAgo: 8, context: context, isSender: true)
            FriendsController.createMessageWithText(text: "Thanks for your understanding.", friend: steve, minsAgo: 7, context: context)
            FriendsController.createMessageWithText(text: "You're welcome!", friend: steve, minsAgo: 6, context: context, isSender: true)

            let donald = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            donald.name = "Donald Trump"
            donald.profileImageName = "donald"
            
            FriendsController.createMessageWithText(text: "American Dream", friend: donald, minsAgo: 5, context: context)

            let hillary = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            hillary.name = "Hillary Cliton"
            hillary.profileImageName = "hillary"
            
            FriendsController.createMessageWithText(text: "i would win", friend: hillary, minsAgo: 10, context: context)
            

            do {
                try(context.save())
            }catch let err{
                print(err)
            }
        }
        loadData()
        
    }
    
    //the method of create messages
    @discardableResult
    static func createMessageWithText(text:String,
                                      friend:Friend,
                                      minsAgo:Double,
                                      context:NSManagedObjectContext,
                                      isSender:Bool = false) -> Message{
        
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.friend = friend
        message.text = text
        message.date = NSDate().addingTimeInterval(-minsAgo*60)
        message.isSender = isSender
        return message
    }

    func loadData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            
            if let friends = fetchFriends() {
                
                messages = [Message]()
                
                for friend in friends {
                    
//                  print (friend.name!)
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                    
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)] // put all the messages in order of one friend
                    
                    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
                    fetchRequest.fetchLimit = 1
                    
                    do {
                        let fetchedMessages = try context.fetch(fetchRequest) as? [Message]
                        messages?.append(contentsOf: fetchedMessages!)
                    } catch let err {
                        print (err)
                    }
                }
                
                messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedDescending}) // sort different friends' messages
                
            }
        }
    }
    
    private func fetchFriends() -> [Friend]? {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
            
            do {
                return try context.fetch(request) as? [Friend]
            
            } catch let err {
                print (err)
            }
        }
        
        return nil

    }

}
