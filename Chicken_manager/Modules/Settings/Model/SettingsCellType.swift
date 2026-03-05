enum SettingsCellType: Identifiable, CaseIterable {
    case push
    case privacy
    case version
    case deleteData
    
    var id: Self {
        self
    }
}

