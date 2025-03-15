//
//  TaskRow.swift
//  TaskManager
//
//  Created by Stefano on 11.03.25.
//

import SwiftUI

struct TaskRow: View {
    @ObservedObject var task: TaskEntity
    @Environment(\.managedObjectContext) private var viewContext
    var updateTaskCounts: () -> Void
    
    @State private var showAlert = false
    @State private var taskToDelete: TaskEntity?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title ?? "Untitled")
                    .font(.headline)
                    .lineLimit(1)
                    .accessibilityLabel(task.title ?? "Untitled Task")
                    .accessibilityHint("The title of the task")
                
                if let description = task.taskDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .accessibilityLabel("Description: \(description)")
                        .accessibilityHint("The description of the task")
                }
                
                Text("Due: \(formattedDate(task.dueDate))")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .accessibilityLabel("Due date")
                    .accessibilityValue(formattedDate(task.dueDate))
                    .accessibilityHint("The due date for the task")
            }
            
            Spacer()
            
            Text(task.priority ?? "Low")
                .font(.subheadline)
                .padding(6)
                .background(priorityColor(task.priority ?? "Low"))
                .foregroundColor(.white)
                .cornerRadius(8)
                .accessibilityLabel("Priority: \(task.priority ?? "Low")")
                .accessibilityHint("The priority of the task")
            
            if task.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .accessibilityLabel("Task completed")
                    .accessibilityHint("This task has been marked as completed")
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
                    .accessibilityLabel("Task not completed")
                    .accessibilityHint("This task is not completed yet")
            }
        }
        .padding()
        .background(task.isCompleted ? Color.green.opacity(0.1) : Color.clear)
        .cornerRadius(10)
        .swipeActions {
            Button(role: .destructive) {
                taskToDelete = task
                showAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .accessibilityLabel("Delete Task")
            .accessibilityHint("Delete this task permanently")
            
            Button {
                toggleCompletion()
            } label: {
                Label(task.isCompleted ? "Mark as Pending" : "Mark as Completed", systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark.circle")
            }
            .tint(task.isCompleted ? .yellow : .green)
            .accessibilityLabel(task.isCompleted ? "Mark as Pending" : "Mark as Completed")
            .accessibilityHint("Tap to change the task completion status")
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete Task"),
                message: Text("Are you sure you want to delete this task?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteTask()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func priorityColor(_ priority: String) -> Color {
        switch priority {
        case "High": return .red
        case "Medium": return .orange
        case "Low": return .green
        default: return .gray
        }
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "No due date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func deleteTask() {
        guard let taskToDelete = taskToDelete else { return }
        
        withAnimation {
            viewContext.delete(taskToDelete)
            try? viewContext.save()
        }
        
        updateTaskCounts()
    }
    
    private func toggleCompletion() {
        task.isCompleted.toggle()
        try? viewContext.save()
        updateTaskCounts()
    }
}
