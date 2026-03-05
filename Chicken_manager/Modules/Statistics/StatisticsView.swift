import SwiftUI
import Charts

struct StatisticsView: View {
    
    @StateObject private var viewModel = StatisticsViewModel()
    
    private var yDomain: ClosedRange<Double> {
        let values = viewModel.chartEntries.map { Double($0.value) }
        
        guard let max = values.max() else {
            return 0...1
        }
        
        return 0...(max + 1)
    }
    
    private var yAxisValues: [Int] {
        let maxValue = viewModel.chartEntries.map { $0.value }.max() ?? 0
        
        let quarter = Int(Double(maxValue) * 0.25)
        let half = Int(Double(maxValue) * 0.5)
        let top = maxValue + 1
        
        return Array(Set([0, quarter, half, top])).sorted()
    }
    
    var body: some View {
        ZStack {
            background
            
            VStack(spacing: 16) {
                navigationBar
                
                if viewModel.chickens.isEmpty {
                    VStack {
                        Text("There is no statistics for this period yet")
                            .font(.inter(.bold, size: 24))
                            .foregroundStyle(.appBrown)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            dateRangeSelector
                            topChicken
                            topChickenEggStats
                            graph
                            totalEggs
                            
                            Color.clear
                                .frame(height: 100)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .animation(.default, value: viewModel.selectedPeriodType)
        .animation(.default, value: viewModel.chickens)
        .onAppear {
            viewModel.loadChickens()
        }
    }
    
    private var background: some View {
        Image(.Images.mainBG)
            .resizeCrop()
    }
    
    private var navigationBar: some View {
        HStack {
            Text("Statistics")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.inter(.bold, size: 38))
                .foregroundStyle(.appBrown)
        }
        .frame(height: 80)
        .padding(.horizontal, 16)
    }
    
    private var dateRangeSelector: some View {
        HStack(spacing: 4) {
            ForEach(PeriodType.allCases) { type in
                Button {
                    viewModel.selectedPeriodType = type
                } label: {
                    Text(type.title)
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .font(.inter(.semibold, size: 19))
                        .foregroundStyle(viewModel.selectedPeriodType == type ? .white : .appBrown)
                        .background(viewModel.selectedPeriodType == type ? .appOrange : .appBeige)
                }
            }
        }
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private var topChicken: some View {
        if let topChicken = viewModel.chickenWithHighestEggScore {
            HStack(spacing: 10) {
                if let image = topChicken.image {
                    Image(uiImage: image)
                        .resizeCrop()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .cornerRadius(16)
                }
                
                VStack(spacing: 4) {
                    Text(topChicken.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.inter(.semibold, size: 19))
                        .foregroundStyle(.appBrown)
                    
                    Text(topChicken.breed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.inter(.medium, size: 19))
                        .foregroundStyle(.appLightBrown)
                }
                
                Text("TOP")
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, 16)
                    .background(.appOrange)
                    .font(.inter(.semibold, size: 19))
                    .foregroundStyle(.appBrown)
            }
            .frame(height: 100)
            .padding(.leading, 12)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
        } else {
            EmptyView()
        }
    }
    
    private var topChickenEggStats: some View {
        HStack(spacing: 16) {
            VStack(spacing: 0) {
                Text("Total Eggs")
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
                    .font(.inter(.semibold, size: 19))
                    .foregroundStyle(.appBrown)
                    .background(.appOrange)
                
                if let topChicken = viewModel.chickenWithHighestEggScore {
                    Text("\(Int(topChicken.eggScore))")
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .font(.inter(.semibold, size: 58))
                        .foregroundStyle(.appBrown)
                        .background(.white)
                }
            }
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
            
            VStack(spacing: 0) {
                Text("Avg/Week")
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
                    .font(.inter(.semibold, size: 19))
                    .foregroundStyle(.appBrown)
                    .background(.appOrange)
                
                if let topChicken = viewModel.chickenWithHighestEggScore {
                    Text("\(Int(topChicken.averageEggsPerWeek))")
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .font(.inter(.semibold, size: 58))
                        .foregroundStyle(.appBrown)
                        .background(.white)
                }
            }
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
        }
    }
    
    private var graph: some View {
        VStack {
            Text("Egg Production")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.inter(.bold, size: 28))
                .foregroundStyle(.appBrown)
            
            Chart {
                ForEach(viewModel.chartEntries) { entry in
                    BarMark(
                        x: .value("Period", entry.label),
                        y: .value("Eggs", entry.value)
                    )
                    .foregroundStyle(.appOrange.opacity(0.7))
                    
                    LineMark(
                        x: .value("Period", entry.label),
                        y: .value("Eggs", entry.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.appOrange)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    PointMark(
                        x: .value("Period", entry.label),
                        y: .value("Eggs", entry.value)
                    )
                    .foregroundStyle(.appOrange)
                    .symbolSize(150)
                    
                    PointMark(
                        x: .value("Period", entry.label),
                        y: .value("Eggs", entry.value)
                    )
                    .foregroundStyle(.white)
                    .symbolSize(75)
                    
                    PointMark(
                        x: .value("Period", entry.label),
                        y: .value("Eggs", entry.value)
                    )
                    .opacity(0)
                    .annotation(position: .top) {
                        Text("\(entry.value)")
                            .frame(width: 24, height: 24)
                            .font(.inter(.medium, size: 14))
                            .foregroundStyle(.white)
                            .background(.appOrange)
                            .cornerRadius(4)
                            .offset(y: -4)
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: yAxisValues) { value in
                    
                    AxisGridLine()
                        .foregroundStyle(.appBrown.opacity(0.15))
                    
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                    AxisTick()
                }
            }
            .frame(height: 200)
            .padding(.top)
            .padding(10)
            .background(
                LinearGradient(
                    colors: [
                        .white,
                        .appLightBeige
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(16)
            .clipped()
            .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
        }
    }
    
    private var totalEggs: some View {
        HStack {
            let periodName = viewModel.selectedPeriodType.title.lowercased()

            Text("Total for \(viewModel.selectedPeriodType == .allTime ? "" : "this") \(periodName)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.inter(.medium, size: 19))
                .foregroundStyle(.appBrown)
            
            HStack(spacing: 4) {
                Image(.Icons.AppTab.eggLog)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 20)
                    .foregroundStyle(.white)
                
                Text(viewModel.totalEggsForSelectedPeriod.formatted())
                    .font(.inter(.semibold, size: 28))
                    .foregroundStyle(.appBrown)
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal)
            .background(.appOrange)
        }
        .frame(height: 52)
        .padding(.leading, 12)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
    }
}

#Preview {
    StatisticsView()
}

