//
//  SettingsDebug.swift
//  Project Iris
//
//  Created by ThreeManager785 on 10/3/24.
//

import Cepheus
import SwiftUI

let debugHistoryArray: [(String, Date, Int)] = [("Iris", Date.now, 20), ("https://apple.com/", Date.now.addingTimeInterval(-84000), 19), ("https://apple.com/apple-watch-series-10", Date.now.addingTimeInterval(-84005), 18), ("https://google.com", Date.now.addingTimeInterval(-168000), 17), ("https://microsoft.com", Date.now.addingTimeInterval(-168030), 16)]

struct DebugView: View {
  @AppStorage("debug") var debug = false
  @AppStorage("poemIsDiscovered") var poemIsDiscovered = false
  @AppStorage("userLatestVersion") var userLatestVersion = "0.0.0"
  @AppStorage("DismissAfterAction") var dismissAfterAction = true
  @AppStorage("lastMigrationTime") var lastMigrationTime = 0.0
  @AppStorage("lastMigrationCode") var lastMigrationCode = ""
  @AppStorage("lastMigrationSlot") var lastMigrationSlot = -1
  @State var newCarinaId: String = ""
  var body: some View {
    List {
      Section(content: {
        NavigationLink(destination: {
          StorageDataView()
        }, label: {
          Label(String("See All Values"), systemImage: "list.bullet")
        })
        Toggle(isOn: $debug, label: {
          Label(String("Enable Debug"), systemImage: "hammer")
        })
        NavigationLink(destination: {
          DebugMigrationView()
        }, label: {
          Label(String("View Migration Datas"), systemImage: "clock")
        })
      }, header: {
        Text(verbatim: "Variables")
      })
      
      Section(content: {
        TextField(String("User Latest Version"), text: $userLatestVersion)
      }, header: {
        Text(verbatim: "User Latest Version")
      })
      
      Section(content: {
        TextField(String("Carina ID"), text: $newCarinaId)
        Button(action: {
          var carinaFeedbacks = (UserDefaults.standard.array(forKey: "personalFeedbacks") ?? []) as! [Int]
          carinaFeedbacks.append(Int(newCarinaId) ?? 0)
          UserDefaults.standard.set(carinaFeedbacks, forKey: "personalFeedbacks")
          newCarinaId = ""
        }, label: {
          Label(String("Add to List"), systemImage: "plus")
        })
        NavigationLink(destination: {
          CarinaDetailView(id: newCarinaId)
        }, label: {
          Label(String("View"), systemImage: "exclamationmark.bubble")
        })
      }, header: {
        Text(verbatim: "Carina")
      })
      
      Section(content: {
        Button(action: {
          updateHistory(debugHistoryArray)
          UserDefaults.standard.set(20, forKey: "lastHistoryID")
//          showTip(String("History Setted"))
        }, label: {
          Label(String("Set History Data"), systemImage: "clock")
            .foregroundStyle(.red)
        })
        Button(action: {
          lastMigrationCode = ""
          lastMigrationSlot = -1
          lastMigrationTime = 0
        }, label: {
          Label(String("Clear Migration Cooldown"), systemImage: "paperplane")
//            .foregroundStyle(.red)
        })
      }, header: {
        Text(verbatim: "Set Storage")
      })
    }
    .navigationTitle("Debug")
  }
}

struct DebugMigrationView: View {
  @State var slot0 = ""
  @State var slot1 = ""
  @State var slot2 = ""
  @State var expand = false
  var body: some View {
    List {
      Toggle(isOn: $expand, label: {
        Text(verbatim: "Expand")
      })
      Button(action: {
        writeOnlineDocContent(onlineDocKeys[0], content: "free", completion: { value in
        })
      }, label: {
        Text(slot0)
          .lineLimit(expand ? nil : 3)
      })
      Button(action: {
        writeOnlineDocContent(onlineDocKeys[1], content: "free", completion: { value in
        })
      }, label: {
        Text(slot1)
          .lineLimit(expand ? nil : 3)
      })
      Button(action: {
        writeOnlineDocContent(onlineDocKeys[2], content: "free", completion: { value in
        })
      }, label: {
        Text(slot2)
          .lineLimit(expand ? nil : 3)
      })
    }
    .onAppear {
      readOnlineDocContent(onlineDocKeys[0], completion: { value in
        slot0 = value ?? "nil"
      })
      readOnlineDocContent(onlineDocKeys[1], completion: { value in
        slot1 = value ?? "nil"
      })
      readOnlineDocContent(onlineDocKeys[2], completion: { value in
        slot2 = value ?? "nil"
      })
    }
  }
}
