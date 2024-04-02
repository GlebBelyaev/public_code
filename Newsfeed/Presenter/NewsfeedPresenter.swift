//
//  NewsfeedPresenter.swift
//  Calendar
//
//  Created by User on 06.12.2023.
//  Copyright © 2023 Николай Борисов. All rights reserved.
//

import Foundation

protocol NewsfeedPresenter: AnyObject {
    func attachView(_ view: NewsfeedViewControllerProtocol)
    func getItemCount() -> Int
    
    func getItem(at: Int) -> NewsfeedModel?
    func getSelectedManager() -> Person?
    
    func getFilters() -> [NewsfeedFiltersType]
    func getAuthorFilter() -> Person?
    func getTagsFilter() -> APITag?
    
    func tagDidTapped(tag: APITag?)
    func getTags() -> [APITag]
    
    func authorDidTapped(person: Person?)
    func getAuthors() -> [Person]
    
    func setFilterType(_ type: NewsfeedType?)
    func getFilterType() -> NewsfeedType?
    
    func setSearchText(_ text: String?)
}

class NewsfeedPresenterImpl: NewsfeedPresenter {
    weak var view: NewsfeedViewControllerProtocol?
    
    var authorFilter: Person?
    var tagFilter: APITag?
    var typeFilter: NewsfeedType?
    var searchText: String?
    
    var cachedData: [NewsfeedModel] = []
    
