//
//  List.swift
//  ListOnWatchW Extension
//
//  Created by Yali Xiao on 2019-06-21.
//  Copyright © 2019 weizhi.ca. All rights reserved.
//

import WatchKit

class List: NSObject {
    
    var id: Int
    var itemName: String?
    
    var check : Int
    
    var current: Int
    
    var listId : Int
    
    init(id: Int,itemName: String?,current:Int,check:Int,listId:Int){
        self.id = id
        self.itemName = itemName
        self.check = check
        self.current=current
        self.listId=listId
        
    }

}
