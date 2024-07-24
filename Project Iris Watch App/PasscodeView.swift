//
//  PasscodeView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2023/10/21.
//

import SwiftUI
import AVFoundation

struct PasscodeView<L: View>: View {
  var destination: () -> L
  var title: LocalizedStringKey = "Passcode.title.access.settings"
  @AppStorage("correctPasscode") var correctPasscode = ""
  var body: some View {
    Group {
      PasscodeInputView(destination: {destination()}, title: title)
    }
  }
}

struct PasscodeSettingsView: View {
  @AppStorage("correctPasscode") var correctPasscode = ""
  @AppStorage("lockBookmarks") var lockBookmarks = false
  @AppStorage("lockHistory") var lockHistory = true
  var body: some View {
    NavigationStack {
      List {
        Section {
          if correctPasscode.isEmpty {
            NavigationLink(destination: {
              PasscodeAddView()
            }, label: {
              Label("Passcode.add", systemImage: "lock")
            })
          } else {
            NavigationLink(destination: {
              PasscodeChangeView()
            }, label: {
              Label("Passcode.change", systemImage: "lock")
            })
            NavigationLink(destination: {
              PasscodeRemoveView()
            }, label: {
              Label("Passcode.remove", systemImage: "lock.slash")
                .foregroundStyle(.red)
            })
          }
        }
        Section("Passcode.content") {
          Toggle(isOn: $lockBookmarks, label: {
            Label("Passcode.content.bookmarks", systemImage: "bookmark")
          })
          Toggle(isOn: $lockHistory, label: {
            Label("Passcode.content.history", systemImage: "clock")
          })
        }
        .disabled(correctPasscode.isEmpty)
      }
    }
    .navigationTitle("Passcode")
  }
}

struct PasscodeAddView: View {
  @AppStorage("correctPasscode") var correctPasscode = ""
  @State var newPasscode: String = ""
  var body: some View {
    PasscodeInputView(destination: {
      PasscodeInputView(destination: {
        VStack {
          Image(systemName: "lock")
            .font(.system(size: 50))
          Text("Passcode.add.success")
            .multilineTextAlignment(.center)
        }
        .onAppear {
          correctPasscode = newPasscode
        }
      }, expectedNumber: newPasscode, title: "Passcode.add", prompt: "Passcode.add.second", lastEnteredDigits: newPasscode.count)
    }, expectedNumber: "any", title: "Passcode.add", prompt: "Passcode.add.first", broadcastingPasscode: $newPasscode)
    .onChange(of: newPasscode, perform: { value in
      print(newPasscode)
    })
  }
}

struct PasscodeChangeView: View {
  @AppStorage("correctPasscode") var correctPasscode = ""
  @State var newPasscode: String = ""
  var body: some View {
    PasscodeInputView(destination: {
      PasscodeInputView(destination: {
        PasscodeInputView(destination: {
          VStack {
            Image(systemName: "lock")
              .font(.system(size: 50))
            Text("Passcode.change.success")
              .multilineTextAlignment(.center)
          }
          .onAppear {
            correctPasscode = newPasscode
          }
        }, expectedNumber: newPasscode, title: "Passcode.change", prompt: "Passcode.add.second", lastEnteredDigits: newPasscode.count)
      }, expectedNumber: "any", title: "Passcode.change", prompt: "Passcode.add.first", broadcastingPasscode: $newPasscode, lastEnteredDigits: correctPasscode.count)
      .onChange(of: newPasscode, perform: { value in
        print(newPasscode)
      })
    }, title: "Passcode.change", prompt: "Passcode.edit.old", hideUnlockTip: true)
  }
}

struct PasscodeRemoveView: View {
  @AppStorage("correctPasscode") var correctPasscode = ""
  var body: some View {
    PasscodeInputView(destination: {
      PasscodeInputView(destination: {
        VStack {
          Image(systemName: "lock.open")
            .font(.system(size: 50))
          Text("Passcode.remove.success")
            .multilineTextAlignment(.center)
        }
        .onAppear {
          correctPasscode = ""
        }
      }, expectedNumber: "1234", title: "Passcode.remove", prompt: "Passcode.remove.confirm")
    }, title: "Passcode.remove", lastEnteredDigits: correctPasscode.count, hideUnlockTip: true)
  }
}


