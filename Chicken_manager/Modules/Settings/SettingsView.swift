import SwiftUI

struct SettingsView: View {
    
    @AppStorage("isPushLaunched") var isPushLaunched = false
    
    @State private var navPath: [SettingsScreen] = []
    @State private var userModel = UserModel()
    
    @State private var isOn = false
    @State private var showDeleteAlert = false
    @State private var showPushError = false
    @State private var showPrivacy = false
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                background
                
                VStack(spacing: 16) {
                    navigationBar
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            user
                            cells
                            
                            Color.clear
                                .frame(height: 100)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .navigationDestination(for: SettingsScreen.self) { screen in
                switch screen {
                    case .user(let user):
                        UserView(userModel: user)
                }
            }
            .onAppear {
                AppTabAppearanceManager.shared.show()
                isOn = isPushLaunched
                
                Task {
                    await userModel = UserDefaultsService.shared.get(UserModel.self, forKey: .user) ??
                    UserModel()
                }
            }
            .sheet(isPresented: $showPrivacy) {
                PrivacyView()
            }
            .alert("Push permission wasn't allowed", isPresented: $showPushError) {}
            .alert("Are you sure you want to delete all the data?", isPresented: $showDeleteAlert) {
                Button("Yes", role: .destructive) {
                    Task {
                        UserDefaultsService.shared.remove(forKey: .chickens)
                        UserDefaultsService.shared.remove(forKey: .user)
                    }
                }
            }
            .onChange(of: isOn) { isOn in
                if isOn {
                    switch PushNotificationManager.shared.currentStatus {
                        case .allowed:
                            isPushLaunched = true
                        case .denied:
                            showPushError = true
                        case .notDetermined:
                            PushNotificationManager.shared.requestAuthorization { status in
                                switch status {
                                    case .allowed:
                                        return
                                    case .denied, .notDetermined:
                                        self.isOn = false
                                }
                            }
                    }
                } else {
                    isPushLaunched = false
                }
            }
        }
    }
    
    private var background: some View {
        Image(.Images.BG)
            .resizeCrop()
    }
    
    private var navigationBar: some View {
        HStack {
            Text("Settings")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.inter(.bold, size: 38))
                .foregroundStyle(.appBrown)
        }
        .frame(height: 80)
        .padding(.horizontal, 16)
    }
    
    private var user: some View {
        HStack {
            Image(userModel.type.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
            
            VStack {
                Text(userModel.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.inter(.semibold, size: 19))
                    .foregroundStyle(.appBrown)
                
                VStack(spacing: 4) {
                    Text(userModel.type.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(userModel.type.subtitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(.appLightBrown)
            }
            
            Button {
                AppTabAppearanceManager.shared.hide()
                navPath.append(.user(userModel))
            } label: {
                Text("Edit")
                    .frame(width: 70, height: 30)
                    .background(.appOrange)
                    .cornerRadius(16)
                    .font(.inter(.semibold, size: 19))
                    .foregroundStyle(.appLightBeige)
            }
        }
        .frame(minHeight: 138)
        .padding(16)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
    }
    
    private var cells: some View {
        VStack(spacing: 16) {
            ForEach(SettingsCellType.allCases) { type in
                HStack {
                    switch type {
                        case .push:
                            HStack {
                                VStack {
                                    Text("Push Notifications")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.inter(.semibold, size: 19))
                                        .foregroundStyle(.appBrown)
                                    
                                    Text("Receive alerts for your egg log")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.inter(.medium, size: 12))
                                        .foregroundStyle(.appLightBrown)
                                }
                                
                                Toggle(isOn: $isOn) {}
                                    .labelsHidden()
                                    .tint(.appOrange)
                            }
                        case .privacy:
                            Button {
                                showPrivacy = true
                            } label: {
                                HStack {
                                    Text("Privacy Policy")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.inter(.semibold, size: 19))
                                        .foregroundStyle(.appBrown)
                                    
                                    Image(.Icons.forward)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(.appOrange)
                                }
                            }
                        case .version:
                            HStack {
                                Text("App version:")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.inter(.semibold, size: 19))
                                
                                Text(appVersion)
                                    .font(.inter(.semibold, size: 19))
                            }
                            .foregroundStyle(.appBrown)
                        case .deleteData:
                            Button {
                                showDeleteAlert = true
                            } label: {
                                HStack {
                                    VStack {
                                        Text("Delete All Data")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.inter(.semibold, size: 19))
                                            .foregroundStyle(Color(hex: "#F9635E"))
                                        
                                        Text("Perma erase all app data")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.inter(.medium, size: 12))
                                            .foregroundStyle(.appLightBrown)
                                    }
                                    
                                    Image(.Icons.forward)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(Color(hex: "#F9635E"))
                                }
                            }
                    }
                }
                .frame(height: 80)
                .padding(.horizontal)
                .background(type == .deleteData ? Color(hex: "#F9635E").opacity(0.2) : .white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
            }
        }
    }
}

