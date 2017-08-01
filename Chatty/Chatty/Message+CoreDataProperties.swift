//
//  Message+CoreDataProperties.swift
//  Chatty
//
//  Created by LiangXiaosheng on 2017/4/23.
//  Copyright © 2017年 LiangXiaosheng. All rights reserved.
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var isSender: Bool
    @NSManaged public var friend: Friend?

}
