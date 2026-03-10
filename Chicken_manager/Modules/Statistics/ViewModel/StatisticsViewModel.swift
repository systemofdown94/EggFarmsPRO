import Foundation
import Combine

final class StatisticsViewModel: ObservableObject {
    
    private let storage = UserDefaultsService.shared
    private let fileManager = ImageFileStorageService.shared
    
    @Published var selectedPeriodType: PeriodType = .week
    
    @Published private(set) var chickens: [Chicken] = []
    
    var totalEggsForSelectedPeriod: Int {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriodType {
            
        case .week:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: now) else {
                return 0
            }
            
            return chickens.reduce(0) { result, chicken in
                
                let base = chicken.eggsPerWeek
                
                let notes = chicken.eggNotes
                    .filter { interval.contains($0.date) }
                    .reduce(0) { $0 + $1.count }
                
                return result + base + notes
            }
            
        case .month:
            guard let interval = calendar.dateInterval(of: .month, for: now) else {
                return 0
            }
            
            let weeksInMonth = calendar.range(of: .weekOfMonth, in: .month, for: now)?.count ?? 0
            
            return chickens.reduce(0) { result, chicken in
                
                let base = chicken.eggsPerWeek * weeksInMonth
                
                let notes = chicken.eggNotes
                    .filter { interval.contains($0.date) }
                    .reduce(0) { $0 + $1.count }
                
                return result + base + notes
            }
            
        case .allTime:
            return chickens.reduce(0) { result, chicken in
                
                let base = Date.multiplyByWeeksSince(
                    chicken.eggsPerWeek,
                    from: chicken.birthDate
                )
                
                let notes = chicken.eggNotes
                    .reduce(0) { $0 + $1.count }
                
                return result + base + notes
            }
        }
    }
    
    private func weekEntries() -> [EggChartEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else {
            return []
        }
        
        let todayWeekday = calendar.component(.weekday, from: now)
        let firstWeekday = calendar.firstWeekday
        
        let days = (firstWeekday...todayWeekday)
        
        var grouped: [Int: Int] = [:]
        
        for chicken in chickens {
            
            for weekday in days {
                
                guard let date = calendar.date(
                    bySetting: .weekday,
                    value: weekday,
                    of: weekInterval.start
                ) else { continue }
                
                if date >= chicken.birthDate {
                    grouped[weekday, default: 0] += chicken.eggsPerWeek / 7
                }
            }
            
            for note in chicken.eggNotes where weekInterval.contains(note.date) {
                let weekday = calendar.component(.weekday, from: note.date)
                
                if weekday <= todayWeekday {
                    grouped[weekday, default: 0] += note.count
                }
            }
        }
        
        let symbols = calendar.shortWeekdaySymbols
        
        return days.map { weekday in
            EggChartEntry(
                label: symbols[weekday - 1].lowercased(),
                value: grouped[weekday] ?? 0
            )
        }
    }
    
    private func monthEntries() -> [EggChartEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: now) else {
            return []
        }
        
        let currentWeek = calendar.component(.weekOfMonth, from: now)
        let weeks = 1...currentWeek
        
        var grouped: [Int: Int] = [:]
        
        for chicken in chickens {
            
            let birthWeek = calendar.component(.weekOfMonth, from: chicken.birthDate)
            let birthMonth = calendar.component(.month, from: chicken.birthDate)
            let currentMonth = calendar.component(.month, from: now)
            
            for week in weeks {
                
                if birthMonth == currentMonth && week < birthWeek {
                    continue
                }
                
                grouped[week, default: 0] += chicken.eggsPerWeek
            }
            
            for note in chicken.eggNotes where monthInterval.contains(note.date) {
                let week = calendar.component(.weekOfMonth, from: note.date)
                
                if week <= currentWeek {
                    grouped[week, default: 0] += note.count
                }
            }
        }
        
        return weeks.map {
            EggChartEntry(
                label: "\($0) week",
                value: grouped[$0] ?? 0
            )
        }
    }
    
    private func yearEntries() -> [EggChartEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        var months: [Date] = []
        
        for offset in stride(from: 11, through: 0, by: -1) {
            if let date = calendar.date(byAdding: .month, value: -offset, to: now) {
                months.append(date)
            }
        }
        
        var grouped: [Int: Int] = [:]
        
        for chicken in chickens {
            
            for (index, monthDate) in months.enumerated() {
                
                guard let interval = calendar.dateInterval(of: .month, for: monthDate) else {
                    continue
                }
                
                if chicken.birthDate <= interval.end {
                    grouped[index, default: 0] += chicken.eggsPerWeek * 4
                }
            }
            
            for note in chicken.eggNotes {
                
                for (index, monthDate) in months.enumerated() {
                    
                    guard let interval = calendar.dateInterval(of: .month, for: monthDate) else {
                        continue
                    }
                    
                    if interval.contains(note.date) {
                        grouped[index, default: 0] += note.count
                    }
                }
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        return months.enumerated().map { index, date in
            EggChartEntry(
                label: formatter.string(from: date),
                value: grouped[index] ?? 0
            )
        }
    }
}

// MARK: - Public API:
extension StatisticsViewModel {
    var chickenWithHighestEggScore: Chicken? {
        chickens.max(by: { lhs, rhs in
            lhs.eggScore < rhs.eggScore
        })
    }
    
    var chartEntries: [EggChartEntry] {
        switch selectedPeriodType {
            case .week:
                return weekEntries()
            case .month:
                return monthEntries()
            case .allTime:
                return yearEntries()
        }
    }
    
    func loadChickens() {
        Task { [weak self] in
            guard let self else { return }
            
            let chickensDTO = await self.storage.get([ChickenDTO].self, forKey: .chickens) ?? []
            let chickens = chickensDTO.map { Chicken(from: $0) }
            
            let chickensWithImages: [Chicken] = await withTaskGroup(of: Chicken.self) { group in
                var newChickens: [Chicken] = []
                
                for chicken in chickens {
                    group.addTask {
                        let image = await self.fileManager.load(uuid: chicken.id)
                        var newChicken  = chicken
                        
                        newChicken.image = image
                        
                        return newChicken
                    }
                    
                    for await chicken in group {
                        newChickens.append(chicken)
                    }
                }
                
                return newChickens
            }
            
            await MainActor.run {
                self.chickens = chickensWithImages
            }
        }
    }
}
