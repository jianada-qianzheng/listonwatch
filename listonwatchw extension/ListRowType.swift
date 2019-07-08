//
//  ListRowType.swift
//  ListOnWatchW Extension
//
//  Created by Yali Xiao on 2019-06-21.
//  Copyright © 2019 weizhi.ca. All rights reserved.
//

import WatchKit
import SQLite3

class ListRowType: NSObject {
    
    var db: OpaquePointer?
    
    var mode : Int = 0
    
    var id : Int?
    
    var itemTable: WKInterfaceTable?
    
    var row: Int?
    
    var itemList = [List]()
    
    var listId : Int!
    
    var controller: DetailInterfaceController?
    
    @IBOutlet weak var editeButton: WKInterfaceButton!
    @IBOutlet weak var deleteButton: WKInterfaceButton!
    
    @IBOutlet weak var checkImage: WKInterfaceImage!
    
    @IBAction func delete() {
        
        controller?.mode = 0
        deleteItem(itemId: id ?? -1)
        readItem()
    }
    
    @IBAction func eidtItemName() {
        controller?.presentTextInputController(withSuggestions: [], allowedInputMode: WKTextInputMode.plain,
                                              completion:{(results) -> Void in
                                                let aResult = results?[0] as? String
                                                print(aResult)
                                                
                                                if aResult != nil{
                                                    
                                                    self.editItem(itemInput: aResult ?? "" )
                                                    
                                                    self.readItem()
                                                }
        })
        
    }
    
    
    @IBOutlet weak var itemName: WKInterfaceLabel!
    
    
    
   
    
    func initDataBase(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("HeroesDatabase.sqlite")
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        
        //creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, itemName TEXT, current INTEGER,check INTEGER,list_id INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    func insertItem(itemInput: String){
        
        
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "INSERT INTO items (itemName,list_id) VALUES (?,0,0,?)"
        
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
        
        if sqlite3_bind_int(stmt, 2, Int32(listId)) != SQLITE_OK{
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
    
    func readItem(){
        
        print("read"+String(listId))
        
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
            
            if listId == self.listId {
            
            itemList.append(List(id:Int(id),itemName: String(describing: itemName), current: Int(current), check: Int(check), listId: Int(listId)))
            //adding values to list
            
            }
        }
        itemTable?.setNumberOfRows(itemList.count, withRowType: "listRowType")
        
        if(itemList.count > 0){
        
        for i in 0...(itemList.count-1)  {
            let row = itemTable?.rowController(at:i) as? ListRowType
            row?.itemName.setText(itemList[i].itemName)
            row?.id = itemList[i].id
            row?.itemTable = itemTable
            row?.row = i
            row?.itemList = itemList
            row?.db = db
            row?.listId = self.listId
            row?.controller = self.controller
            
            if itemList[i].check == 0 {
                row?.checkImage.setImageNamed("checked")
            }else{
                row?.checkImage.setImageNamed("check")
            }
            
            
        }
        }
        
    }
    
    
    
    func editItem (itemInput: String){
        print("update")
        var stmt: OpaquePointer?
        //the insert query
        let queryString = "UPDATE item SET itemName = (?) WHERE id = (?)"
        
        
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        let id = itemList[row ?? 0].id
        
        
        
        
        if sqlite3_bind_text(stmt, 1, itemInput, -1,nil) != SQLITE_OK{
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
