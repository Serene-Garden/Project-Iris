//
//  ViewCollectedStorageData.swift
//  Project Iris
//
//  Created by ThreeManager785 on 10/19/24.
//

import SwiftUI

struct StorageDataView: View {
  @State var storages: [String: Any] = [:]
  @State var storagesKeys: [String] = []
  @State var storagesValues: [String] = []
  
  let decoder = JSONDecoder()
  var body: some View {
    NavigationStack {
      List {
        if storagesKeys.count > 0 {
          ForEach(0..<storagesKeys.count, id: \.self) { keysIndex in
            Group {
              VStack(alignment: .leading) {
                Text(storagesKeys[keysIndex])
                  .font(.footnote)
                  .foregroundStyle(.secondary)
                Text(storagesValues[keysIndex])
                  .font(.caption)
              }
            }
          }
        } else {
          ProgressView()
        }
      }
    }
    .navigationTitle("Storage")
    .onAppear {
      storages = getStorageDictionary() ?? [:]
      for (key, value) in storages {
        storagesKeys.append(key)
        storagesValues.append("\(value)")
      }
    }
  }
}
