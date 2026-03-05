import SwiftUI

struct AddEggNoteView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var viewModel: EggLogViewModel
    
    @State var note: EggNote
    
    var body: some View {
        ZStack {
            background
            
            VStack(spacing: 16) {
                navigationBar
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        chicken
                        eggCounter
                        date
                        datePicker
                        saveButton
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .navigationBarBackButtonHidden()
    }
    
    private var background: some View {
        Image(.Images.BG)
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Add Chicken")
                .font(.inter(.semibold, size: 28))
                .foregroundStyle(.appBrown)
        }
        .frame(height: 80)
        .background(.appOrange)
    }
    
    private var chicken: some View {
        HStack(spacing: 10) {
            if let image = viewModel.currentChicken.image {
                Image(uiImage: image)
                    .resizeCrop()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .cornerRadius(16)
            }
            
            VStack(spacing: 4) {
                Text(viewModel.currentChicken.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.inter(.semibold, size: 19))
                    .foregroundStyle(.appBrown)
                
                Text(viewModel.currentChicken.breed)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.inter(.medium, size: 19))
                    .foregroundStyle(.appLightBrown)
            }
        }
        .padding(.horizontal, 16)
        .frame(width: UIScreen.main.bounds.width - 32, height: 100)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
    }
    
    private var eggCounter: some View {
        HStack {
            Button {
                let newValue = note.count == 1 ? 1 : note.count - 1
                note.count = newValue
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 48, height: 48)
                    .foregroundStyle(Color(hex: "#FDEADE"))
                    .overlay {
                        Image(systemName: "minus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.appOrange)
                    }
            }
            
            
            HStack {
                Image(.Icons.AppTab.eggLog)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.appBrown)
                
                Text(note.count.formatted())
                    .font(.inter(.semibold, size: 58))
                    .foregroundStyle(.appBrown)
            }
            .frame(maxWidth: .infinity)
            
            Button {
                note.count += 1
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.appOrange)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.appLightBeige)
                    }
            }
        }
        .frame(height: 102)
        .padding(.horizontal, 12)
        .background(.white)
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
    }
    
    private var date: some View {
        VStack {
            Text("Date")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.inter(.bold, size: 28))
                .foregroundStyle(.appBrown)
            
            HStack {
                Text(note.date.formatted(.dateTime.year().month(.abbreviated).day()))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.inter(.medium, size: 19))
                    .foregroundStyle(.appLightBrown)
                
                Image(systemName: "calendar")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.appOrange)
            }
            .frame(height: 52)
            .padding(.horizontal, 12)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
        }
        .padding(.horizontal, 16)
    }
    
    private var datePicker: some View {
        DatePicker("", selection: $note.date, in: ...Date(), displayedComponents: [.date])
            .labelsHidden()
            .datePickerStyle(.graphical)
            .tint(.appOrange)
            .background(.white)
            .cornerRadius(16)
            .padding(.horizontal, 16)
            .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
    }
    
    private var saveButton: some View {
        Button {
            viewModel.save(note)
        } label: {
            Text("Save")
                .frame(width: 270, height: 52)
                .background(.appOrange)
                .font(.inter(.semibold, size: 19))
                .foregroundStyle(.appLightBeige)
                .cornerRadius(16)
        }
    }
}

#Preview {
    AddEggNoteView(note: EggNote())
        .environmentObject(EggLogViewModel())
}
