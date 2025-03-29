//
//  SettingsInterfaceAdvancedView.swift
//  Project Iris
//
//  Created by ThreeManager785 on 9/8/24.
//

import SwiftUI

struct SettingsInterfaceAdvancedView: View {
  let languageCode = Locale.current.language.languageCode
  let languageScript = Locale.current.language.script
  @Environment(\.layoutDirection) var layoutDirection
//  @AppStorage("tipConfirmRequired") var tipConfirmRequired = false
//  @AppStorage("tipAnimationSpeed") var tipAnimationSpeed = 1
//  @AppStorage("homeToolbar1") var homeToolbar1: String = "nil"
//  @AppStorage("homeToolbar2") var homeToolbar2: String = "nil"
//  @AppStorage("homeToolbar3") var homeToolbar3: String = "nil"
//  @AppStorage("homeToolbar4") var homeToolbar4: String = "nil"
//  @AppStorage("homeToolbarMonogram") var homeToolbarMonogram: String = ""
//  @AppStorage("homeToolbarMonogramFontIsUsingTitle3") var homeToolbarMonogramFontIsUsingTitle3 = false
//  @AppStorage("homeToolbarMonogramFontIsCapitalized") var homeToolbarMonogramFontIsCapitalized = true
//  @AppStorage("homeToolbarMonogramFontDesign") var homeToolbarMonogramFontDesign = 1
  @AppStorage("homeToolbarBottomBlur") var homeToolbarBottomBlur = 0
//  @AppStorage("leftSwipeSearchButton") var leftSwipeSearchButton = 0
//  @AppStorage("rightSwipeSearchButton") var rightSwipeSearchButton = 3
  @AppStorage("appFont") var appFont = 0
  @AppStorage("appLanguage") var appLanguage = ""
//  @AppStorage("dimmingCoefficientIndex") var dimmingCoefficientIndex = 100
  @AppStorage("globalDimming") var globalDimming = false
//  @State var tintColorValues: [Any] = defaultColor
//  @State var tintColor = Color(hue: defaultColor[0]/359, saturation: defaultColor[1]/100, brightness: defaultColor[2]/100)
//  @State var dimmingCoefficient = 1.0
//  @State var isToolbarOnSelect = false
  @State var currentTextDirection = 0
  @State var selectedTextDirection = 0
  //  @State var editingToolbar = 0
  //  @Environment(\.dismiss) var dismiss
  let fontDesign: [Int: Font.Design] = [0: .default, 1: .rounded, 2: .monospaced, 3: .serif]
  let availableLanguages = ["", "zh-Hans", "zh-Hant","en"]
  let presentationText = ["∗", "简", "繁", "En"]
    //  let availableLanguages = ["", "ar", "zh-Hans", "zh-Hant", "nl", "en", "fr", "de", "hi", "id", "it", "ja", "ko", "pl", "pt", "ru", "es", "th", "tr", "uk", "vi"]
    //  let presentationText = ["∗", "عر", "简", "繁", "Nl", "En", "Fr", "De", "हि", "Id", "It", "日", "한", "Pl", "Pt", "Ру", "Es", "ทย", "Tr", "Ук", "Vi"]
  var body: some View {
      //MARK: --- Advanced ---
      List {
        Section(content: {
          Text("Settings.interface.advanced.footer")
            .foregroundStyle(.yellow)
          Picker("Settings.interface.home.blur", selection: $homeToolbarBottomBlur) {
            Text("Settings.interface.home.blur.none").tag(0)
            Text("Settings.interface.home.blur.thin").tag(1)
            Text("Settings.interface.home.blur.thick").tag(2)
          }
          Picker("Settings.interface.advanced.font", selection: $appFont) {
            Text("Settings.interface.advanced.font.default").tag(0).fontDesign(.default)
            Text("Settings.interface.advanced.font.rounded").tag(1).fontDesign(.rounded)
            Text("Settings.interface.advanced.font.serif").tag(2).fontDesign(.serif)
          }
//                  Picker("Settings.interface.advanced.dimming-coefficient", selection: $dimmingCoefficientIndex) {
//                    ForEach(0...10, id: \.self) { dimmingIndex in
//                      Text(verbatim: "\(dimmingIndex*10)%").tag(100-(dimmingIndex*10))
//                    }
//                  }
          NavigationLink(destination: {
            List {
              Section {
                Button(action: {
                  appLanguage = ""
                }, label: {
                  HStack {
                    Text(verbatim: "*")
                      .font(.title3)
                      .fontDesign(.monospaced)
                    Text("Settings.interface.advanced.languange.follow-system-language")
                    Spacer()
                    if appLanguage == "" {
                      Image(systemName: "checkmark")
                    }
                  }
                })
                if selectedTextDirection != currentTextDirection {
                  HStack {
                    Image(systemName: "text.alignright")
                      .font(.title3)
                    VStack(alignment: .leading) {
                      Text("Settings.interface.advanced.languange.incorrect-direction")
                        .environment(\.locale, .init(identifier: "\(languageCode!)-\(languageScript!)"))
                      Text("Settings.interface.advanced.languange.incorrect-direction")
                        .opacity(0.6)
                        .font(.footnote)
                        .lineLimit(2)
                    }
                    Spacer()
                  }
                  .foregroundStyle(.yellow)
                }
              }
              Section(content: {
                ForEach(1..<availableLanguages.count, id: \.self) { languageIndex in
                  Button(action: {
                    appLanguage = availableLanguages[languageIndex]
                  }, label: {
                    HStack {
                      Text(presentationText[languageIndex])
                        .font(.title3)
                        .fontDesign(.rounded)
                      VStack(alignment: .leading) {
                        Text(Locale(identifier: availableLanguages[languageIndex]).localizedString(forIdentifier: availableLanguages[languageIndex])!)
                        Text(Locale(identifier: appLanguage.isEmpty ? "\(languageCode!)-\(languageScript!)" : appLanguage).localizedString(forIdentifier: availableLanguages[languageIndex])!)
                          .font(.footnote)
                          .foregroundStyle(.secondary)
                      }
                      Spacer()
                      if appLanguage == availableLanguages[languageIndex] {
                        Image(systemName: "checkmark")
                      }
                    }
                  })
                }
              }, footer: {
//                if false {
                  Text("Settings.interface.advanced.languange.footer")
//                }
//                Text("Settings.interface.advanced.languange.footer.description")
              })
//              .disabled()
            }
            .navigationTitle("Settings.interface.advanced.languange")
            .onAppear {
              currentTextDirection = convertLayoutDirectionIntoInt(layoutDirection)
              selectedTextDirection = convertCharacterDirectionIntoInt(Locale.Language(identifier: appLanguage).characterDirection)
            }
            .onChange(of: appLanguage, perform: { value in
              currentTextDirection = convertLayoutDirectionIntoInt(layoutDirection)
              selectedTextDirection = convertCharacterDirectionIntoInt(Locale.Language(identifier: appLanguage).characterDirection)
            })
          }, label: {
            VStack(alignment: .leading) {
              Text("Settings.interface.advanced.languange")
              Text(appLanguage.isEmpty ? String(localized: "Settings.interface.advanced.languange.follow-system-language") : Locale(identifier: appLanguage).localizedString(forIdentifier: appLanguage)!)
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
          })
          Toggle("Settings.interface.advanced.dim-globally", isOn: $globalDimming)
        })
      }
      .navigationTitle("Settings.interface.advanced")
    
  }
}

func convertCharacterDirectionIntoInt(_ direction: Locale.LanguageDirection) -> Int {
  if direction == .leftToRight {
    return 0
  } else if direction == .rightToLeft {
    return 1
  } else if direction == .topToBottom {
    return 2
  } else if direction == .bottomToTop {
    return 3
  } else if direction == .unknown {
    return 4
  } else {
    return 4
  }
}

func convertLayoutDirectionIntoInt(_ direction: LayoutDirection) -> Int {
  if direction == .leftToRight {
    return 0
  } else if direction == .rightToLeft {
    return 1
  } else {
    return 4
  }
}
