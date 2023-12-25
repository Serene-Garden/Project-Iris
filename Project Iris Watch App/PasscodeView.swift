//
//  PasscodeView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2023/10/21.
//

import SwiftUI

struct PasscodeView: View {
    @AppStorage("isPasscodeRequired") var isPasscodeRequired = false
    @AppStorage("passcode1") var passcode1 = 0
    @AppStorage("passcode2") var passcode2 = 0
    @AppStorage("passcode3") var passcode3 = 0
    @AppStorage("passcode4") var passcode4 = 0
    @State var inputCode1 = 0
    @State var inputCode2 = 0
    @State var inputCode3 = 0
    @State var inputCode4 = 0
    @State var isUnlocked = false
    var destination: Int
    var body: some View {
        if isPasscodeRequired && !isUnlocked {
            VStack {
                Text("Passcode.enter")
                    .bold()
                _PasscodeView(inputCode1: $inputCode1, inputCode2: $inputCode2, inputCode3: $inputCode3, inputCode4: $inputCode4)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        if verifyPasscode(input: "\(inputCode1)\(inputCode2)\(inputCode3)\(inputCode4)") {
                            isUnlocked = true
                        } else {
                            showTip("Passcode.incorrect", symbol: "lock")
                        }
                    } label: {
                        Label("Passcode.submit", systemImage: "checkmark")
                            .foregroundStyle(.primary)
                    }
                }
            }
        } else {
            if destination == 0 {
                HistoryView()
            }
        }
    }
}

struct PasscodeChangeView: View {
    @AppStorage("isPasscodeRequired") var isPasscodeRequired = false
    @AppStorage("passcode1") var passcode1 = 0
    @AppStorage("passcode2") var passcode2 = 0
    @AppStorage("passcode3") var passcode3 = 0
    @AppStorage("passcode4") var passcode4 = 0
    @State var newCode1 = 0
    @State var newCode2 = 0
    @State var newCode3 = 0
    @State var newCode4 = 0
    @State var inputCode1 = 0
    @State var inputCode2 = 0
    @State var inputCode3 = 0
    @State var inputCode4 = 0
    @State var step = 1
    @State var offset: CGFloat = 0
    var body: some View {
        VStack {
            ZStack {
                Text("Passcode.change.old")
                    .offset(x: offset)
                Text("Passcode.change.new")
                    .offset(x: offset+500)
                Text("Passcode.change.verify")
                    .offset(x: offset+1000)
                Text("Passcode.change.success")
                    .offset(x: offset+1500)
            }
            .bold()
            .animation(.easeInOut(duration: 0.5), value: offset)
            _PasscodeView(inputCode1: $inputCode1, inputCode2: $inputCode2, inputCode3: $inputCode3, inputCode4: $inputCode4)
                .disabled(step==4)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    if verifyPasscode(input: "\(inputCode1)\(inputCode2)\(inputCode3)\(inputCode4)") && step == 1 {
                        inputCode1 = 0
                        inputCode2 = 0
                        inputCode3 = 0
                        inputCode4 = 0
                        step = 2
                        offset = -500
                    } else if step == 2 {
                        newCode1 = inputCode1
                        newCode2 = inputCode2
                        newCode3 = inputCode3
                        newCode4 = inputCode4
                        inputCode1 = 0
                        inputCode2 = 0
                        inputCode3 = 0
                        inputCode4 = 0
                        step = 3
                        offset = -1000
                    } else if inputCode1 == newCode1 && inputCode2 == newCode2 && inputCode3 == newCode3 && inputCode4 == newCode4 && step == 3 {
                        passcode1 = newCode1
                        passcode2 = newCode2
                        passcode3 = newCode3
                        passcode4 = newCode4
                        step = 4
                        offset = -1500
                    } else {
                        if step == 3 {
                            showTip("Passcode.mismatch", symbol: "xmark")
                        } else {
                            showTip("Passcode.incorrect", symbol: "lock")
                        }
                    }
                } label: {
                    Label("Passcode.next-step", systemImage: "chevron.forward")
                }
            }
        }
    }
}