#Preview {
    SettingsView()
}

struct PrivacyView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Privacy Policy")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title)
                        .foregroundStyle(.black)
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "multiply.circle.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.black.opacity(0.5))
                    }
                }
                
                Divider()
                
                ScrollView(showsIndicators: false) {
                    Text(LocalizedStringKey(privacy))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.body)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
        }
    }
}

fileprivate let privacy = """
**Privacy Policy**

This privacy policy applies to the EggFarms PRO app (hereby referred to as "Application") for mobile devices that was created by (hereby referred to as "Service Provider") as a Free service. This service is intended for use "AS IS".

**Information Collection and Use**

The Application collects information when you download and use it. This information may include information such as

*   Your device's Internet Protocol address (e.g. IP address)
*   The pages of the Application that you visit, the time and date of your visit, the time spent on those pages
*   The time spent on the Application
*   The operating system you use on your mobile device

The Application does not gather precise information about the location of your mobile device.

The Application uses Artificial Intelligence (AI) technologies to enhance user experience and provide certain features. The AI components may process user data to deliver personalized content, recommendations, or automated functionalities. All AI processing is performed in accordance with this privacy policy and applicable laws. If you have questions about the AI features or data processing, please contact the Service Provider.

The Service Provider may use the information you provided to contact you from time to time to provide you with important information, required notices and marketing promotions.

For a better experience, while using the Application, the Service Provider may require you to provide us with certain personally identifiable information. The information that the Service Provider request will be retained by them and used as described in this privacy policy.

**Third Party Access**

Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service. The Service Provider may share your information with third parties in the ways that are described in this privacy statement.

The Service Provider may disclose User Provided and Automatically Collected Information:

*   as required by law, such as to comply with a subpoena, or similar legal process;
*   when they believe in good faith that disclosure is necessary to protect their rights, protect your safety or the safety of others, investigate fraud, or respond to a government request;
*   with their trusted services providers who work on their behalf, do not have an independent use of the information we disclose to them, and have agreed to adhere to the rules set forth in this privacy statement.

**Opt-Out Rights**

You can stop all collection of information by the Application easily by uninstalling it. You may use the standard uninstall processes as may be available as part of your mobile device or via the mobile application marketplace or network.

**Data Retention Policy**

The Service Provider will retain User Provided data for as long as you use the Application and for a reasonable time thereafter. If you'd like them to delete User Provided Data that you have provided via the Application, please contact them at rylanjones71@icloud.com and they will respond in a reasonable time.

**Children**

The Service Provider does not use the Application to knowingly solicit data from or market to children under the age of 13.

The Service Provider does not knowingly collect personally identifiable information from children. The Service Provider encourages all children to never submit any personally identifiable information through the Application and/or Services. The Service Provider encourage parents and legal guardians to monitor their children's Internet usage and to help enforce this Policy by instructing their children never to provide personally identifiable information through the Application and/or Services without their permission. If you have reason to believe that a child has provided personally identifiable information to the Service Provider through the Application and/or Services, please contact the Service Provider <span>(rylanjones71@icloud.com)</span> so that they will be able to take the necessary actions. You must also be at least 16 years of age to consent to the processing of your personally identifiable information in your country (in some countries we may allow your parent or guardian to do so on your behalf).

**Security**

The Service Provider is concerned about safeguarding the confidentiality of your information. The Service Provider provides physical, electronic, and procedural safeguards to protect information the Service Provider processes and maintains.

**Changes**

This Privacy Policy may be updated from time to time for any reason. The Service Provider will notify you of any changes to the Privacy Policy by updating this page with the new Privacy Policy. You are advised to consult this Privacy Policy regularly for any changes, as continued use is deemed approval of all changes.

This privacy policy is effective as of 2026-03-05

**Your Consent**

By using the Application, you are consenting to the processing of your information as set forth in this Privacy Policy now and as amended by us.

**Contact Us**

If you have any questions regarding privacy while using the Application, or have questions about the practices, please contact the Service Provider via email at rylanjones71@icloud.com.

* * *
"""
