//
//  CorvusReportView.swift
//  Project Iris
//
//  Created by ThreeManager785 on 1/26/25.
//

import Cepheus
import CorvusKit
import SwiftUI

struct CorvusReportView: View {
  @State var corvusTranscribe = ""
  
  var body: some View {
    List {
      Text("Corvus.reason")
      
      Section(content: {
        Group {
          if "\(languageCode)".contains("zh") {
            Text(verbatim: "法律之前人人平等，并有权享受法律的平等保护，不受任何歧视。人人有权享受平等保护，以免受违反本宣言的任何歧视行为以及煽动这种歧视的任何行为之害。")
          } else {
            Text(verbatim: "All are equal before the law and are entitled without any discrimination to equal protection of the law. All are entitled to equal protection against any discrimination in violation of this Declaration and against any incitement to such discrimination.")
          }
        }
        .font(.caption)
        .italic()
        .fontDesign(.serif)
        CepheusKeyboard(input: $corvusTranscribe, prompt: "Corvus.transcrible.label", CepheusIsEnabled: true)
      }, header: {
        Text("Corvus.transcribe")
      }, footer: {
        Text("Corvus.transcribe.footer")
      })
      
      Section(content: {
        
      }, header: {
        
      })
    }
    .navigationTitle("Corvus.report")
    .onAppear {
      Task {
        do {
          let checker = COKChecker(caller: .garden)
          try await checker.checkAndApplyWatermark()
        } catch {
          print(error)
        }
      }
    }
  }
}
