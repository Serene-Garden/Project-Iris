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
  @AppStorage("tipConfirmRequired") var tipConfirmRequired = false
  @AppStorage("tipAnimationSpeed") var tipAnimationSpeed = 1
//  @AppStorage("homeToolbar1") var homeToolbar1: String = "nil"
//  @AppStorage("homeToolbar2") var homeToolbar2: String = "nil"
//  @AppStorage("homeToolbar3") var homeToolbar3: String = "nil"
//  @AppStorage("homeToolbar4") var homeToolbar4: String = "nil"
  @AppStorage("homeToolbarMonogram") var homeToolbarMonogram: String = ""
//  @AppStorage("homeToolbarMonogramFontIsUsingTitle3") var homeToolbarMonogramFontIsUsingTitle3 = false
//  @AppStorage("homeToolbarMonogramFontIsCapitalized") var homeToolbarMonogramFontIsCapitalized = true
//  @AppStorage("homeToolbarMonogramFontDesign") var homeToolbarMonogramFontDesign = 1
  @AppStorage("homeToolbarBottomBlur") var homeToolbarBottomBlur = 0
  @AppStorage("leftSwipeSearchButton") var leftSwipeSearchButton = 0
  @AppStorage("rightSwipeSearchButton") var rightSwipeSearchButton = 3
//  @AppStorage("appFont") var appFont = 0
//  @AppStorage("appLanguage") var appLanguage = ""
  @AppStorage("dimmingCoefficientIndex") var dimmingCoefficientIndex = 100
  @AppStorage("globalDimming") var globalDimming = false
  @AppStorage("dimmingAtSpecificPeriod") var dimmingAtSpecificPeriod = false
  @State var tintColorValues: [Any] = defaultColor
  @State var tintColor = Color(hue: defaultColor[0]/359, saturation: defaultColor[1]/100, brightness: defaultColor[2]/100)
  @State var dimmingCoefficient = 1.0
  @State var isToolbarOnSelect = false
  @State var currentTextDirection = 0
  @State var selectedTextDirection = 0
  @State var dimStartingTime: Date = dimmingPresetDates.0
  @State var dimEndingTime: Date = dimmingPresetDates.1
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
            CepheusEnablingToggle(showSymbol: true)
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
            Text("Settings.interface.search-button.swipe.customize")
              .tag(3)
          }
        }
        
        Section(content: {
          if #available(watchOS 10, *) {
            NavigationLink(destination: {
              List {
                Section {
                  Button(action: {
                    dimmingAtSpecificPeriod = false
                  }, label: {
                    HStack {
                      Text("Settings.interface.dimming.period.always")
                      Spacer()
                      if !dimmingAtSpecificPeriod {
                        Image(systemName: "checkmark")
                      }
                    }
                  })
                  Button(action: {
                    dimmingAtSpecificPeriod = true
                  }, label: {
                    HStack {
                      Text("Settings.interface.dimming.period.specific")
                      Spacer()
                      if dimmingAtSpecificPeriod {
                        Image(systemName: "checkmark")
                      }
                    }
                  })
                }
                if dimmingAtSpecificPeriod {
                  Section {
                    NavigationLink(destination: {
                      DatePicker(selection: $dimStartingTime, displayedComponents: .hourAndMinute, label: {
                        Text("Settings.interface.dimming.period.from")
                      })
                      .navigationTitle("Settings.interface.dimming.period.from")
                    }, label: {
                      VStack(alignment: .leading) {
                        Text("Settings.interface.dimming.period.from")
                        Text(dateFormatter.string(from: dimStartingTime))
                          .foregroundStyle(.secondary)
                      }
                    })
                    NavigationLink(destination: {
                      DatePicker(selection: $dimEndingTime, displayedComponents: .hourAndMinute, label: {
                        Text("Settings.interface.dimming.period.to")
                      })
                      .navigationTitle("Settings.interface.dimming.period.to")
                    }, label: {
                      VStack(alignment: .leading) {
                        Text("Settings.interface.dimming.period.to")
                        Text(dateFormatter.string(from: dimEndingTime))
                          .foregroundStyle(.secondary)
                          
                      }
                    })
                  }
                  .onChange(of: dimStartingTime, {
                    writeDimTime(from: dimStartingTime, to: dimEndingTime)
                  })
                  .onChange(of: dimEndingTime, {
                    writeDimTime(from: dimStartingTime, to: dimEndingTime)
                  })
                }
              }
              .navigationTitle("Settings.interface.dimming.period")
            }, label: {
              VStack(alignment: .leading) {
                Text("Settings.interface.dimming.period")
                Text(dimmingAtSpecificPeriod ? "Settings.interface.dimming.period.specific.\(dateFormatter.string(from: dimStartingTime)).\(dateFormatter.string(from: dimEndingTime))" : "Settings.interface.dimming.period.always")
                  .foregroundStyle(.secondary)
                  .font(.caption)
              }
            })
          }
          Slider(value: $dimmingCoefficient, in: 0.2...1.0, label: {
            Text("Settings.interface.dimming")
          }, minimumValueLabel: {
            Image(systemName: "moon")
          }, maximumValueLabel: {
            Image(systemName: "sun.max")
          })
          .onChange(of: dimmingCoefficient, perform: { value in
            dimmingCoefficientIndex = Int(dimmingCoefficient * 100)
          })
          .listRowBackground(Color.clear)
          .padding(-10)
        }, header: {
          Text("Settings.interface.dimming")
        }, footer: {
          if dimmingCoefficient == 1 {
            Text("Settings.interface.dimming.description.same")
          } else {
            if globalDimming {
              Text("Settings.interface.dimming.description.\("\(Int(dimmingCoefficient*100))%").globally")
            } else {
              Text("Settings.interface.dimming.description.\("\(Int(dimmingCoefficient*100))%").portion")
            }
          }
        })
        
        Section("Settings.interface.tip") {
          Toggle("Settings.interface.tip.confirm", isOn: $tipConfirmRequired)
          Picker("Settings.interface.tip.speed", selection: $tipAnimationSpeed) {
            Text("Settings.interface.tip.speed.fast")
              .tag(0)
            Text("Settings.interface.tip.speed.default")
              .tag(1)
            Text("Settings.interface.tip.speed.slow")
              .tag(2)
            Text("Settings.interface.tip.speed.very-slow")
              .tag(3)
          }
        }
        
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
        dimStartingTime = readDimTime().0
        dimEndingTime = readDimTime().1
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
        dimmingCoefficient = Double(dimmingCoefficientIndex) / 100
      }
    }
  }
}

