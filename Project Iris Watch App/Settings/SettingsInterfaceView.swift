//
//  SettingsInterfaceView.swift
//  Project Iris Watch App
//
//  Created by ThreeManager785 on 2024/8/2.
//


import SwiftUI
import Cepheus
import Vela

//MARK: --- Interface ---

struct SettingsInterfaceView: View {
  let languageCode = Locale.current.language.languageCode
  let languageScript = Locale.current.language.script
  @Environment(\.layoutDirection) var layoutDirection
//  @AppStorage("tipConfirmRequired") var tipConfirmRequired = false
//  @AppStorage("tipAnimationSpeed") var tipAnimationSpeed = 1
//  @AppStorage("homeToolbar1") var homeToolbar1: String = "nil"
//  @AppStorage("homeToolbar2") var homeToolbar2: String = "nil"
//  @AppStorage("homeToolbar3") var homeToolbar3: String = "nil"
//  @AppStorage("homeToolbar4") var homeToolbar4: String = "nil"
  @AppStorage("homeToolbarMonogram") var homeToolbarMonogram: String = ""
//  @AppStorage("homeToolbarMonogramFontIsUsingTitle3") var homeToolbarMonogramFontIsUsingTitle3 = false
//  @AppStorage("homeToolbarMonogramFontIsCapitalized") var homeToolbarMonogramFontIsCapitalized = true
//  @AppStorage("homeToolbarMonogramFontDesign") var homeToolbarMonogramFontDesign = 1
  @AppStorage("homeToolbarBottomBlur") var homeToolbarBottomBlur = 0
  @AppStorage("leftSwipeSearchButton") var leftSwipeSearchButton = 4
  @AppStorage("rightSwipeSearchButton") var rightSwipeSearchButton = 3
  @AppStorage("internalCepheusIsEnabled") var internalCepheusIsEnabled = false
//  @AppStorage("appFont") var appFont = 0
//  @AppStorage("appLanguage") var appLanguage = ""
  @State var tintColorValues: [Any] = defaultColor
  @State var tintColor = Color(hue: defaultColor[0]/359, saturation: defaultColor[1]/100, brightness: defaultColor[2]/100)
  
