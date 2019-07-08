//
//  InterfaceController.swift
//  ListOnWatchW Extension
//
//  Created by Yali Xiao on 2019-06-13.
//  Copyright © 2019 weizhi.ca. All rights reserved.
//

import WatchKit
import Foundation
import SQLite3


class InterfaceController: WKInterfaceController {
    var db: OpaquePointer?
    var titleList = [Title]()
    
    
    var mode: Int?
    
    
    
    
        
    
    
    @IBAction func longpress(_ sender: Any) {
        print("long press ")
        
        for i in 0...titleList.count  {
            let row = titleTable.rowController(at:i) as? TitleRowType
            
            row?.buttonDele.setHidden(false)
            
            let currentDevice = WKInterfaceDevice.current()
            
            let bounds = currentDevice.screenBounds
            print(bounds.width)
            if bounds.width == 136 {
                row?.rowDescription.setWidth(86)
                
            }else if bounds.width == 156{
                row?.rowDescription.setWidth(111)
                
                
            }else if bounds.width == 162{
                
                row?.rowDescription.setWidth(104)
                
                
                
            }else if bounds.width == 184{
                row?.rowDescription.setWidth(132)
                
                
            }
            
            
            
        }
        mode = 1
        
        

        
    }
    
    
   
    
    
    
    
    
    
    
    
    @IBOutlet weak var titleTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        mode = 0
        
        initDataBase()
        //insertTitle(titleInput: "list1-sqlite")
        
        readTitle()
        
        
        
        
        
        
        



        
        
        
        
        
        // Configure interface objects here.
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        print("selected" + String( rowIndex))
        
        if mode == 0  {
            print("go to")
            
            let row = titleTable?.rowController(at:rowIndex) as? TitleRowType

            self.pushController(withName: "showDetails", context: row?.id)

        }
        

        if mode == 1 {
            
            for i in 0...titleList.count  {
                let row = titleTable.rowController(at:i) as? TitleRowType
                row?.buttonDele.setHidden(true)
                row?.editeButton.setHidden(true)
                let currentDevice = WKInterfaceDevice.current()
                
                let bounds = currentDevice.screenBounds
                print(bounds.width)
                if bounds.width == 136 {
                    row?.rowDescription.setWidth(120)
                    
                }else if bounds.width == 156{
                    row?.rowDescription.setWidth(145)
                    
                    
                }else if bounds.width == 162{
                    
                    row?.rowDescription.setWidth(138)
                    
                    
                    
                }else if bounds.width == 184{
                    row?.rowDescription.setWidth(168)
                    
                    
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
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS titles (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, current INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        //creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, itemName TEXT, current INTEGER DEFAULT 1,checked INTEGER DEFAULT 1,list_id INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    func insertTitle(titleInput: String){
        
        
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "INSERT INTO titles (title, current) VALUES (?,?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        if sqlite3_bind_text(stmt, 1, titleInput, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 2, 1) != SQLITE_OK{
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
    
    func deleteTitle(titleId: Int){
        
        let deleteStatementStirng = "DELETE FROM titles WHERE id = ?;"
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(deleteStatement, 1, Int32(titleId))
            
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
    
    func readTitle(){
        
        titleList.removeAll()
        let queryString = "SELECT * FROM titles"
        
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
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let current = sqlite3_column_int(stmt, 2)
            
            titleList.insert(Title(id:Int(id),title: String(describing: title),current: Int(current)), at: 0)
            //adding values to list
            
            
        }
        titleTable.setNumberOfRows(titleList.count, withRowType: "titleRowType")

        if titleList.count > 0{
        for i in 0...titleList.count  {
            let row = titleTable.rowController(at:i) as? TitleRowType
            row?.rowDescription.setText(titleList[i].title)
            row?.id = titleList[i].id
            row?.titleTable = self.titleTable
            row?.row = i
            row?.titleList = self.titleList
            row?.db = db
            row?.controler = self
            

        }
        }
        
    }
    
    

    
    
    
    
    
    @IBAction func Add() {
        print("add function")

        self.presentTextInputController(withSuggestions: ["To do list","Grocery list"], allowedInputMode: WKTextInputMode.plain,
                                                       completion:{(results) -> Void in
                                                        let aResult = results?[0] as? String
                                                        print(aResult)
                                                        if aResult != nil {
                                                            self.insertTitle(titleInput: aResult ?? "" )
                                                        
                                                            self.readTitle()
                                                        }
        })
        
       
    }
    
    
    
    
    
}
