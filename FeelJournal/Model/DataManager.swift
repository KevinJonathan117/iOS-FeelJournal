//
//  DataManager.swift
//  FeelJournal
//
//  Created by Kevin Jonathan on 12/03/22.
//

import Foundation
import UIKit

struct DataManager {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getAllItems() {
        do {
            journalData = try context.fetch(JournalEntryItem.fetchRequest()).reversed()
            getAnalytics()
        } catch {
            print("Cannot get all items")
        }
    }
    
    func getItemsBySearch(text: String) {
        do {
            journalData = try context.fetch(JournalEntryItem.fetchRequest()).reversed().filter { $0.title!.lowercased().contains(text.lowercased()) ||  $0.body!.lowercased().contains(text.lowercased())}
        } catch {
            print("Cannot get items by search")
        }
    }
    
    func getAnalytics() {
        let average: Double = journalData.map {$0.feelingIndex}.average
        let average7days: Double = journalData.filter { journal in
            (Date() - journal.createdAt!).day! <= 7
        }.map {$0.feelingIndex}.average
        
        feelAverage = journalData.count > 0 ? average == 0 ? "Neutral" : average < 0 ? "Sad" : "Happy" : "No Data"
        feelAverage7days = journalData.filter { journal in
            (Date() - journal.createdAt!).day! <= 7
        }.count > 0 ? average7days == 0 ? "Neutral" : average7days < 0 ? "Sad" : "Happy" : "No Data"
    }

    func createItem(title: String, body: String, feeling: String, feelingIndex: Double) {
        let newItem = JournalEntryItem(context: context)
        newItem.title = title
        newItem.createdAt = Date()
        newItem.body = body
        newItem.feeling = feeling
        newItem.feelingIndex = feelingIndex

        do {
            try context.save()
            getAllItems()
        } catch {
            print("Cannot create item")
        }
    }

    func deleteItem(item: JournalEntryItem) {
        context.delete(item)

        do {
            try context.save()
            getAllItems()
        } catch {
            print("Cannot delete item")
        }
    }

    func updateItem(item: JournalEntryItem, newTitle: String, newBody: String, newFeeling: String, newFeelingIndex: Double) {
        item.title = newTitle
        item.body = newBody
        item.feeling = newFeeling
        item.feelingIndex = newFeelingIndex
        do {
            try context.save()
            getAllItems()
        } catch {
            print("Cannot update item")
        }
    }
}

extension Date {
    static func -(recent: Date, previous: Date) -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second

        return (month: month, day: day, hour: hour, minute: minute, second: second)
    }
}

extension Array where Element: BinaryFloatingPoint {
    var average: Double {
        return self.isEmpty ? 0.0 : Double(self.reduce(0, +)) / Double(self.count)
    }
}

let dataManager: DataManager = DataManager()
