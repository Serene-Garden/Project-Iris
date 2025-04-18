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

import CorvusKit
import SwiftUI
import UIKit
import RadarKitCore

public let languageCode = Locale.current.language.languageCode
public let countryCode = Locale.current.region!.identifier
public let watchSize = WKInterfaceDevice.current().screenBounds
public let systemVersion = WKInterfaceDevice.current().systemVersion
public let currentIrisVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
public let currentLocale = Locale.current

//UNNECESSARY
public let timeZone = Locale.current.timeZone!.identifier
public let currencyCode = Locale.current.currency!.identifier
public let measurementSystem = Locale.current.measurementSystem

public let defaultColor: [Double] = [275, 40, 100] //[140, 39, 100]

//@MainActor var pShowTipText = ""
//@MainActor var pShowTipSymbol = ""
//@MainActor var pTipBoxOffset: CGFloat = 80
@MainActor var nTipboxText: LocalizedStringResource = ""
@MainActor var nTipboxSymbol = ""
@MainActor var nIsTipBoxDisplaying = false
@MainActor var isShowMemoryInScreen = false

//@available(watchOS 10.0, *)
//extension AttributeScopes.AccessibilityAttributes.AnnouncementPriorityAttribute.AnnouncementPriority: @unchecked @retroactive Sendable {}
@MainActor public var webpageIsDisplaying = false
@MainActor public var webpageIsArchive = false
@MainActor public var webpageArchiveURL: String?
@MainActor public var webpageArchiveTitle: String?
@MainActor public var webpageContent: WKWebView = WKWebView()

@main
struct Project_Iris_Watch_AppApp: App {
  @WKApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @AppStorage("appFont") var appFont = 0
  @AppStorage("appLanguage") var appLanguage = ""
  @AppStorage("statsCollectionIsAllowed") var statsCollectionIsAllowed = true
  @AppStorage("irisStartedUpSuccessfully") var irisStartedUpSuccessfully = true
  @State var shouldWebpageDisplays = false
  @State var mainIrisIsDisplaying = false
  @State var crashErrorViewShouldDisplay = false
  @State var irisStartedUpLastTime = true
  let globalFont: [Font.Design?] = [nil, .rounded, .serif]
  var body: some Scene {
    WindowGroup {
      if mainIrisIsDisplaying {
        Group {
          ZStack {
            if #available(watchOS 10, *) {
              MainView()
                .typesettingLanguage(appLanguage.isEmpty ? currentLocale.language : .init(identifier: appLanguage), isEnabled: !appLanguage.isEmpty)
            } else {
              MainView()
            }
            DimmingView(isGlobal: true)
          }
        }
        //      .sheet
        .sheet(isPresented: $shouldWebpageDisplays, content: {
          SwiftWebView(webView: webpageContent)
        })
        .onAppear {
            Task {
              do {
                let checker = COKChecker(caller: .garden)
                try await checker.checkAndApplyWatermark(content: {
                  VStack {
                    ForEach(0..<20, id: \.self) { i in
                      HStack {
                        ForEach(0..<20, id: \.self) { i in
                          Text("Corvus.watermark")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .opacity(0.7)
                            .bold()
                            .lineLimit(1)
                        }
                      }
                    }
                  }
                  .ignoresSafeArea()
                  .frame(width: 1000000, height: 1000000)
                  .rotationEffect(Angle(degrees: -45))
                })
//                try await checker.checkAndApplyWatermark()
              } catch {
                print(error)
              }
            }
          
          if statsCollectionIsAllowed {
            fetchWebPageContent(urlString: "https://fapi.darock.top:65535/analyze/add/garden_iris_login/\(Date.now.timeIntervalSince1970)") { result in}
          }
          Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            shouldWebpageDisplays = webpageIsDisplaying
          }
        }
        .fontDesign(globalFont[appFont])
        //      .brightness(-0.1)
      } else {
        if crashErrorViewShouldDisplay {
          CrashView(showIris: $mainIrisIsDisplaying)
        } else {
          ProgressView()
            .onAppear {
              irisStartedUpLastTime = irisStartedUpSuccessfully
              irisStartedUpSuccessfully = false
              if irisStartedUpLastTime {
                mainIrisIsDisplaying = true
              } else {
                crashErrorViewShouldDisplay = true
              }
            }
        }
      }
    }
    .environment(\.locale, appLanguage.isEmpty ? currentLocale : .init(identifier: appLanguage))
//    .environment(\.locale, .init(identifier: appLanguage.isEmpty ? "\(languageCode!)-\(languageScript ?? "")" : appLanguage))
  }
}

