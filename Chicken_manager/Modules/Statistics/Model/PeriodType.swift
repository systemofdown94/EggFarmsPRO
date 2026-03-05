enum PeriodType: Identifiable, CaseIterable {
    case week
    case month
    case allTime

    var id: Self {
        self
    }
    
    var title: String {
        switch self {
            case .week:
                "Week"
            case .month:
                "Month"
            case .allTime:
                "All time"
        }
    }
}