@MainActor @discardableResult func writeDimTime(from: Date, to: Date) -> Bool {
  do {
    let fileURL = getDocumentsDirectory().appendingPathComponent("DimTime.txt")
    let fComponents = Calendar.current.dateComponents([.hour, .minute], from: from)
    let fHour = fComponents.hour ?? 0
    let fMinute = fComponents.minute ?? 0
    
    let tComponents = Calendar.current.dateComponents([.hour, .minute], from: to)
    let tHour = tComponents.hour ?? 0
    let tMinute = tComponents.minute ?? 0
    try "\(fHour):\(fMinute),\(tHour):\(tMinute)".write(to: fileURL, atomically: true, encoding: .utf8)
    return true
  } catch {
    return false
  }
}

@MainActor func readDimTime() -> (Date, Date) {
  do {
    let fileData = try Data(contentsOf: getDocumentsDirectory().appendingPathComponent("DimTime.txt"))
    let fileContent = String(decoding: fileData, as: UTF8.self)
    
    var dateComponentsFrom = DateComponents()
    let dateFrom = fileContent.components(separatedBy: ",")[0]
    dateComponentsFrom.hour = Int(dateFrom.components(separatedBy: ":")[0])
    dateComponentsFrom.minute = Int(dateFrom.components(separatedBy: ":")[1])
    let calendarFrom = Calendar(identifier: .gregorian)
    
    var dateComponentsTo = DateComponents()
    let dateTo = fileContent.components(separatedBy: ",")[1]
    dateComponentsTo.hour = Int(dateTo.components(separatedBy: ":")[0])
    dateComponentsTo.minute = Int(dateTo.components(separatedBy: ":")[1])
    let calendarTo = Calendar(identifier: .gregorian)
    
    return (calendarFrom.date(from: dateComponentsFrom) ?? Date(), calendarTo.date(from: dateComponentsTo) ?? Date())
  } catch {
    return (Date(), Date())
  }
}
