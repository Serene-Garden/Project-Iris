//
//  SettingsDebug.swift
//  Project Iris
//
//  Created by ThreeManager785 on 10/3/24.
//

import Cepheus
import SwiftUI

struct DebugView: View {
  @AppStorage("debug") var debug = false
  @AppStorage("poemIsDiscovered") var poemIsDiscovered = false
  @AppStorage("userLatestVersion") var userLatestVersion = "0.0.0"
  @AppStorage("DismissAfterAction") var dismissAfterAction = true
  @State var newCarinaId: String = ""
  var body: some View {
    List {
      NavigationLink(destination: {
        List {
          Text(getSettingsForAppdiagnose() ?? "Failed")
            .fontDesign(.monospaced)
        }
      }, label: {
        Label("Debug.get-all-values", systemImage: "list.bullet")
      })
      Toggle(isOn: $poemIsDiscovered, label: {
        Label("Debug.poem-is-discovered", systemImage: "sparkles")
      })
      Toggle(isOn: $debug, label: {
        Label("Debug.debug", systemImage: "hammer")
      })
      Toggle(isOn: $dismissAfterAction, label: {
        Label("Debug.dismissAfterAction", systemImage: "hammer")
      })
      CepheusKeyboard(input: $userLatestVersion, prompt: "userLatestVersion")
      NavigationLink(destination: {
        PasscodeInputView(destination: {Text(verbatim: "1")})
      }, label: {
        Text(verbatim: "PasscodeInputView")
      })
      CepheusKeyboard(input: $newCarinaId)
      Button(action: {
        var carinaFeedbacks = (UserDefaults.standard.array(forKey: "personalFeedbacks") ?? []) as! [Int]
        carinaFeedbacks.append(Int(newCarinaId) ?? 0)
        UserDefaults.standard.set(carinaFeedbacks, forKey: "personalFeedbacks")
        newCarinaId = ""
      }, label: {
        Label("Debug.carina.add", systemImage: "plus")
      })
      NavigationLink(destination: {
//        CarinaDetailView(carinaID: Int(newCarinaId) ?? 0)
      }, label: {
        Label("Debug.carina.view", systemImage: "exclamationmark.bubble")
      })
      Button(action: {
        showTip("Debug.debug")
      }, label: {
        Label(String("tip"), systemImage: "sparkles")
      })
    }
    .navigationTitle("Debug")
  }
}
