import SwiftUI

struct AddChickenView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject private var viewModel: ChickensViewModel
    
    @State var chicken: Chicken
    
    @State private var eggsCount: Double = 0
    @State private var shouldShowImagePicker = false
    @State private var hasDateSelected = false
    @State private var shouldShowDatePicker = false
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        ZStack {
            background
            
            VStack(spacing: 40) {
                navigationBar
                
                VStack(spacing: 36) {
                    image
                    inputs
                }
                .padding(.horizontal, 16)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
            if shouldShowDatePicker {
                datePicker
            }
        }
        .navigationBarBackButtonHidden()
        .animation(.default, value: shouldShowDatePicker)
        .sheet(isPresented: $shouldShowImagePicker) {
            ImagePicker(selectedImage: $chicken.image)
        }
        .onAppear {
            eggsCount = Double(chicken.eggsPerWeek)
            hasDateSelected = chicken.name != ""
        }
        .onChange(of: chicken.birthDate) { _ in 
            hasDateSelected = true
        }
        .onChange(of: eggsCount) { count in
            chicken.eggsPerWeek = Int(count)
        }
    }
    
    private var background: some View {
        Image(.BG)
            .resizeCrop()
    }
    
    private var navigationBar: some View {
        ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.appBeige)
                }
                .frame(width: 40, height: 40)
                
                Spacer()
                
                Button {
                    viewModel.save(chicken)
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.appBeige.opacity(chicken.isReady ? 1 : 0))
                }
                .frame(width: 40, height: 40)
                .disabled(!chicken.isReady)
            }
            
            Text("Add Chicken")
                .font(.inter(.semibold, size: 28))
                .foregroundStyle(.appBrown)
        }
        .frame(height: 80)
        .background(.appOrange)
    }
    
    private var image: some View {
        VStack(spacing: 8) {
            Text("Photo")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.inter(.semibold, size: 20))
                .foregroundStyle(.appBrown)
            
            HStack {
                Button {
                    shouldShowImagePicker = true
                } label: {
                    ZStack {
                        if let image = chicken.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 130, height: 130)
                                .clipped()
                                .cornerRadius(16)
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 130, height: 130)
                                .foregroundStyle(.appOrange)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            .appBrown,
                                            style: StrokeStyle(
                                                lineWidth: 2,
                                                lineCap: .round,
                                                lineJoin: .round,
                                                dash: [8],
                                                dashPhase: 0
                                            )
                                        )
                                        .padding(1)
                                }
                        }
                        
                        Image(systemName: "photo")
                            .font(.system(size: 64, weight: .medium))
                            .foregroundStyle(.appLightBeige.opacity(chicken.image == nil ? 1 : 0.5))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var inputs: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Text("Name")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.inter(.semibold, size: 19))
                    .foregroundStyle(.appBrown)
                
                CustomTextField(
                    text: $chicken.name,
                    placeholder: "Enter name",
                    isFocused: $isFocused
                )
            }
            
            VStack(spacing: 12) {
                Text("Breed")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.inter(.semibold, size: 19))
                    .foregroundStyle(.appBrown)
                
                CustomTextField(
                    text: $chicken.breed,
                    placeholder: "Enter breed",
                    isFocused: $isFocused
                )
            }
            
            VStack(spacing: 12) {
                Text("Date of Birth")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.inter(.semibold, size: 19))
                    .foregroundStyle(.appBrown)
                
                Button {
                    shouldShowDatePicker = true
                } label: {
                    HStack {
                        let date = chicken.birthDate.formatted(.dateTime.year().month(.twoDigits).day())
                        
                        Text(hasDateSelected ? date : "Select date")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.inter(.semibold, size: 19))
                            .foregroundStyle(.white)
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .frame(height: 43)
                    .padding(.horizontal, 12)
                    .background(.appOrange)
                    .cornerRadius(16)
                }
            }
            
            VStack(spacing: 12) {
                Text("Eggs per week")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.inter(.semibold, size: 19))
                    .foregroundStyle(.appBrown)
                
                HStack(spacing: 10) {
                    Slider(value: $eggsCount, in: 1...10, step: 1)
                        .labelsHidden()
                        .tint(.appOrange)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .frame(width: 48, height: 48)
                        .foregroundStyle(.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.appBrown, lineWidth: 1)
                                .overlay {
                                    Text(eggsCount.formatted())
                                }
                        }
                }
            }
        }
    }
    
    private var datePicker: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    shouldShowDatePicker = false
                }
            
            VStack {
                HStack {
                    Button {
                        shouldShowDatePicker = false
                    } label: {
                        Text("Done")
                            .foregroundStyle(.appOrange)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal)
                
                
                DatePicker("", selection: $chicken.birthDate, displayedComponents: [.date])
                    .labelsHidden()
                    .datePickerStyle(.graphical)
                    .tint(.appOrange)
            }
            .padding()
            .background(.white)
            .cornerRadius(16)
            .padding()
        }
    }
}

#Preview {
    AddChickenView(chicken: Chicken(isMock: false))
}

#Preview {
    AddChickenView(chicken: Chicken(isMock: true))
}
