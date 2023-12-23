//
//  HistoryView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2023/10/21.
//

import SwiftUI

struct HistoryView: View {
    @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
    var body: some View {
        NavigationSplitView {
            Text("History View")
        } detail: {
            Text("DETAIL")
        }
        .privacySensitive()
    }
}

#Preview {
    HistoryView()
}
