//
//  File.swift
//  Universal
//
//  Created by Ahmed Sultan on 7/28/19.
//  Copyright © 2019 Ahmed Sultan. All rights reserved.
//

import Foundation
import SQLite
class SQLiteManager {
    //MARK: - Properties
   private var database:Connection!
   private var itemTable = Table("itemTable")
   private var id = Expression<Int64>("id")
   private var name = Expression<String>("name")
   private var imageName = Expression<String>("imageName")
    //MARK: - Singleton instance
    static func shared() -> SQLiteManager {
        return SQLiteManager()
    }
    private init() {
        prepareDatabase()
    }
    //MARK: - SQLite Database Configuration 
    private func prepareDatabase() {
        let documentDirectoery = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
     //  let databaseDirectoryUrl = documentDirectoery.appendingPathComponent("database")
            do {
              // try FileManager.default.createDirectory(at: databaseDirectoryUrl, withIntermediateDirectories: true, attributes: nil)
                let databaseUrl = documentDirectoery.appendingPathComponent("items/").appendingPathExtension(".sqlie3")
                let database = try Connection(databaseUrl.path)
                self.database = database
                createTable()
                
            }
            catch {
                print("error creating database directory url \(error)")
            }
    }
    private func createTable() {
        let createTable = self.itemTable.create(block: { (table) in
            table.column(id, primaryKey: true)
            table.column(self.name)
            table.column(self.imageName, unique: true)
        })
        do {
            try self.database.run(createTable)
        }
        catch {
            print("error creating table is \(error)")
        }
    }
    func insert(newItem:Item) {
        let insert = self.itemTable.insert(self.name <- newItem.name, self.imageName <- newItem.imageName)
        do {
            try self.database.run(insert)
        } catch {
            print("error inserting new item \(error)")
        }
    }
    func delete(item:Item, completion: @escaping (Bool) ->Void){
        let deletedItem = self.itemTable.filter(name == item.name)
        do {
            try self.database.run(deletedItem.delete())
            completion(true)
        } catch {
            print("error deleting item is \(error)")
            completion(false)
        }
    }
    func update(item:Item, with name:String){
        let updatedItem = self.itemTable.filter(self.name == item.name)
        do {
            try self.database.run(updatedItem.update(self.name <- self.name.replace(item.name, with: name)))
        } catch {
            print("error deleting item is \(error)")
        }
    }
    func listOfItems() -> [Item] {
        var items = [Item]()
        do {
            let fetchedItemRows = try self.database.prepare(self.itemTable)
            for itemRow in fetchedItemRows {
                let itemName = itemRow[self.name]
                let imageName = itemRow[self.imageName]
               
                let item = Item(name: itemName, imageName: imageName)
                items.append(item)
            }
        } catch {
            print("error listed items is \(error)")
        }
        return items
    }
}