struct PasscodeCreateView: View {
    @AppStorage("isPasscodeRequired") var isPasscodeRequired = false
    @AppStorage("passcode1") var passcode1 = 0
    @AppStorage("passcode2") var passcode2 = 0
    @AppStorage("passcode3") var passcode3 = 0
    @AppStorage("passcode4") var passcode4 = 0
    @State var newCode1 = 0
    @State var newCode2 = 0
    @State var newCode3 = 0
    @State var newCode4 = 0
    @State var inputCode1 = 0
    @State var inputCode2 = 0
    @State var inputCode3 = 0
    @State var inputCode4 = 0
    @State var step = 1
    @State var offset: CGFloat = 0
    var body: some View {
        VStack {
            ZStack {
                Text("Passcode.create.new")
                    .offset(x: offset)
                Text("Passcode.create.verify")
                    .offset(x: offset+500)
                Text("Passcode.create.success")
                    .offset(x: offset+1000)
            }
            .bold()
            .animation(.easeInOut(duration: 0.5), value: offset)
            _PasscodeView(inputCode1: $inputCode1, inputCode2: $inputCode2, inputCode3: $inputCode3, inputCode4: $inputCode4)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    if step == 1 {
                        newCode1 = inputCode1
                        newCode2 = inputCode2
                        newCode3 = inputCode3
                        newCode4 = inputCode4
                        inputCode1 = 0
                        inputCode2 = 0
                        inputCode3 = 0
                        inputCode4 = 0
                        step = 2
                        offset = -500
                    } else if inputCode1 == newCode1 && inputCode2 == newCode2 && inputCode3 == newCode3 && inputCode4 == newCode4 && step == 2 {
                        passcode1 = newCode1
                        passcode2 = newCode2
                        passcode3 = newCode3
                        passcode4 = newCode4
                        step = 3
                        offset = -1000
                        isPasscodeRequired = true
                    } else {
                        showTip("Passcode.mismatch", symbol: "xmark")
                    }
                } label: {
                    Label("Passcode.next-step", systemImage: "chevron.forward")
                }
            }
        }
    }
}

struct PasscodeDeleteView: View {
    @AppStorage("isPasscodeRequired") var isPasscodeRequired = false
    @AppStorage("passcode1") var passcode1 = 0
    @AppStorage("passcode2") var passcode2 = 0
    @AppStorage("passcode3") var passcode3 = 0
    @AppStorage("passcode4") var passcode4 = 0
    @State var inputCode1 = 0
    @State var inputCode2 = 0
    @State var inputCode3 = 0
    @State var inputCode4 = 0
    @State var step = 1
    @State var offset: CGFloat = 0
    var body: some View {
        VStack {
            ZStack {
                Text("Passcode.delete.enter")
                    .offset(x: offset)
                Text("Passcode.delete.confirm")
                    .offset(x: offset+500)
                Text("Passcode.delete.success")
                    .offset(x: offset+1000)
            }
            .bold()
            .animation(.easeInOut(duration: 0.5), value: offset)
            _PasscodeView(inputCode1: $inputCode1, inputCode2: $inputCode2, inputCode3: $inputCode3, inputCode4: $inputCode4)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    if verifyPasscode(input: "\(inputCode1)\(inputCode2)\(inputCode3)\(inputCode4)") && step == 1 {
                        inputCode1 = 0
                        inputCode2 = 0
                        inputCode3 = 0
                        inputCode4 = 0
                        step = 2
                        offset = -500
                    } else if inputCode1 == 1 && inputCode2 == 2 && inputCode3 == 3 && inputCode4 == 4 && step == 2 {
                        step = 3
                        isPasscodeRequired = false
                        offset = -1000
                    } else {
                        if step == 2 {
                            showTip("Passcode.mismatch", symbol: "xmark")
                        } else {
                            showTip("Passcode.incorrect", symbol: "lock")
                        }
                    }
                } label: {
                    Label("Passcode.next-step", systemImage: "chevron.forward")
                }
            }
        }
    }
}

private func verifyPasscode(input inp: String) -> {
    var storedPasscode = ""
    for i in 1...4 {
        storedPasscode += String(UserDefaults.standard.int(forKey: "passcode\(i)"))
    }
    return storedPasscode == inp
}

fileprivate struct _PasscodeView: View {
    @Binding var inputCode1: Int
    @Binding var inputCode2: Int
    @Binding var inputCode3: Int
    @Binding var inputCode4: Int
    var body: some View {
        HStack {
            Picker("Passcode.digit.1", selection: $inputCode1) {
                Text("0").tag(0)
                Text("1").tag(1)
                Text("2").tag(2)
                Text("3").tag(3)
                Text("4").tag(4)
                Text("5").tag(5)
                Text("6").tag(6)
                Text("7").tag(7)
                Text("8").tag(8)
                Text("9").tag(9)
            }
            Picker("Passcode.digit.2", selection: $inputCode2) {
                Text("0").tag(0)
                Text("1").tag(1)
                Text("2").tag(2)
                Text("3").tag(3)
                Text("4").tag(4)
                Text("5").tag(5)
                Text("6").tag(6)
                Text("7").tag(7)
                Text("8").tag(8)
                Text("9").tag(9)
            }
            Picker("Passcode.digit.3", selection: $inputCode3) {
                Text("0").tag(0)
                Text("1").tag(1)
                Text("2").tag(2)
                Text("3").tag(3)
                Text("4").tag(4)
                Text("5").tag(5)
                Text("6").tag(6)
                Text("7").tag(7)
                Text("8").tag(8)
                Text("9").tag(9)
            }
            Picker("Passcode.digit.4", selection: $inputCode4) {
                Text("0").tag(0)
                Text("1").tag(1)
                Text("2").tag(2)
                Text("3").tag(3)
                Text("4").tag(4)
                Text("5").tag(5)
                Text("6").tag(6)
                Text("7").tag(7)
                Text("8").tag(8)
                Text("9").tag(9)
            }
        }
        .bold()
        .labelsHidden()
    }
}
