enum NewsfeedType {
    case create
    case changeStatus
    
    static var allCasses: [NewsfeedType] {
        return [.create, .changeStatus]
    }
    
    var title: String {
        switch self {
        case .create:
            return "New Task"
        case .changeStatus:
            return "Status Change"
        }
    }
    
    var order: Int {
        switch self {
        case .create:
            return 0
        case .changeStatus:
            return 1
        }
    }
}
