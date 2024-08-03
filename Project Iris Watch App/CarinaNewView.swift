//
//  CarinaNewView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import SwiftUI
import Cepheus

struct CarinaNewView: View {
  @State var personalFeedbacks: [Any] = []
  @State var type = 0
  @State var place = 3000
  @State var title = ""
  @State var content = ""
  @State var sent = false
  @State var CarinaID = 0
  @State var sending = false
  @State var package = """
"""
  @State var encodedPackage = ""
  @State var isAddedToList = false
  
  @State var typesPicker: [Int] = []
  @State var placesPicker: [Int] = []
  
  @State var settingsValues: String? = ""
  @State var sendAllSettingsValue = true
  @State var showSettingsDisablingAlert = false
  @State var showWhatsIncludedSheet = false
  @State var sendLocaleInformations = false
  @State var sendDeviceInformations = true
  @AppStorage("appLanguage") var appLanguage = ""
  
  @Environment(\.accessibilityEnabled) var accaccessibilityEnabled
  let languageCode = Locale.current.language.languageCode
  let countryCode = Locale.current.region!.identifier
  let watchSize = WKInterfaceDevice.current().screenBounds
  
  @State var selectedGroup = 0
  @State var selectedBookmark = 0
  @State var attachmentLinksPickingSheetIsDisplaying = false
  @State var attachmentLinks: [String] = []
  @State var attachmentCounts = 2
  @State var historyLink: String = ""
  @State var historyID: Int = -1
  var body: some View {
    if sent {
      if CarinaID == -1 || CarinaID == -2 {
        VStack {
          if #available(watchOS 10, *) {
            Image(systemName: "circle.badge.exclamationmark")
              .font(.system(size: 50))
          } else {
            Image(systemName: "bolt.horizontal")
              .font(.system(size: 50))
          }
          Text("Carina.failed")
          Group {
            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) + Text(" · ") + Text(CarinaID == -1 ? "Carina.failed.fetching" : "Carina.failed.connecting")
          }
          .foregroundStyle(.secondary)
          Button(action: {
            sendCarina()
          }, label: {
            if !sending {
              Label("Carina.failed.resend", systemImage: "arrow.clockwise")
            } else {
              ProgressView()
            }
          })
          .disabled(sending)
          .foregroundStyle(title.isEmpty && !sending ? Color.secondary : Color.primary)
        }
        .multilineTextAlignment(.center)
      } else if CarinaID == 0 {
        VStack {
          Image(systemName: "hourglass")
            .font(.system(size: 50))
          Text("Carina.sending")
          Group {
            Text(carinaTypes[type] ?? "Carina.type.other") + Text(" · ") + Text(carinaPlaces[place] ?? "Carina.place.other") + Text(" · ") + Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
          }
          .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
      } else {
        VStack {
          Image(systemName: "paperplane")
            .font(.system(size: 50))
          //.bold()
          Text("Carina.sent") + Text(" · ") + Text("#\(String(CarinaID))").monospaced()
          Group {
            Text(carinaTypes[type] ?? "Carina.type.other") + Text(" · ") + Text(carinaPlaces[place] ?? "Carina.place.other") + Text(" · ") + Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
          }
          .foregroundStyle(.secondary)
          .font(.caption)
          //.multilineTextAlignment(.center)
          NavigationLink(destination: {
            CarinaDetailView(carinaID: CarinaID)
          }, label: {
            Label("Carina.sent.view", systemImage: "doc.text.image")
          })
        }
        .multilineTextAlignment(.center)
        .onAppear {
          if !isAddedToList {
            personalFeedbacks.append(CarinaID)
            UserDefaults.standard.set(personalFeedbacks, forKey: "personalFeedbacks")
            isAddedToList = true
          }
        }
      }
    } else {
      List {
        Section("Carina.new.app") {
          Text("Project Iris \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
        }
        Section(content: {
          Picker("Carina.type", selection: $type) {
            ForEach(0..<typesPicker.count, id: \.self) { typeIndex in
              Text(carinaTypes[typesPicker[typeIndex]] ?? "Carina.type.other").tag(typesPicker[typeIndex])
            }
          }
          Picker("Carina.place", selection: $place) {
            ForEach(0..<placesPicker.count, id: \.self) { placeIndex in
              Text(carinaPlaces[placesPicker[placeIndex]] ?? "Carina.place.other").tag(placesPicker[placeIndex])
            }
          }
        }, header: {
          Text("Carina.new.basic-information")
        }, footer: {
          if type == 0 {
            Text("Carina.type.function.description")
          } else if type == 1 {
            Text("Carina.type.interface.description")
          } else if type == 2 {
            Text("Carina.type.texts.description")
          } else if type == 3 {
            Text("Carina.type.suggestions.description")
          }
        })
        Section("Carina.new.details") {
          CepheusKeyboard(input: $title, prompt: "Carina.new.title")
          CepheusKeyboard(input: $content, prompt: "Carina.new.content")
        }
        NavigationLink(destination: {
          List {
            Section(content: {
              Toggle(isOn: $sendAllSettingsValue, label: {
                Text("Carina.new.attachments.settings")
              })
              .onChange(of: sendAllSettingsValue, perform: { value in
                showSettingsDisablingAlert = !sendAllSettingsValue
              })
              .alert("Carina.new.attachments.settings.alert.title", isPresented: $showSettingsDisablingAlert, actions: {
                Button(role: .cancel, action: {
                  sendAllSettingsValue = true
                }, label: {
                  Text("Carina.new.attachments.settings.alert.cancel")
                })
                Button(role: .destructive, action: {
                  sendAllSettingsValue = false
                }, label: {
                  Text("Carina.new.attachments.settings.alert.confirm")
                })
                .foregroundStyle(.red)
              }, message: {
                Text("Carina.new.attachments.settings.alert.message")
              })
              Toggle(isOn: $sendDeviceInformations, label: {
                Text("Carina.new.attachments.device")
              })
              Toggle(isOn: $sendLocaleInformations, label: {
                Text("Carina.new.attachments.locale")
              })
            }, header: {
              Text("Carina.new.attachments.title")
            }, footer: {
              Text("Carina.new.attachments.description")
            })
            
            Section(content: {
              Button(action: {
                attachmentLinksPickingSheetIsDisplaying = true
              }, label: {
                Label("Carina.new.attachments.links.add", systemImage: "plus")
              })
              .sheet(isPresented: $attachmentLinksPickingSheetIsDisplaying, content: {
                NavigationStack {
                  List {
                    if #available(watchOS 10, *) {
                      NavigationLink(destination: {
                        BookmarkPickerView(editorSheetIsDisaplying: $attachmentLinksPickingSheetIsDisplaying, seletedGroup: $selectedGroup, selectedBookmark: $selectedBookmark, groupIndexEqualingGoal: selectedGroup, bookmarkIndexEqualingGoal: selectedBookmark, action: {
                          attachmentLinks.append(getBookmarkLibrary()[selectedGroup].3[selectedBookmark].3)
                        })
                        //
                      }, label: {
                        Label("Carina.new.attachments.links.add.bookmark", systemImage: "bookmark")
                      })
                    }
                    NavigationLink(destination: {
                      HistoryPickerView(pickerSheetIsDisplaying: $attachmentLinksPickingSheetIsDisplaying, historyLink: $historyLink, historyID: $historyID, acceptNonLinkHistory: false, action: {
                        attachmentLinks.append(historyLink)
                      })
                    }, label: {
                      Label("Carina.new.attachments.links.add.history", systemImage: "clock")
                    })
                  }
                  .navigationTitle("Carina.new.attachments.links.add")
                }
              })
              if !attachmentLinks.isEmpty {
                ForEach(0..<attachmentLinks.count, id: \.self) { attachmentIndex in
                  Text(attachmentLinks[attachmentIndex])
                }
                .onDelete(perform: { index in
                  attachmentLinks.remove(atOffsets: index)
                })
              }
            }, header: {
              Text("Carina.new.attachments.links.header")
            }, footer: {
              Text("Carina.new.attachments.links.footer")
            })
            Section {
              Button(action: {
                showWhatsIncludedSheet = true
              }, label: {
                Text("Carina.new.attachments.items")
              })
              .sheet(isPresented: $showWhatsIncludedSheet, content: {
                CarinaAttachmentItemsView(sendSettingsValues: sendAllSettingsValue, sendDeviceInformations: sendDeviceInformations, sendLocaleInformations: sendLocaleInformations)
              })
            }
          }
          .navigationTitle("Carina.new.attachments")
          .onDisappear {
            attachmentCounts = (sendAllSettingsValue ? 1 : 0) + (sendDeviceInformations ? 1 : 0) + (sendLocaleInformations ? 1 : 0) + attachmentLinks.count
          }
        }, label: {
          HStack {
            Image(systemName: "paperclip")
            Text("Carina.new.attachments")
            Spacer()
            Text("\(attachmentCounts)")
              .foregroundStyle(.secondary)
            Image(systemName: "chevron.forward")
              .foregroundStyle(.secondary)
          }
        })
        Button(action: {
          sendCarina()
        }, label: {
          if sending {
            HStack {
              ProgressView()
              Text("Carina.new.sending")
              Spacer()
            }
          } else {
            Label("Carina.new.send", systemImage: "paperplane")
          }
        })
        .disabled(title.isEmpty && !sending)
        .foregroundStyle(title.isEmpty && !sending ? Color.secondary : Color.primary)
      }
      .navigationTitle("Carina.new")
      .onAppear {
        settingsValues = getSettingsForAppdiagnose { data in
          data.removeValue(forKey: "correctPasscode")
        }
        personalFeedbacks = UserDefaults.standard.array(forKey: "personalFeedbacks") ?? []
        isAddedToList = false
        
        typesPicker = []
        placesPicker = []
        for (key, value) in carinaTypes {
          typesPicker.append(key)
        }
        for (key, value) in carinaPlaces {
          placesPicker.append(key)
        }
        typesPicker.sort()
        placesPicker.sort()
      }
    }
  }
  func sendCarina() {
    sending = true
    CarinaID = 0
    package = """
\(title)
CarinaType：\(type)
IrisPlace：\(place)
State：0
Body：\(content.isEmpty ? "none" : content)
Version：\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
CarinaTime：\(Date().timeIntervalSince1970)
OS：\(systemVersion)
AccessibilityEnabled：\(accaccessibilityEnabled)
Sender：Iris
"""
    if sendAllSettingsValue {
      package.append("""

Settings：\(settingsValues ?? "nil")
""")
    }
    if sendDeviceInformations {
      package.append("""

DeviceSize：\(watchSize)
AccessibilityIsEnabled：\(accaccessibilityEnabled)
""")
    }
    if sendLocaleInformations {
      package.append("""

Language：\(languageCode!)
Region：\(countryCode)
ModifiedLanguage：\(appLanguage.isEmpty ? "default" : appLanguage)
""")
    }
    if !attachmentLinks.isEmpty {
      package.append("""

AttachedLinks：\(attachmentLinks)
""")
    }
    encodedPackage = (package.data(using: .utf8)?.base64EncodedString() ?? "").replacingOccurrences(of: "/", with: "{slash}")
    fetchWebPageContent(urlString: "https://fapi.darock.top:65535/feedback/submit/anony/Project Iris/\(encodedPackage)") { result in
      switch result {
        case .success(let content):
          CarinaID = Int(content) ?? -1
          sending = false
          sent = true
        case .failure(let error):
          CarinaID = -2
          sending = false
          sent = true
      }
    }
  }
}

