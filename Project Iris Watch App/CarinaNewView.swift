//
//  CarinaNewView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import SwiftUI
import Cepheus

let systemVersion = WKInterfaceDevice.current().systemVersion

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
  
  var body: some View {
    if sent {
      if CarinaID == -1 || CarinaID == -2 {
        VStack {
          Image(systemName: "circle.badge.exclamationmark")
            .font(.system(size: 50))
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
          Text("Carina.sent") + Text(" · ") + Text("#\(CarinaID)").monospaced()
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
        }, header: {
          Text("Carina.new.attachments")
        }, footer: {
          Text("Carina.new.attachments.description")
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
Settings：\(sendAllSettingsValue ? (settingsValues ?? "nil") : "toggled-off")
Sender：Iris
"""
    encodedPackage = package.data(using: .utf8)?.base64EncodedString() ?? ""
    fetchWebPageContent(urlString: "https://fapi.darock.top:65535/feedback/submit/anony/Project%20Iris/\(encodedPackage)") { result in
      switch result {
        case .success(let content):
          CarinaID = Int(content) ?? -1
        case .failure(let error):
          CarinaID = -2
      }
      sending = false
    }
    sent = true
  }
}

#Preview {
  CarinaNewView()
}
