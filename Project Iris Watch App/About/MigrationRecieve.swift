//
//  MigrationRecieve.swift
//  Project Iris
//
//  Created by ThreeManager785 on 11/23/24.
//

import SwiftUI

//struct MigrationRecieveView: View {
//  @State var recievingPackage = false
//  @State var readablePasskey = ""
////  @State var passkey = ""
//  var body: some View {
//    ZStack {
//      MigrationRecievePrepareView(recievingPackage: $recievingPackage, passkey: $readablePasskey)
//        .opacity(recievingPackage ? 0 : 1)
////        .focusable(!finishedPackaging)
//      MigrationRecieveConfirmView(readablePasskey: readablePasskey, recievingPackage: $recievingPackage)
//        .opacity(recievingPackage ? 1 : 0)
//    }
//    .animation(.easeInOut(duration: 0.3), value: recievingPackage)
//    .navigationTitle(recievingPackage ? "Migration.recieve.confirm" : "Migration.recieve.abbr")
////    .onChange(of: readablePasskey, perform: { value in
////      passkey = readablePasskey.replacingOccurrences(of: " ", with: "").lowercased()
////    })
//  }
//}

struct MigrationRecieveView: View {
//  @State var recievingPackage: Bool
  @State var passkey: String = ""
  var body: some View {
    NavigationStack {
      List {
          //      Section {
        VStack {
          Image(systemName: "square.and.arrow.down")
            //            .foregroundStyle(.blue)
            .font(.title)
          Text("Migration.recieve")
            .bold()
            .font(.title3)
          Text("Migration.recieve.info")
            .font(.footnote)
            .multilineTextAlignment(.center)
        }
        .listRowBackground(Color.clear)
          //      }
          //      Section {
        TextField("Migration.recieve.key", text: $passkey)
          .textInputAutocapitalization(.never)
          .fontDesign(.monospaced)
        if passkey.count > 10 {
          Text(passkey)
            .fontDesign(.monospaced)
            .scaledToFit()
        }
        NavigationLink(destination: {
          MigrationRecieveConfirmView(readablePasskey: passkey)
        }, label: {
          Label("Migration.recieve.prepared", systemImage: "checkmark")
        })
        .disabled(passkey.isEmpty || passkey.split(separator: " ").count < 2)
          //      }
      }
      .navigationTitle("Migration.recieve.abbr")
    }
  }
}

struct MigrationRecieveConfirmView: View {
  var readablePasskey: String
  @State var packageState = -1
  @State var passkey = ""
  var body: some View {
    VStack {
      Image(systemName: "rectangle.and.pencil.and.ellipsis")
        .font(.title)
      HStack {
        Spacer()
        if packageState == -1 {
          ProgressView()
            .frame(width: 10, height: 10)
          Text("Migration.recieve.status.checking")
        } else if packageState >= 0 {
          Circle()
            .foregroundStyle(.green)
            .frame(width: 10)
          Text("Migration.recieve.status.ready")
        } else {
          Circle()
            .foregroundStyle(.red)
            .frame(width: 10)
          Text("Migration.recieve.status.failure")
        }
//        Text(readablePasskey.lowercased())
//          .bold()
//          .fontDesign(.monospaced)
          //          .font(.title3)
        Spacer()
      }
      .scaledToFit()
      .bold()
      .font(.title3)
    }
    .navigationTitle("Migration.recieve.confirm")
      //    .onChange(of: recievingPackage, perform: { value in
    .onAppear {
      passkey = readablePasskey.replacingOccurrences(of: " ", with: "").lowercased()
      
      if !passkey.isEmpty {
        readOnlineDocContent(onlineDocKeys[0]) { result in
          if result != nil && ((validateMigrationPackage(result!, encryption: getEncryptionStrings([passkey]))) != nil) {
            packageState = 0
          } else {
            readOnlineDocContent(onlineDocKeys[1]) { result1 in
              if result != nil && ((validateMigrationPackage(result1!, encryption: getEncryptionStrings([passkey]))) != nil) {
                packageState = 1
              } else {
                readOnlineDocContent(onlineDocKeys[0]) { result2 in
                  if result != nil && ((validateMigrationPackage(result2!, encryption: getEncryptionStrings([passkey]))) != nil) {
                    packageState = 2
                  } else {
                    packageState = -2
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
