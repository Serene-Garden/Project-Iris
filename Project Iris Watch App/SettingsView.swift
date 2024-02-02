//
//  SettingsView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2023/10/21.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("tipConfirmRequired") var tipConfirmRequired = false
    @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
    @AppStorage("isPrivateModePinned") var isPrivateModePinned = false
    @AppStorage("isPasscodeRequired") var isPasscodeRequired = false
    @AppStorage("isCookiesAllowed") var isCookiesAllowed = false
    @AppStorage("isSettingsButtonPinned") var isSettingsButtonPinned = false
    @AppStorage("isBookmarkRequiringPassword") var isBookmarkRequiringPassword = false
    @AppStorage("tipAnimationSpeed") var tipAnimationSpeed = 1
    @AppStorage("tintSaturation") var tintSaturation: Int = 40
    @AppStorage("tintBrightness") var tintBrightness: Int = 100
    @AppStorage("searchEngineSelection") var searchEngineSelection = "Bing"
    @AppStorage("searchEngineBackup") var searchEngineBackup = "Google"
    @AppStorage("customizedSearchEngine") var customizedSearchEngine = ""
    @AppStorage("longPressButtonAction") var longPressButtonAction = 0
    @State var isClearHistoryAlertPresenting = false
    @State var isToggling = false
    @State var tintColor = Color(hue: 275/360, saturation: 40/100, brightness: 100/100)
    @State var isCustomizeSearchEngineSheetDisplaying = false
    @State var isTintColorSheetDisplaying = false
    @State var isPasswordSheetDisplaying = false
    @State var userCustomizedSearchEngineInput = ""
    var body: some View {
        List {
            Section("Settings.search") {
                Picker("Settings.search-engine.default", selection: $searchEngineSelection) {
                    Text("Settings.search-engine.Bing").tag("Bing")
                    Text("Settings.search-engine.Google").tag("Google")
                    Text("Settings.search-engine.Baidu").tag("Baidu")
                    Text("Settings.search-engine.Sougou").tag("Sougou")
                    Text("Settings.search-engine.customize").tag("Customize")
                }
                Picker("Settings.search-engine.backup", selection: $searchEngineBackup) {
                    Text("Settings.search-engine.Bing").tag("Bing")
                    Text("Settings.search-engine.Google").tag("Google")
                    Text("Settings.search-engine.Baidu").tag("Baidu")
                    Text("Settings.search-engine.Sougou").tag("Sougou")
                    Text("Settings.search-engine.customize").tag("Customize")
                }
                Button(action: {
                    isCustomizeSearchEngineSheetDisplaying = true
                }, label: {
                    Label("Settings.search-engine.customize...", systemImage: "magnifyingglass")
                })
            }
            
            Section(content: {
                if !isPasscodeRequired {
                    NavigationLink(destination: {
                        PasscodeCreateView()
                    }, label: {
                        Label("Settings.passcode.create", systemImage: "lock")
                    })
                } else {
                    Toggle(isOn: $isBookmarkRequiringPassword, label: {
                        Label("Settings.passcode.bookmarks", systemImage: "bookmark")
                    })
                    .onChange(of: isBookmarkRequiringPassword, {
                        if !isToggling {
                            isToggling = true
                            isBookmarkRequiringPassword.toggle()
                            isPasswordSheetDisplaying = true
                        }
                    })
                    .onChange(of: isPasswordSheetDisplaying, {
                        if !isPasswordSheetDisplaying {
                            isToggling = false
                        }
                    })
                    .sheet(isPresented: $isPasswordSheetDisplaying, content: {PasscodeView(destination: 2)})
                    NavigationLink(destination: {
                        PasscodeChangeView()
                    }, label: {
                        Label("Settings.passcode.change", systemImage: "lock.open")
                    })
                    NavigationLink(destination: {
                        PasscodeDeleteView()
                    }, label: {
                        Label("Settings.passcode.delete", systemImage: "lock.slash")
                            .foregroundStyle(.red)
                    })
                }
            }, header: {
                Text("Settings.passcode")
            }, footer: {
                if isBookmarkRequiringPassword {
                    Text("Settings.passcode.discription.bookmarks")
                } else {
                    Text("Settings.passcode.discription")
                }
            })
            
            Section("Settings.interface") {
                Picker("Settings.inteface.long-presss-action", selection: $longPressButtonAction) {
                    Text("Settings.inteface.long-presss-action.none").tag(0)
                    Text("Settings.inteface.long-presss-action.backup-engine").tag(1)
                    Text("Settings.inteface.long-presss-action.select-engine").tag(2)
                    Text("Settings.inteface.long-presss-action.private-mode").tag(3)
                }
                Toggle(isOn: $isSettingsButtonPinned, label: {
                    Label("Settings.interface.pin-settings-button", systemImage: "gear")
                })
                Toggle(isOn: $isPrivateModePinned, label: {
                    Label("Settings.privacy-mode.pin", systemImage: "hand.raised")
                })
            }
            
            Section("Settings.privacy") {
                Toggle(isOn: $isPrivateModeOn, label: {
                    Label("Settings.privacy-mode", systemImage: "hand.raised")
                })
                Button(action: {
                    isClearHistoryAlertPresenting = true
                }, label: {
                    Label("Settings.privacy.clear-history", systemImage: "trash")
                        .foregroundStyle(.red)
                })
            }
            
            Section("Settings.Cookies") {
                Toggle("Settings.cookies.allow", isOn: $isCookiesAllowed)
            }
            
            Section("Settings.tip") {
                Toggle("Settings.tip.confirm", isOn: $tipConfirmRequired)
                Picker("Settings.tip.speed", selection: $tipAnimationSpeed) {
                    Text("Settings.tip.speed.fast")
                        .tag(0)
                    Text("Settings.tip.speed.default")
                        .tag(1)
                    Text("Settings.tip.speed.slow")
                        .tag(2)
                    Text("Settings.tip.speed.very-slow")
                        .tag(3)
                }
            }

            Section {
                NavigationLink(destination: AboutView(), label: {
                    Label("Settings.about", systemImage: "info.circle")
                })
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            tintColor = Color(hue: 275/360, saturation: Double(tintSaturation/100), brightness: Double(tintBrightness/100))
        }
        .sheet(isPresented: $isCustomizeSearchEngineSheetDisplaying, onDismiss: {
            if !userCustomizedSearchEngineInput.contains("\\Iris") {
                showTip("Search.search-engine.customize.failed", symbol: "exclamationmark.circle.fill")
            } else {
                if !userCustomizedSearchEngineInput.hasPrefix("http://") && !userCustomizedSearchEngineInput.hasPrefix("http://") {
                    userCustomizedSearchEngineInput = "http://" + userCustomizedSearchEngineInput
                }
                customizedSearchEngine = userCustomizedSearchEngineInput
            }
            userCustomizedSearchEngineInput = ""
        }) {
            List {
                if userCustomizedSearchEngineInput.contains("\\Iris") {
                    Label("Search.search-engine.customize.replacement-tip", systemImage: "checkmark.circle")
                } else {
                    Label("Search.search-engine.customize.replacement-tip", systemImage: "exclamationmark.circle")
                }
                /* if customizedSearchEngine.isEmpty {
                 Text("Settings.search-engine.customize.none")
                 } else {
                 Text(customizedSearchEngine)
                 } */
                // 永远不要觉得所有用户都要听你的话
                // 要自己给输入做验证
                TextField("Search.search-engine.customize.enter", text: $userCustomizedSearchEngineInput)
            }
            .onAppear {
                userCustomizedSearchEngineInput = customizedSearchEngine
            }
        }
        .alert("Settings.history.clear", isPresented: $isClearHistoryAlertPresenting, actions: {
            Button(role: .destructive, action: {
                UserDefaults.standard.set([], forKey: "HistoryLink")
            }, label: {
                HStack {
                    Text("Settings.history.confirm")
                    Spacer()
                }
            })
            Button(action: {
                
            }, label: {
                Text("Settings.history.cancel")
            })
        }, message: {
            Text("Settings.history.message")
        })
    }
}



#Preview {
    SettingsView()
}
