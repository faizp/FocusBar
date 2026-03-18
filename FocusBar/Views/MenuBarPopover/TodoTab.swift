import SwiftUI

struct TodoTab: View {
    @Environment(TodoService.self) private var todoService
    @State private var newTodoTitle = ""
    @State private var isAddingNew = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("To-Do")
                        .font(.headline)
                    Spacer()
                    Text("\(todoService.pendingItems.count) pending")
                        .font(.system(.callout, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                .padding()

                // Add new todo inline
                if isAddingNew {
                    HStack(spacing: 10) {
                        Image(systemName: "circle")
                            .font(.body)
                            .foregroundStyle(.tertiary)

                        TextField("What needs to be done?", text: $newTodoTitle)
                            .textFieldStyle(.plain)
                            .font(.callout)
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                commitNewTodo()
                            }
                            .onExitCommand {
                                cancelAdding()
                            }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                    Divider().padding(.leading, 44)
                }

                // Pending items
                if todoService.pendingItems.isEmpty && !isAddingNew {
                    VStack(spacing: 6) {
                        Text("No tasks yet")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Text("⌘N to add a new task")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(todoService.pendingItems) { item in
                            todoRow(item)
                            Divider().padding(.leading, 44)
                        }
                    }
                }

                // Completed items
                if !todoService.completedItems.isEmpty {
                    HStack {
                        Text("Completed")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 4)

                    LazyVStack(spacing: 0) {
                        ForEach(todoService.completedItems) { item in
                            todoRow(item)
                            Divider().padding(.leading, 44)
                        }
                    }
                }
            }
        }
        .keyboardShortcut(.init("n"), modifiers: .command)
        .background {
            Button("") { startAdding() }
                .keyboardShortcut("n", modifiers: .command)
                .hidden()
        }
    }

    private func todoRow(_ item: TodoItem) -> some View {
        HStack(spacing: 10) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    todoService.toggleComplete(item)
                }
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                    .foregroundStyle(item.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            Text(item.title)
                .font(.callout)
                .strikethrough(item.isCompleted)
                .foregroundStyle(item.isCompleted ? .secondary : .primary)
                .lineLimit(2)

            Spacer()

            if item.isCompleted {
                Button {
                    withAnimation {
                        todoService.delete(item)
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    private func startAdding() {
        isAddingNew = true
        isTextFieldFocused = true
    }

    private func commitNewTodo() {
        todoService.add(newTodoTitle)
        newTodoTitle = ""
        isAddingNew = false
    }

    private func cancelAdding() {
        newTodoTitle = ""
        isAddingNew = false
    }
}
