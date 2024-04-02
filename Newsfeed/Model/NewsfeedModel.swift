struct NewsfeedModel {
    let type: NewsfeedType
    let task: Task
    let updateAt: Date
    let author: Person
    
    //Нужен только для type == .changeStatus
    let newStatusID: Int
    let oldStatusID: Int
    
    init(type: NewsfeedType, task: Task, updateAt: Date, author: Person, newStatusID: Int = 0, oldStatusID: Int = 0) {
        self.type = type
        self.task = task
        self.updateAt = updateAt
        self.author = author
        self.newStatusID = newStatusID
        self.oldStatusID = oldStatusID
    }
}
