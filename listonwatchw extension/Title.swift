//
//  Title.swift
//  ListOnWatchW Extension
//
//  Created by Yali Xiao on 2019-06-19.
//  Copyright © 2019 weizhi.ca. All rights reserved.
//

import WatchKit

class Title: NSObject {
    var id: Int
    var title: String?
    var current: Int
    
    init(id: Int,title: String?,current:Int){
        self.id = id
        self.title = title
        self.current = current
        
    }

}
