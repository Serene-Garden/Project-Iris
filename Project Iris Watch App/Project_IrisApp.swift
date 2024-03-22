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

import SwiftUI

public let isOpenSource = true
//Modification to this constant value can lead to accidental fatal error.

let languageCode = Locale.current.language.languageCode

var pShowTipText = ""
var pShowTipSymbol = ""
var nTipboxText: LocalizedStringKey = ""
var nTipboxSymbol = ""
var pTipBoxOffset: CGFloat = 80
var nIsTipBoxDisplaying = false
var isShowMemoryInScreen = false


@main
struct Project_Iris_Watch_AppApp: App {
    @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
    @AppStorage("tipConfirmRequired") var tipConfirmRequired = false
    @AppStorage("tipAnimationSpeed") var tipAnimationSpeed = 1
    @State var showTipText = ""
    @State var showTipSymbol = ""
    @State var tipboxText: LocalizedStringKey = ""
    @State var tipboxSymbol = ""
    @State var tipBoxOffset: CGFloat = 80
    @State var isTipBoxDisplaying = false
    @State var offset: CGFloat = 110
    let tipAnimations = [0.2, 0.35, 0.65, 1]
    var body: some Scene {
        WindowGroup {
            ZStack {
                if #available(watchOS 10.0, *) {
                ContentView()
                    .privacySensitive(isPrivateModeOn)
                    .containerBackground(Color(red: 166/255, green: 132/255, blue: 234/255).gradient, for: .navigation)
                } else {
                    ContentView()
                        .privacySensitive(isPrivateModeOn)
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
                            Capsule()
                                .strokeBorder(Color.primary, style: StrokeStyle(lineWidth: 2))
                                .frame(height: 50)
                            if tipboxSymbol.isEmpty {
                                Text(tipboxText)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .offset(y: offset-25)
                            } else {
                                Label(tipboxText, systemImage: tipboxSymbol)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .offset(y: offset-25)
                            }
                        }
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
                    Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
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
                // .environment(\.locale, .init(identifier: "zh_CN"))
            }
        }
    }
}

public func showTip(_ text: LocalizedStringKey, symbol: String = "", time: Double = 2.0) {
    @AppStorage("tipConfirmRequired") var tipConfirmRequired = false
    nTipboxText = text
    nTipboxSymbol = symbol
    nIsTipBoxDisplaying = true
    if !tipConfirmRequired {
        Timer.scheduledTimer(withTimeInterval: time, repeats: false) { timer in
            nIsTipBoxDisplaying = false
        }
    }
}