    func attachView(_ view: NewsfeedViewControllerProtocol) {
        self.view = view
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateAfterSync),
                                               name: NSNotification.Name("globalDatasourceDidChange"),
                                               object: nil)
        
    }
    
    @objc
    func updateAfterSync() {
        cachedData.removeAll()
        self.view?.reloadData()
    }
    
    func getSelectedManager() -> Person? {
        var selectedManagers: [Person] = []
        
        if let filter = Filter.allObjects().firstObject() as? Filter {
            for person in filter.managers.nsArray() as! [Person] {
                if person.isSelectedAsManager {
                    selectedManagers.append(person)
                }
            }
        }
    
        if selectedManagers.isEmpty {
            return nil
        } else {
            return selectedManagers[0]
        }
    }
    
    
    func getData() -> [NewsfeedModel] {
        var result: [NewsfeedModel] = []
        
        if cachedData.isEmpty {
            if self.typeFilter == nil || self.typeFilter == .create {
                var addedTaskID: Set<Int> = []
                let tasks = self.getTasks()
                tasks.forEach { item in
                    if !addedTaskID.contains(item.id) {
                        addedTaskID.insert(item.id)
                        
                        let formatter = DateFormatter()
                        formatter.timeZone = TimeZone(abbreviation: "UTC")
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                        if let dateStr = item.date, let date = formatter.date(from: dateStr), let authorPerson = item.authorPerson {
                            let model: NewsfeedModel = NewsfeedModel(type: .create, task: item.freeze(), updateAt: date, author: authorPerson)
                            result.append(model)
                        }
                    }
                }
            }
            
            if self.typeFilter == nil || self.typeFilter == .changeStatus {
                let changeStatuses = self.getNewsfeedChangedStatuses()
                changeStatuses.forEach { item in
                    let authorId = item.authorId
                    
                    var oldStatusId = 0
                    let filteredItems = changeStatuses.filter({$0.taskId == item.taskId}).sorted(by: {$0.id < $1.id})
                    
                    if let index = filteredItems.firstIndex(of: item), index != 0 {
                        oldStatusId = filteredItems[index - 1].statusId
                    }
                    
                    if let task = Task.allObjects().objectsWhere("ID == \(item.taskId)", args: getVaList([])).firstObject() as? Task,
                       let author = Person.allObjects().objects(with: NSPredicate(format: "ID == \(authorId)")).firstObject() as? Person {
                        if task.task == "No title", task.tags.nsArray().isEmpty, task.start_date == nil {

                        } else {
                            //Проверим фильтр на tag
                            if let tagFilter = tagFilter {
                                if let tags = task.tags.nsArray() as? [APITag], !tags.isEmpty {
                                    if tags.contains(where: {$0.tag_id == tagFilter.tag_id}) {
                                        let model: NewsfeedModel = NewsfeedModel(type: .changeStatus, task: task.freeze(), updateAt: item.updatedAt, author: author, newStatusID: item.statusId, oldStatusID: oldStatusId)
                                        result.append(model)
                                    }
                                }
                            } else {
                                let model: NewsfeedModel = NewsfeedModel(type: .changeStatus, task: task.freeze(), updateAt: item.updatedAt, author: author, newStatusID: item.statusId, oldStatusID: oldStatusId)
                                result.append(model)
                            }
                        }
                    }
                }
            }
            
            cachedData = result
        } else {
            result = cachedData
        }
        
        if let text = self.searchText {
            result = result.filter({$0.task.eventTitle.lowercased().contains(text.lowercased())})
        }
        
        result = result.sorted { item1, item2 in
            if (item1.updateAt > item2.updateAt) {
                return true
            } else if (item1.updateAt < item2.updateAt) {
                return false
            } else if (item1.updateAt == item2.updateAt) {
                if item1.task.id == item2.task.id {
                    return item1.type.order >= item2.type.order
                }
            }
            
            return true
        }

        return result
    }
    
    func getFilters() -> [NewsfeedFiltersType] {
        return [.type, .author, .tag]
    }
    
    func setSearchText(_ text: String?) {
        var inputText = text
        
        if let text = text {
            if text.isEmpty {
                inputText = nil
            }
        }
            
        self.searchText = inputText
    }
    
    func authorDidTapped(person: Person?) {
        if self.authorFilter != nil {
            self.authorFilter = nil
        } else {
            if let person = person {
                self.authorFilter = person
            }
        }
        
        cachedData.removeAll()
        
        view?.reloadFilterData()
        self.view?.reloadData()
    }
    
    func tagDidTapped(tag: APITag?) {
        if self.tagFilter != nil {
            self.tagFilter = nil
        } else {
            if let tag = tag {
                self.tagFilter = tag
            }
        }
        
        cachedData.removeAll()
        
        view?.reloadFilterData()
        self.view?.reloadData()
    }
    
    func setFilterType(_ type: NewsfeedType?) {
        if self.typeFilter != nil {
            typeFilter = nil
        } else {
            typeFilter = type
        }
        
        cachedData.removeAll()
        
        view?.reloadFilterData()
        self.view?.reloadData()
    }
    
    func getFilterType() -> NewsfeedType? {
        return self.typeFilter
    }
    
    func getAuthorFilter() -> Person? {
        return self.authorFilter
    }
    
    func getTagsFilter() -> APITag? {
        return self.tagFilter
    }
    
    func getItemCount() -> Int {
        return getData().count
    }
    
    func getItem(at index: Int) -> NewsfeedModel? {
        let items = getData()
        
        guard index < items.count else { return nil }
        let result = items[index]
        
        return result
    }
    
    private func getTaskFrom(index: Int) -> Task? {
        let tasks = getTasks()
        
        guard index < tasks.count else { return nil }
        let result = tasks[index]
        
        return result
    }
    
    func getTasks() -> [Task] {
        var result: [Task] = []

        guard let manager = getSelectedManager() else { return result }
        let managerID = manager.id
        
        var predicate = "(task_type != 2 AND (ANY managers.ID = \(managerID)))"
        
        if let author = authorFilter {
            predicate = "\(predicate) AND authorPerson.ID = \(author.id)"
        }
        
        if let tagFilter = tagFilter {
            predicate = "\(predicate) AND (ANY tags.tag_id = \(tagFilter.tag_id))"
        }
        
        let taskFromBD = Task.allObjects().objectsWhere(predicate, args: getVaList([]))
        
        for i in 0..<taskFromBD.count {
            let item = taskFromBD[i] as! Task
            result.append(item)
        }
        
        return result
    }
    
    func getNewsfeedChangedStatuses() -> [NewsfeedChangeStatusModel] {
        var result: [NewsfeedChangeStatusModel] = []
        
        guard let manager = getSelectedManager() else { return result }
        let managerID = manager.id
        
        var predicate = "(ANY managers.ID = \(managerID))"
        if let author = authorFilter {
            predicate += " AND (authorId = \(author.id))"
        }
        
        var items = NewsfeedChangeStatusModel.allObjects()
        if !predicate.isEmpty {
            items = NewsfeedChangeStatusModel.allObjects().objectsWhere(predicate, args: getVaList([]))
        }
        
        for i in 0..<items.count {
            let item = items[i] as! NewsfeedChangeStatusModel
            result.append(item)
        }
        
        return result
    }
    
    func getAuthors() -> [Person] {
        var result: Set<Person> = []
        let data = getData()
        
        data.forEach { model in
            result.insert(model.author)
        }
        
        return Array(result)
    }
    
    func getTags() -> [APITag] {
        var result: Set<APITag> = []
        let data = getData()
        
        data.forEach { model in
            model.task.tags.nsArray().forEach { tag in
                if let tag = tag as? APITag {
                    result.insert(tag)
                }
            }
        }
        
        let new = result.sorted { tag1, tag2 in
            return tag1.tag_title < tag2.tag_title
        }
        
        return Array(new)
    }
    
}