struct PasscodeInputView<L: View>: View {
  var destination: () -> L
  var expectedNumber = "def"
  var title: LocalizedStringKey = "Passcode"
  var prompt: LocalizedStringKey = "Passcode.enter"
  var broadcastingPasscode: Binding<String>?
  var lastEnteredDigits = 0
  var hideUnlockTip = false
  @AppStorage("correctPasscode") var correctPasscode = ""
  @State var isCorrect: Bool = false
  @State var enteredPasscode: String = ""
  @State var showLastDigit = false
  @State var delete = false
  @State var offset: CGFloat = 500
  @State var timer: Timer? = Timer()
  //  @State var rotation1: Double = 0.0
  let player = AVPlayer(url: Bundle.main.url(forResource: "unlockTip", withExtension: "wav")!)
  var body: some View {
    Group {
      if isCorrect {
        destination()
      } else {
        VStack {
          HStack {
            Text(title)
              .font(.caption)
              .fontWeight(.medium)
              .padding(.top, 12)
            Spacer()
          }
          .padding(.leading, 7)
          Spacer()
            .frame(height: 10)
          ZStack {
            Text(dotsByInt(lastEnteredDigits))
              .offset(x: offset - 500)
            Group {
              if enteredPasscode.isEmpty {
                Text(prompt)
                  .multilineTextAlignment(.center)
                //          .fontDesign(.monospaced)
              } else {
                if showLastDigit {
//                  print(LocalizedStringKey(""))
                  Text(dots(enteredPasscode, showLastDigit: showLastDigit)) + Text(String(enteredPasscode.last!)).fontDesign(.monospaced)
                } else {
                  Text(dots(enteredPasscode, showLastDigit: false))
                }
              }
            }
            .flipsForRightToLeftLayoutDirection(false)
            .offset(x: offset)
          }
          Grid {
            GridRow {
              Button(action: {
                enteredPasscode.append("1")
              }, label: {
                Text(verbatim: "1")
              })
              .buttonStyle(DigitStyle(scaleAnchor: .topLeading))
              
              Button(action: {
                enteredPasscode.append("2")
              }, label: {
                Text(verbatim: "2")
              })
              .buttonStyle(DigitStyle(scaleAnchor: .top))
              
              Button(action: {
                enteredPasscode.append("3")
              }, label: {
                Text(verbatim: "3")
              })
              .buttonStyle(DigitStyle(scaleAnchor: .topTrailing))
            }
            .disabled(enteredPasscode.count >= 10)
            .foregroundStyle(enteredPasscode.count >= 10 ? .secondary : .primary)
            .flipsForRightToLeftLayoutDirection(false)
            GridRow {
              Button(action: {
                enteredPasscode.append("4")
              }, label: {
                Text(verbatim: "4")
              })
              .buttonStyle(DigitStyle(scaleAnchor: .leading))
              
              Button(action: {
                enteredPasscode.append("5")
              }, label: {
                Text(verbatim: "5")
              })
              .buttonStyle(DigitStyle(scaleAnchor: .center))
              
              Button(action: {
                enteredPasscode.append("6")
              }, label: {
                Text(verbatim: "6")
              })
              .buttonStyle(DigitStyle(scaleAnchor: .trailing))
            }
            .disabled(enteredPasscode.count >= 10)
            .foregroundStyle(enteredPasscode.count >= 10 ? .secondary : .primary)
            .flipsForRightToLeftLayoutDirection(false)
            GridRow {
              Button(action: {
                enteredPasscode.append("7")
              }, label: {
                Text(verbatim: "7")
              })
              .buttonStyle(DigitStyle(scaleAnchor: .leading))
              
              Button(action: {
                enteredPasscode.append("8")
              }, label: {
                Text(verbatim: "8")
              })
              .buttonStyle(DigitStyle(scaleAnchor: .center))
              
              Button(action: {
                enteredPasscode.append("9")
              }, label: {
                Text(verbatim: "9")
              })
              .buttonStyle(DigitStyle(scaleAnchor: .trailing))
            }
            .disabled(enteredPasscode.count >= 10)
            .foregroundStyle(enteredPasscode.count >= 10 ? .secondary : .primary)
            .flipsForRightToLeftLayoutDirection(false)
            GridRow {
              if enteredPasscode.isEmpty {
                DismissButton(action: {}, label: {
                  Image(systemName: "chevron.backward")
                })
                .buttonStyle(DigitStyle(scaleAnchor: .bottomLeading, removeBackground: true))
              } else {
                Button(action: {
                  if !enteredPasscode.isEmpty {
                    enteredPasscode.removeLast()
                    delete = true
                  }
                }, label: {
                  Image(systemName: "delete.left")
                })
                .buttonStyle(DigitStyle(scaleAnchor: .bottomLeading, removeBackground: true))
              }
              
              Button(action: {
                enteredPasscode.append("0")
              }, label: {
                Text(verbatim: "0")
              })
              .buttonStyle(DigitStyle(scaleAnchor: .bottom))
              .disabled(enteredPasscode.count >= 10)
              .foregroundStyle(enteredPasscode.count >= 10 ? .secondary : .primary)
              
              Button(action: {
                if passcodeIsCorrect(enteredPasscode, correctPasscode: correctPasscode, expectedNumber: expectedNumber) {
                  //MARK: PASS
                  isCorrect = true
                  if expectedNumber == "def" && !hideUnlockTip {
                    player.play()
                  }
                } else {
                  //MARK: FAILURE
                  isCorrect = false
                  enteredPasscode = ""
                  WKInterfaceDevice().play(.retry)
                }
              }, label: {
                Image(systemName: "checkmark")
              })
              .buttonStyle(DigitStyle(scaleAnchor: .bottomTrailing, removeBackground: true))
              .disabled(enteredPasscode.isEmpty)
              .foregroundStyle(enteredPasscode.isEmpty ? .secondary : .primary)
            }
          }
          .onChange(of: enteredPasscode, perform: { value in
            if broadcastingPasscode != nil {
              broadcastingPasscode!.wrappedValue = enteredPasscode
            }
            if !delete {
              showLastDigit = true
            } else {
              delete = false
            }
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
              showLastDigit = false
            }
          })
        }
        .ignoresSafeArea(.all, edges: .top)
        .ignoresSafeArea(.all, edges: .bottom)
        .navigationBarBackButtonHidden()
        .flipsForRightToLeftLayoutDirection(false)
      }
    }
    .onAppear {
      if lastEnteredDigits == 0 {
        offset = 0
      } else {
        withAnimation(.easeInOut(duration: 0.5)) {
          offset = 0
        }
      }
      if expectedNumber == "def" && correctPasscode.isEmpty {
        isCorrect = true
      }
    }
  }
}


