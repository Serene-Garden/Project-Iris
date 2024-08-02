//
//  Project_IrisApp.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2023/10/19.
//

//Iris，我的处女作
//生于安详的和平
//你于2024年新春将至之际
//正式完成开发

//新的一年
//希望你能安稳的运行
//度过没有bug的一年
//感激不尽

//2024.02.03

import SwiftUI

public let languageCode = Locale.current.language.languageCode
public let countryCode = Locale.current.region!.identifier
public let watchSize = WKInterfaceDevice.current().screenBounds
public let systemVersion = WKInterfaceDevice.current().systemVersion

//UNNECESSARY
public let timeZone = Locale.current.timeZone!.identifier
public let currencyCode = Locale.current.currency!.identifier
public let measurementSystem = Locale.current.measurementSystem

//@MainActor var pShowTipText = ""
//@MainActor var pShowTipSymbol = ""
//@MainActor var pTipBoxOffset: CGFloat = 80
@MainActor var nTipboxText: LocalizedStringResource = ""
@MainActor var nTipboxSymbol = ""
@MainActor var nIsTipBoxDisplaying = false
@MainActor var isShowMemoryInScreen = false

@available(watchOS 10.0, *)
//extension AttributeScopes.AccessibilityAttributes.AnnouncementPriorityAttribute.AnnouncementPriority: @unchecked @retroactive Sendable {}


@main
struct Project_Iris_Watch_AppApp: App {
  let languageCode = Locale.current.language.languageCode
  let languageScript = Locale.current.language.script
  @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
  @AppStorage("tipConfirmRequired") var tipConfirmRequired = false
  @AppStorage("tipAnimationSpeed") var tipAnimationSpeed = 1
  @AppStorage("appFont") var appFont = 0
  @AppStorage("appLanguage") var appLanguage = ""
  @State var showTipText = ""
  @State var showTipSymbol = ""
  @State var tipboxText: LocalizedStringResource = ""
  @State var tipboxSymbol = ""
  @State var tipBoxOffset: CGFloat = 80
  @State var isTipBoxDisplaying = false
  @State var offset: CGFloat = 110
  @State var tintColorValues: [Any] = [275, 40, 100]
  @State var tintColor = Color(hue: 275/359, saturation: 40/100, brightness: 100/100)
  let tipAnimations = [0.2, 0.35, 0.65, 1]
  let globalFont: [Font.Design?] = [nil, .rounded, .serif]
  var body: some Scene {
    WindowGroup {
      Group {
        ZStack {
          if #available(watchOS 10.0, *) {
            ContentView()
              .privacySensitive(isPrivateModeOn)
              .containerBackground(tintColor.gradient, for: .navigation)
          } else {
            ContentView()
              .privacySensitive(isPrivateModeOn)
          }
          VStack {
            Spacer()
            HStack {
              Spacer()
              ZStack {
                Capsule()
                  .foregroundStyle(Color(red: 32/255, green: 32/255, blue: 33/255))
                  .frame(height: 50)
                  .shadow(radius: 15)
                if #available(watchOS 10, *) {
                  Capsule()
                    .strokeBorder(Color.primary, style: StrokeStyle(lineWidth: 2))
                    .frame(height: 50)
                }
                //TODO: Smaller version
                Group {
                  if tipboxSymbol.isEmpty {
                    Text(tipboxText)
                      .multilineTextAlignment(.center)
                      .lineLimit(1)
                      .offset(y: offset-25)
                  } else {
                    HStack {
                      Spacer()
                      Image(systemName: tipboxSymbol)
                      Text(tipboxText)
                      Spacer()
                    }
                    //                  Label(tipboxText, systemImage: tipboxSymbol)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .offset(y: offset-25)
                  }
                }
                //              .focused($isTipBoxDisplaying)
              }
              .accessibilityHidden(!isTipBoxDisplaying)
              Spacer()
            }
          }
          .padding()
          .offset(y: offset)
          //                    .opacity(opacityEaseInOut)
          .animation(.easeInOut(duration: tipAnimations[tipAnimationSpeed]), value: offset)
          .onTapGesture {
            if tipConfirmRequired {
              nIsTipBoxDisplaying = false
              isTipBoxDisplaying = false
            }
          }
          .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
              DispatchQueue.main.async {
                tipboxText = nTipboxText
                tipboxSymbol = nTipboxSymbol
                isTipBoxDisplaying = nIsTipBoxDisplaying
                //Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
                //  tipBoxOffset = pTipBoxOffset
                //  timer.invalidate()
                //}
                if isTipBoxDisplaying {
                  offset = 25
                } else {
                  offset = 110
                }
              }
            }
          }
        }
        .onAppear {
          if (UserDefaults.standard.array(forKey: "tintColor") ?? []).isEmpty {
            UserDefaults.standard.set([275, 40, 100], forKey: "tintColor")
          }
          tintColorValues = UserDefaults.standard.array(forKey: "tintColor") ?? [275, 40, 100]
          tintColor = Color(hue: (tintColorValues[0] as! Double)/359, saturation: (tintColorValues[1] as! Double)/100, brightness: (tintColorValues[2] as! Double)/100)
        }
        //      .tint(tintColor)
        //      .accentColor(tintColor)
      }
      .fontDesign(globalFont[appFont])
    }
    .environment(\.locale, .init(identifier: appLanguage.isEmpty ? "\(languageCode!)-\(languageScript!)" : appLanguage))
  }
}

@MainActor public func showTip(_ text: LocalizedStringResource, symbol: String = "", time: Double = 2.0, debug: Bool = false) {
  @AppStorage("debug") var debugMode = false
  @AppStorage("tipConfirmRequired") var tipConfirmRequired = false
  if !debug || (debug && debugMode)  {
    nTipboxText = text
    nTipboxSymbol = symbol
    nIsTipBoxDisplaying = true
    if debug {
      print("[TIPBOX]\(text.key)")
    }
    
    if #available(watchOS 10.0, *) {
      var highPriorityAnnouncement: AttributedString {
        var highPriorityString = AttributedString(localized: text)
        highPriorityString.accessibilitySpeechAnnouncementPriority = .high
        return highPriorityString
      }
      AccessibilityNotification.Announcement(highPriorityAnnouncement)
        .post()
    }
  }
  if !tipConfirmRequired {
    Timer.scheduledTimer(withTimeInterval: time, repeats: false) { timer in
      DispatchQueue.main.async {
        nIsTipBoxDisplaying = false
      }
    }
  }
}

struct TabViews: View {
  @State var tabs: [(String, String)] = [("Iris://Home", "home")]
  @State var currentTab: Int?
  var body: some View {
    NavigationStack {
      List {
        ForEach(0..<tabs.count, id: \.self) { tab in
          NavigationLink(value: tab, label: {
            HStack {
              Image(systemName: tabs[tab].1)
              Text(tabs[tab].0)
              Spacer()
            }
            .padding()
          })
        }
      }
      .navigationDestination(for: Int?.self, destination: { tab in
        ContentView()
      })
    }
  }
}
