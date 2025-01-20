//
//  MigrationSend.swift
//  Project Iris
//
//  Created by ThreeManager785 on 11/23/24.
//

import SwiftUI

struct MigrationSendView: View {
  @State var preparingPackaging = false
  @State var passkey: [String] = []
  var body: some View {
    ZStack {
      MigrationSendPrepareView(passkey: passkey, finishedPackaging: $preparingPackaging)
        .opacity(preparingPackaging ? 0 : 1)
//        .focused($preparingPackaging)
      MigrationPackageView(passkey: $passkey)
        .opacity(preparingPackaging ? 1 : 0)
//        .focused($finishedPackaging)
    }
    .animation(.easeInOut(duration: 0.3), value: preparingPackaging)
    .onAppear {
      passkey = createRandomPasskey()
    }
    .navigationTitle(preparingPackaging ? "Migration.send.package.title" : "Migration.send")
  }
}

struct MigrationSendPrepareView: View {
  var passkey: [String]
  @Binding var finishedPackaging: Bool
  @State var serverState = -3
  @State var startPackaging = false
  
  @AppStorage("lastMigrationTime") var lastMigrationTime = 0.0
  @AppStorage("lastMigrationCode") var lastMigrationCode = ""
  @AppStorage("lastMigrationSlot") var lastMigrationSlot = -1
  
  let serverStateText: [Int: LocalizedStringResource] = [-3: "Migration.send.content.state.checking", -2: "Migration.send.content.state.unconnectable", -1: "Migration.send.content.state.busy", 0: "Migration.send.content.state.ready", 1: "Migration.send.content.state.ready", 2: "Migration.send.content.state.ready"]
  let serverStateColors: [Int: Color] = [-3: .secondary, -2: .red, -1: .orange, 0: .green, 1: .green, 2: .green]
  var body: some View {
    List {
      Section(content: {
        VStack {
          Image(systemName: "paperplane")
            //            .foregroundStyle(.blue)
            .font(.title)
          Text("Migration.send")
            .bold()
            .font(.title3)
          Text("Migration.send.info")
            .font(.footnote)
            .multilineTextAlignment(.center)
        }
        .listRowBackground(Color.clear)
        
        HStack {
          Text(serverStateText[serverState]!)
          Spacer()
          Circle()
            .foregroundStyle(serverStateColors[serverState] ?? Color.secondary)
            .frame(width: 10)
            .padding(.trailing, 7)
        }
        Button(action: {
          startPackaging = true
          checkNewMigrationAvailablility(completion: { value in
            serverState = value
            if serverState >= 0 {
//              var passkey = createRandomPasskey(8)
//              var passkeyString = ""
              writeOnlineDocContent(onlineDocKeys[serverState], content: createMigrationPackage(getEncryptionStrings(passkey)), completion: { value in
                if value {
                  lastMigrationCode = getReadableCode(passkey)
                  lastMigrationSlot = serverState
                  lastMigrationTime = Date.now.timeIntervalSince1970
                  
                  finishedPackaging = true
                  startPackaging = false
                } else {
                  startPackaging = false
                  showTip("Migration.send.content.failure")
                }
              })
            } else {
              startPackaging = false
            }
          })
        }, label: {
          HStack {
            Label(startPackaging ? "Migration.send.content.sending": "Migration.send.content.send", systemImage: "paperplane")
            Spacer()
            if startPackaging {
              ProgressView()
                .frame(width: 25)
            }
          }
        })
        .disabled(serverState < 0 || startPackaging || lastMigrationSlot != -1)
      }, footer: {
        if serverState < 0 && serverState > -3 {
          Text("Migration.send.content.try-later")
        } else {
          Text("Migration.send.content.exclude-passcode")
        }
      })
    }
    .onAppear {
      startPackaging = false
      finishedPackaging = false
      serverState = -3
      checkNewMigrationAvailablility(completion: { value in
        serverState = value
      })
    }
  }
}

struct MigrationPackageView: View {
  @Binding var passkey: [String]
  @State var readablePasskey = ""
  var body: some View {
    VStack {
      Image(systemName: "paperplane")
//        .bold()
        .font(.title)
      Text(readablePasskey)
        .bold()
//        .font(.system(size: 15))
        .scaledToFit()
        .multilineTextAlignment(.center)
        .fontDesign(.monospaced)
      Text("Migration.send.package.passkey.description")
        .foregroundStyle(.secondary)
        .font(.footnote)
        .multilineTextAlignment(.center)
    }
    .onChange(of: passkey, perform: { value in
      readablePasskey = getReadableCode(passkey)
    })
  }
}