struct DigitStyle: ButtonStyle {
  var scaleAnchor: UnitPoint = .center
  var removeBackground: Bool = false
  func makeBody(configuration: Configuration) -> some View {
    if #available(watchOS 10, *) {
      ZStack {
        if !removeBackground {
          RoundedRectangle(cornerRadius: 5, style: .continuous)
            .foregroundStyle(.tertiary)
            .scaleEffect(configuration.isPressed ? 1.2 : 1, anchor: scaleAnchor)
            .animation(.easeOut(duration: configuration.isPressed ? 0.01 : 0.5), value: configuration.isPressed)
        }
        configuration.label
          .bold()
          .fontDesign(.monospaced)
          .font(.system(size: 20))
          .scaleEffect(configuration.isPressed ? 1.2 : 1, anchor: scaleAnchor)
          .animation(.easeOut(duration: configuration.isPressed ? 0.01 : 0.5), value: configuration.isPressed)
      }
      .padding(-1)
      .onChange(of: configuration.isPressed) { value in
        if value {
          DispatchQueue.main.async {
            WKInterfaceDevice().play(.click)
          }
        }
      }
    }
  }
}

func dots(_ array: String, showLastDigit: Bool = false) -> String {
  var output = ""
  for i in 0..<array.count {
    //    output.append("•")
    if showLastDigit && i == array.count-1 {
      //      output.append(String(array[array.count-1]))
    } else {
      output.append("●")
    }
  }
  return output
}

func dotsByInt(_ number: Int) -> String {
  var output = ""
  for _ in 0...number {
      output.append("●")
  }
  return output
}

func passcodeIsCorrect(_ input: String, correctPasscode: String, expectedNumber: String) -> Bool {
  if expectedNumber == "any"{
    return true
  } else if expectedNumber == "def" {
    return correctPasscode.isEmpty || correctPasscode == input
  } else {
    return input == expectedNumber
  }
}