struct CarinaAttachmentItemsView: View {
  var sendSettingsValues: Bool
  var sendDeviceInformations: Bool
  var sendLocaleInformations: Bool
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
          Section(content: {
            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.basic.form", image: "doc.text.image")
            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.basic.time", image: "clock")
            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.basic.watchos-version", image: "applewatch.side.right")
            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.basic.app-version", image: "app.badge")
            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.device.atttached-link", image: "link")
          }, header: {
            Text("Carina.new.attachments.items.basic")
              .bold()
          })
        Spacer()
          .frame(height: 20)
        Group {
          Section(content: {
            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.settings.passcode", image: "lock", send: false)
            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.settings.bookmark", image: "bookmark", send: false)
            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.settings.history", image: "clock.arrow.circlepath", send: false)
            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.settings.values", image: "gear", send: sendSettingsValues)
          }, header: {
            Text("Carina.new.attachments.items.settings")
              .bold()
          })
        }
        Spacer()
          .frame(height: 20)
        Group {
          Section(content: {
            if #available(watchOS 11, *) {
              CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.device.watch-size", image: "applewatch.case.sizes", send: sendDeviceInformations)
            } else {
              CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.device.watch-size", image: "applewatch.watchface", send: sendDeviceInformations)
            }
            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.device.accessibility", image: "accessibility", send: sendDeviceInformations)
          }, header: {
            Text("Carina.new.attachments.items.device")
              .bold()
          })
        }
        Spacer()
          .frame(height: 20)
        Group {
          Section(content: {
            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.locale.language", image: "globe", send: sendLocaleInformations)
            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.locale.region", image: "globe.asia.australia", send: sendLocaleInformations)
            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.locale.edited-language", image: "globe.desk", send: sendLocaleInformations)
//            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.locale.time-zone", image: "calendar.badge.clock", send: false)
//            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.locale.currency", image: "dollarsign.circle", send: false)
//            CarinaAttachmentSingleItemView(text: "Carina.new.attachments.items.locale.measurement-system", image: "ruler", send: false)
          }, header: {
            Text("Carina.new.attachments.items.locale")
              .bold()
          })
        }
      }
    }
    .navigationTitle("Carina.new.attachments.items")
  }
}

struct CarinaAttachmentSingleItemView: View {
  var text: LocalizedStringResource
  var image: String
  var send: Bool = true
  var body: some View {
    HStack {
      Image(systemName: image)
      Text(text)
      Spacer()
      Image(systemName: send ? "checkmark" : "xmark")
        .foregroundStyle(send ? .green : .secondary)
    }
    .font(.footnote)
    .padding(.bottom, 1)
  }
}


#Preview {
  CarinaAttachmentItemsView(sendSettingsValues: true, sendDeviceInformations: true, sendLocaleInformations: true)
}
