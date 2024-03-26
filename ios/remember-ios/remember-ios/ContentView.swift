import SwiftUI

struct ContentView: View {
  @ObservedObject var store = Store()

  @State var presentSheet = false

  var body: some View {
    VStack(alignment: .leading) {
      Text("Remember")
        .font(.title)
        .fontWeight(.bold)
      List {
        ForEach(store.entries) { entry in
          HStack {
            Text(entry.title)
            Spacer()
            if let dueIn = entry.dueIn {
              Text(dueIn)
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
          }.swipeActions {
            Button(action: {
              store.archive(entry: entry)
            }, label: {
              Image(systemName: "checkmark.circle")
            }).tint(.accentColor)
            Button(action: {
              store.delete(entry: entry)
            }, label: {
              Image(systemName: "trash.slash.fill")
            }).tint(.red)
          }
        }.listRowInsets(EdgeInsets())
      }
      .listStyle(.plain)
      .onShake { _ in
        _ = Backend.shared.undo()
      }
      HStack {
        Spacer()
        Button(action: {
          presentSheet.toggle()
        }, label: {
          Image(systemName: "plus.app")
            .font(.system(size: 24))
        }).sheet(isPresented: $presentSheet, content: {
          CommandView()
        })
        Spacer()
      }
    }
    .padding()
  }
}

struct CommandView: View {
  @Environment(\.dismiss) private var dismiss

  @State private var command = ""
  @FocusState private var focused

  var body: some View {
    NavigationView {
      VStack(alignment: .leading) {
        TextField("Remember...", text: $command)
          .focused($focused)
        Spacer()
      }
      .padding()
      .toolbar {
        ToolbarItem {
          Button("Done") {
            Backend.shared.commit(command: command).onComplete { _ in
              dismiss()
            }
          }
        }
      }
    }.onAppear {
      focused = true
    }
  }
}