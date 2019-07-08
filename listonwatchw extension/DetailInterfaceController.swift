//
//  DetailInterfaceController.swift
//  ListOnWatchW Extension
//
//  Created by Yali Xiao on 2019-06-21.
//  Copyright © 2019 weizhi.ca. All rights reserved.
//

import WatchKit
import Foundation
import SQLite3


class DetailInterfaceController: WKInterfaceController {
    
    var db: OpaquePointer?
    var itemList = [List]()
    
    var listId: Int!
    
    
    var mode: Int?
            
    
    @IBOutlet weak var itemTable: WKInterfaceTable!
    
    @IBOutlet weak var Add: WKInterfaceButton!
    
    
    
    @IBAction func AddItem() {
        print("add function")
        
        self.presentTextInputController(withSuggestions: [""], allowedInputMode: WKTextInputMode.plain,
                                        completion:{(results) -> Void in
                                            let aResult = results?[0] as? String
                                            print(aResult)
                                            
                                            if aResult != nil {
                                                
                                                if aResult?.contains(",") ?? false {
                                                
                                                    let stringArr = aResult?.split{$0 == "," || $0 == "."}.map(String.init)
                                                    
                                                    if stringArr?.count ?? -1 > 0{
                                                    
                                                    for i in 0...stringArr!.count-1{
                                                        self.insertItem(itemInput: stringArr?[i] ?? "" )

                                                    }
                                                    }
                                                }else if aResult?.contains("，") ?? false {
                                                    
                                                    let stringArr = aResult?.split{$0 == "，" || $0 == "。"}.map(String.init)
                                                    if stringArr?.count ?? -1 > 0{

                                                    for i in 0...stringArr!.count-1{
                                                        self.insertItem(itemInput: stringArr?[i] ?? "" )
                                                        
                                                    }
                                                    }
                                                }else{
                                                    self.insertItem(itemInput: aResult ?? "" )
                                                }
                                            
                                            
                                                self.readItem(id: self.listId)
                                            }
        })
        //self.readItem(id: self.listId)
    }
    
    @IBAction func longPress(_ sender: Any) {
        print("long press ")
        for i in 0...itemList.count  {
            let row = itemTable.rowController(at:i) as? ListRowType
            
            row?.deleteButton.setHidden(false)
            
            let currentDevice = WKInterfaceDevice.current()
            
            let bounds = currentDevice.screenBounds
            print(bounds.width)
            if bounds.width == 136 {
                row?.itemName.setWidth(60)
                
            }else if bounds.width == 156{
                row?.itemName.setWidth(71)
                
                
            }else if bounds.width == 162{
                
                row?.itemName.setWidth(77)
                
                
                
            }else if bounds.width == 184{
                row?.itemName.setWidth(99)
                
                
            }
            
            
            
        }
        mode = 1
    }
    
  
    
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
         self.listId = context as! Int
        print ("list id"+String(listId))
        
        itemList = [List]()
        
        
        mode = 0
        initDataBase()
       // itemTable.setNumberOfRows(4, withRowType: "ListRowType")
        //insertTitle(titleInput: "list1-sqlite")
        readItem(id:self.listId)
        
        
        
        
        
        
        
        
        
        
        
        // Configure interface objects here.
    }
    
    
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        print("selected" + String( rowIndex))
        
        if mode == 0 {
            print("check")
            
            let row = itemTable.rowController(at:rowIndex) as? ListRowType
            
            if itemList[rowIndex].check == 0 {
                row?.checkImage.setImageNamed("check")
                itemList[rowIndex].check =  itemList[rowIndex].current
                update(row:rowIndex)

                return
                
                
            }else{
                row?.checkImage.setImageNamed("checked")
                
                
                
                itemList[rowIndex].check = 0
                update(row:rowIndex)

                return
            }
            
        }
        
        
        if mode == 1 {
            
            for i in 0...itemList.count  {
                let row = itemTable.rowController(at:i) as? ListRowType
                row?.deleteButton.setHidden(true)
                let currentDevice = WKInterfaceDevice.current()
                let bounds = currentDevice.screenBounds
                
                if bounds.width == 136 {
                    row?.itemName.setWidth(90)
                    
                }else if bounds.width == 156{
                    row?.itemName.setWidth(114)

                    
                    
                }else if bounds.width == 162{
                    row?.itemName.setWidth(110)

                }else if bounds.width == 184{
                    row?.itemName.setWidth(136)

                }
                
                }
            mode = 0
            
        }
        
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func initDataBase(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("HeroesDatabase.sqlite")
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        
        //creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, itemName TEXT, current INTEGER DEFAULT 1,checked INTEGER DEFAULT 1,list_id INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    func insertItem(itemInput: String){
        
        
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "INSERT INTO items (itemName,list_id) VALUES (?,?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        if sqlite3_bind_text(stmt, 1, itemInput, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
//        if sqlite3_bind_text(stmt, 2, 0, -1, nil) != SQLITE_OK{
//            let errmsg = String(cString: sqlite3_errmsg(db)!)
//            print("failure binding name: \(errmsg)")
//            return
//        }
//        if sqlite3_bind_text(stmt, 3, 0, -1, nil) != SQLITE_OK{
//            let errmsg = String(cString: sqlite3_errmsg(db)!)
//            print("failure binding name: \(errmsg)")
//            return
//        }
        
        if sqlite3_bind_int(stmt, 2, Int32(self.listId) ) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding current: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        
    }
    
    func deleteItem(itemId: Int){
        
        let deleteStatementStirng = "DELETE FROM items WHERE id = ?;"
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(deleteStatement, 1, Int32(itemId))
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        
        
        
        
        sqlite3_finalize(deleteStatement)
        
        
        print("delete")
        
        
    }
    
    func readItem(id : Int){
        
        itemList.removeAll()
        let queryString = "SELECT * FROM items"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let itemName = String(cString: sqlite3_column_text(stmt, 1))
            let current = sqlite3_column_int(stmt, 2)
            let check =  sqlite3_column_int(stmt,3)
            let listId = sqlite3_column_int(stmt,4)
            
            if listId == self.listId{
            
            itemList.append(List(id:Int(id),itemName: String(describing: itemName), current: Int(current), check: Int(check), listId: Int(self.listId)))
                
            }
            //adding values to list
            
            
        }
        
        print("count:"+String(itemList.count))
        itemTable.setNumberOfRows(itemList.count, withRowType: "listRowType")
        
        var end =  0
        
        if (itemList.count>0){
             end =  itemList.count - 1
            
            for i in 0...end  {
                
                print("read loop")
                
                //print("item name:"+itemList[i].itemName! ?? "nil")
                let row = itemTable.rowController(at:i) as? ListRowType
                row?.itemName.setText(itemList[i].itemName)
                row?.id = itemList[i].id
                row?.itemTable = itemTable
                row?.row = i
                row?.itemList = itemList
                row?.db = db
                
                row?.listId = self.listId
                row?.controller = self
                
                
                
                
                
                if itemList[i].check == 0 {
                    row?.checkImage.setImageNamed("checked")
                }else{
                    row?.checkImage.setImageNamed("check")
                }
                
                
            }
        }
        
        
        

    }
    
    func update (row: Int){
        print("update")
        var stmt: OpaquePointer?
        //the insert query
        let queryString = "UPDATE items SET checked = (?) WHERE id = (?)"
        
        
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        let id = itemList[row].id
        
        
            
        let check =  itemList[row].check
        
        if sqlite3_bind_int(stmt, 1, Int32(check)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
        }
       
        
            
        
        
        if sqlite3_bind_int(stmt, 2, Int32(id)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
    }
}