  let dateFormatter = DateFormatter()
  //  @State var editingToolbar = 0
  //  @Environment(\.dismiss) var dismiss
//  let fontDesign: [Int: Font.Design] = [0: .default, 1: .rounded, 2: .monospaced, 3: .serif]
//  let availableLanguages = ["", "ar", "zh-Hans", "zh-Hant", "nl", "en", "fr", "de", "hi", "id", "it", "ja", "ko", "pl", "pt", "ru", "es", "th", "tr", "uk", "vi"]
//  let presentationText = ["∗", "عر", "简", "繁", "Nl", "En", "Fr", "De", "हि", "Id", "It", "日", "한", "Pl", "Pt", "Ру", "Es", "ทย", "Tr", "Ук", "Vi"]
  var body: some View {
    NavigationStack {
      List {
        if #available(watchOS 10.0, *) {
          Section("Settings.interface.home") {
            VelaPicker(color: $tintColor, defaultColor: Color(hue: defaultColor[0]/359, saturation: defaultColor[1]/100, brightness: defaultColor[2]/100), allowOpacity: false, HSB_primary: true, label: {
              Text("Settings.interface.home.color")
            }, onSubmit: {
              UserDefaults.standard.set([tintColor.HSB_values().0, tintColor.HSB_values().1, tintColor.HSB_values().2], forKey: "tintColor")
            })
            NavigationLink(destination: {
              SettingsInterfaceHomeListEditView()
                .navigationTitle("Settings.interface.home.list.title")
            }, label: {
              Text("Settings.interface.home.list")
            })
//            .swipeActions(content: {
//              Button(role: .destructive, action: {
//                UserDefaults.standard.set(defaultHomeList, forKey: "homeList")
//                UserDefaults.standard.set(defaultHomeListValues, forKey: "homeListValues")
//                showTip("Settings.interface.home.list.reseted", symbol: "")
//              }, label: {
//                Label("Settings.interface.home.list.error.reset", systemImage: "arrow.clockwise")
//              })
//            })
            //          if #available(watchOS 10.0, *) {
            NavigationLink(/*isActive: $showToolbarEditingSheet, */destination: {
              SettingsInterfaceHomeToolbarEditView()
            }, label: {
              Text("Settings.interface.home.toolbar")
            })
          }
          .onChange(of: homeToolbarMonogram, perform: { value in
            if !homeToolbarMonogram.isEmpty {
              homeToolbarBottomBlur = 1
            } else {
              homeToolbarBottomBlur = 0
            }
          })
        }
        
//        Section("Settings.interface.global") {
//          Slider(value: $brightnessDimmingLevel, in: 0...100, step: 1) {
//           Text("1")
//          }
//        }
        
        if #available(watchOS 10, *) {
          Section(content: {
            Toggle(isOn: $internalCepheusIsEnabled, label: {
              Text("Settings.keyboard.enable")
            })
            NavigationLink(destination: {
              CepheusSettingsView()
            }, label: {
              Label("Settings.keyboard.learn-more", systemImage: "keyboard.badge.ellipsis")
            })
          }, header: {
            Text("Settings.keyboard")
          }, footer: {
            Text(verbatim: "Powered by Garden Cepheus")
          })
        }
        
        Section("Settings.interface.search-button") {
          Picker("Settings.interface.search-button.swipe.left", selection: $leftSwipeSearchButton) {
            Text("Settings.interface.search-button.swipe.none")
              .tag(0)
            Text("Settings.interface.search-button.swipe.privacy-mode")
              .tag(1)
            Text("Settings.interface.search-button.swipe.search")
              .tag(2)
            Text("Settings.interface.search-button.swipe.secondary")
              .tag(4)
            Text("Settings.interface.search-button.swipe.customize")
              .tag(3)
          }
          Picker("Settings.interface.search-button.swipe.right", selection: $rightSwipeSearchButton) {
            Text("Settings.interface.search-button.swipe.none")
              .tag(0)
            Text("Settings.interface.search-button.swipe.privacy-mode")
              .tag(1)
            Text("Settings.interface.search-button.swipe.search")
              .tag(2)
            Text("Settings.interface.search-button.swipe.secondary")
              .tag(4)
            Text("Settings.interface.search-button.swipe.customize")
              .tag(3)
          }
        }
        
//        Section("Settings.interface.tip") {
//          Toggle("Settings.interface.tip.confirm", isOn: $tipConfirmRequired)
//          Picker("Settings.interface.tip.speed", selection: $tipAnimationSpeed) {
//            Text("Settings.interface.tip.speed.fast")
//              .tag(0)
//            Text("Settings.interface.tip.speed.default")
//              .tag(1)
//            Text("Settings.interface.tip.speed.slow")
//              .tag(2)
//            Text("Settings.interface.tip.speed.very-slow")
//              .tag(3)
//          }
//        }
        
        if #available(watchOS 10.0, *) {
          Section("Settings.interface.others") {
            NavigationLink(destination: {
              SettingsInterfaceAdvancedView()
            }, label: {
              HStack {
                Label("Settings.interface.advanced", systemImage: "hammer")
                Spacer()
                Image(systemName: "chevron.forward")
                  .foregroundStyle(.secondary)
              }
            })
          }
        }
      }
      .navigationTitle("Settings.interface")
      .onAppear {
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        if (UserDefaults.standard.array(forKey: "tintColor") ?? []).isEmpty {
          UserDefaults.standard.set(defaultColor, forKey: "tintColor")
        }
        tintColorValues = UserDefaults.standard.array(forKey: "tintColor") ?? (defaultColor as [Any])
        tintColor = Color(hue: (tintColorValues[0] as! Double)/359, saturation: (tintColorValues[1] as! Double)/100, brightness: (tintColorValues[2] as! Double)/100)
        if !homeToolbarMonogram.isEmpty {
          homeToolbarBottomBlur = 1
        } else {
          homeToolbarBottomBlur = 0
        }
      }
    }
  }
}