struct CrashView: View {
  @Binding var showIris: Bool
  @AppStorage("lastCrashReportTime") var lastCrashReportTime = ""
  @State var lastCrashReportDate: Date = Date.now
  @State var timeInterval = 0.0
  @State var reportSending = false
  @State var reportSentSucceed = false
  @State var reportSentFailed = false
  var dateFormatter = DateFormatter()
  var projectManager = RKCFeedbackManager(projectName: "Project Iris")
  var body: some View {
    NavigationStack {
      List {
        Text("Crash.title")
          .bold()
        Text("Crash.content")
        NavigationLink(destination: {
          StorageDataView()
        }, label: {
          HStack {
            Label("Crash.check-storage", systemImage: "externaldrive")
            Spacer()
            Image(systemName: "chevron.forward")
              .foregroundStyle(.secondary)
          }
        })
        Button(action: {
          Task {
            do {
              var replyData: NewFeedbackData = try .init(title: "[Iris]IrisCrash", content: "", sender: "Iris Crash Reporter \(currentIrisVersion)", additionalData: .rawString("""
OS：\(systemVersion)
Version：\(currentIrisVersion)
\(generateAttachmentDatas(sendDeviceInfos: true, sendSettingsValues: true, sendRegionInfos: true, sendBookmarkFiles: true, sendHistoryFiles: true, attachedLinks: []))
"""))
              await reportSentSucceed = (projectManager.newFeedback(replyData) != nil)
              if reportSentSucceed {
                lastCrashReportTime = dateFormatter.string(from: Date.now)
              } else {
                reportSentFailed = true
              }
            } catch {
              print(error)
            }
          }
        }, label: {
          if reportSentSucceed {
            HStack {
              Label("Crash.report.succeed", systemImage: "exclamationmark.bubble")
              Spacer()
              Image(systemName: "checkmark")
                .foregroundStyle(.secondary)
            }
          } else if reportSentFailed {
            HStack {
              Label("Crash.report.failed", systemImage: "exclamationmark.bubble")
              Spacer()
              if reportSending {
                ProgressView()
                  .frame(width: 25)
              }
            }
          } else if timeInterval <= 300 {
            HStack {
              Label("Crash.report.too-quick", systemImage: "exclamationmark.bubble")
              Spacer()
            }
          } else {
            HStack {
              Label("Crash.report", systemImage: "exclamationmark.bubble")
              Spacer()
              if reportSending {
                ProgressView()
                  .frame(width: 25)
              }
            }
          }
        })
        .disabled(reportSentSucceed || reportSending || timeInterval <= 300)
        Button(action: {
          showIris = true
        }, label: {
          HStack {
            Label("Crash.restart", systemImage: "restart")
            Spacer()
          }
        })
      }
      .onAppear {
        lastCrashReportDate = dateFormatter.date(from: lastCrashReportTime) ?? Date()
        timeInterval = Date.now.timeIntervalSince(lastCrashReportDate)
      }
      .navigationTitle("Crash")
    }
  }
}

struct MainView: View {
  @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
  @AppStorage("tipConfirmRequired") var tipConfirmRequired = false
  @AppStorage("tipAnimationSpeed") var tipAnimationSpeed = 1
  @AppStorage("appFont") var appFont = 0
  @AppStorage("appLanguage") var appLanguage = ""
  @AppStorage("AppearanceSchedule") var appearanceSchedule = 0
  @State var showTipText = ""
  @State var showTipSymbol = ""
  @State var tipboxText: LocalizedStringResource = ""
  @State var tipboxSymbol = ""
  @State var tipBoxOffset: CGFloat = 80
  @State var isTipBoxDisplaying = false
  @State var offset: CGFloat = 110
  @State var tintColorValues: [Any] = defaultColor as [Any]
  @State var tintColor = Color(hue: defaultColor[0]/359, saturation: defaultColor[1]/100, brightness: defaultColor[2]/100)
  let tipAnimations = [0.2, 0.35, 0.65, 1]
  var body: some View {
    Group {
      ZStack {
        if #available(watchOS 10.0, *) {
          ContentView()
//            .privacySensitive(isPrivateModeOn)
            .containerBackground(tintColor.gradient, for: .navigation)
        } else {
          ContentView()
//            .privacySensitive(isPrivateModeOn)
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
          if appearanceSchedule == 3 {
            updateDimTimeWithSolarTimes()
          }
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
          UserDefaults.standard.set(defaultColor, forKey: "tintColor")
        }
        tintColorValues = UserDefaults.standard.array(forKey: "tintColor") ?? defaultColor
        tintColor = Color(hue: (tintColorValues[0] as! Double)/359, saturation: (tintColorValues[1] as! Double)/100, brightness: (tintColorValues[2] as! Double)/100)
        if readPlainTextFile("DimTime.txt").isEmpty {
          writePlainTextFile("21:00,6:00", to: "DimTime.txt")
        }
      }
      //      .tint(tintColor)
      //      .accentColor(tintColor)
    }
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

class AppDelegate: NSObject, WKApplicationDelegate {
  // 此代理方法在用户同意通知权限后调用
  func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
    let tokenString = deviceToken.hexEncodedString() // 见下方对 Data 的 Extension
    UserDefaults.standard.set(tokenString, forKey: "UserNotificationToken")
  }
}

extension Data {
  struct HexEncodingOptions: OptionSet {
    let rawValue: Int
    static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
  }
  
  func hexEncodedString(options: HexEncodingOptions = []) -> String {
    let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
    return self.map { String(format: format, $0) }.joined()
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
