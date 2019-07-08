//
//  TitleRowType.swift
//  ListOnWatchW Extension
//
//  Created by Yali Xiao on 2019-06-18.
//  Copyright © 2019 weizhi.ca. All rights reserved.
//

import WatchKit
import UIKit
import SQLite3


class TitleRowType: NSObject {
    
    var controler : InterfaceController?
    
    var db: OpaquePointer?
    
    var mode : Int = 0
    
    var id : Int?
    
    var titleTable: WKInterfaceTable?
    
    var row: Int?
    
    var titleList = [Title]()

    @IBOutlet weak var editImage: WKInterfaceImage!
    @IBOutlet weak var editButtonGroup: WKInterfaceGroup!
    @IBOutlet weak var editeButton: WKInterfaceButton!
    
    @IBAction func edit() {
        controler?.presentTextInputController(withSuggestions: [], allowedInputMode: WKTextInputMode.plain,
                                        completion:{(results) -> Void in
                                            let aResult = results?[0] as? String
                                            print(aResult)
                                       
                                            if aResult != nil{
                                           
                                                self.editTitle(titleInput:aResult ?? "" )
                                            
                                            self.readTitle()
                                            }
        })
        
        
    }
    
    
    @IBOutlet weak var buttonDele: WKInterfaceButton!
    @IBOutlet weak var rowDescription: WKInterfaceLabel!
    
    
    
    @IBAction func delete() {
        
        controler?.mode = 0;
        //initDataBase()
        deleteTitle(titleId: id ?? -1)
        //titleList.remove(at: row ?? -1)
    
        readTitle()
        for i in 0...titleList.count  {
            let row = titleTable?.rowController(at:i) as? TitleRowType
            row?.buttonDele.setHidden(true)


        }
        
        print(id)
        
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
            print("list id ")
            
            print(id)
            
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let current = sqlite3_column_int(stmt, 2)
            
            titleList.insert(Title(id:Int(id),title: String(describing: title),current: Int(current)), at: 0)
            
            //titleList.append()
            //adding values to list
            
            
            
            
        }
        print("title list count")
        
        print(titleList.count)
        
        
        
        
        
        titleTable?.setNumberOfRows(titleList.count, withRowType: "titleRowType")
        
        if titleList.count > 0{

            for i in 0...(titleList.count-1)  {
                
                print("for loop ")
                
                print(i)
                
                print(titleList[i].id)
                
                let row = titleTable?.rowController(at:i) as? TitleRowType
                row?.rowDescription.setText(titleList[i].title)
                row!.id = titleList[i].id
                row?.titleTable = self.titleTable
                row?.row = i
                row?.titleList = self.titleList
                row?.db = db
                row?.controler = self.controler
            
            
            }
        }
        
        
        
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
    }
    
    func deleteTitle(titleId: Int){
        
        print("delete list id")
        
        print(Int32(titleId))
        
        deleteList(listId: titleId  )
        
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
    
    func deleteList(listId: Int){
        
//        let queryString = "SELECT * FROM items"
//
//        //statement pointer
//        var stmt:OpaquePointer?
//
//        //preparing the query
//        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
//            let errmsg = String(cString: sqlite3_errmsg(db)!)
//            print("error preparing insert: \(errmsg)")
//            return
//        }
//
//        //traversing through all the records
//
//        while(sqlite3_step(stmt) == SQLITE_ROW){
//            let itemId = sqlite3_column_int(stmt, 0)
//            let itemName = String(cString: sqlite3_column_text(stmt, 1))
//            let current = sqlite3_column_int(stmt, 2)
//            let check =  sqlite3_column_int(stmt,3)
//            let listI = sqlite3_column_int(stmt,4)
//
//            print("All list id")
//
//            print (Int(listI))
//
//            print (self.id!)
//
//            if Int(listI) == self.id! {
//
//                deleteItem(itemId: Int(itemId))
//
//            }
//            //adding values to list
//
//
//        }
//
        
        
        let deleteStatementStirng = "DELETE FROM items WHERE list_id = ?"
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(deleteStatement, 1, Int32(self.id!))
            
            print("delte listid")
            
            print(listId)
            
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
        
        
        print("delete item")
        
        print (itemId)
        
        
    }
    
    func editTitle (titleInput: String){
        print("update")
        var stmt: OpaquePointer?
        //the insert query
        let queryString = "UPDATE titles SET title = (?) WHERE id = (?)"
        
        
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        let id = titleList[row ?? -1].id
        
        
        
        
        if sqlite3_bind_text(stmt, 1, titleInput, -1,nil) != SQLITE_OK{
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
