enum NewsfeedFiltersType {
    case type
    case author
    case tag
    
    var title: String {
        switch self {
        case .type:
            "All"
        case .author:
            "Author"
        case .tag:
            "Tag"
        }
    }
}
