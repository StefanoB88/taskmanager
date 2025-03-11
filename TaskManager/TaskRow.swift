//
//  TaskRow.swift
//  TaskManager
//
//  Created by Stefano on 11.03.25.
//

import SwiftUI

struct TaskRow: View {
    @Binding var task: TaskEntity
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title ?? "Untitled")
                    .font(.headline)
                    .lineLimit(1)
                
                if let description = task.taskDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Text("Due: \(formattedDate(task.dueDate))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(task.priority ?? "Low")
                .font(.subheadline)
                .padding(6)
                .background(priorityColor(task.priority ?? "Low"))
                .foregroundColor(.white)
                .cornerRadius(8)
            
            if task.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(task.isCompleted ? Color.green.opacity(0.1) : Color.clear)
        .cornerRadius(10)
        .swipeActions {
            Button(role: .destructive) {
                deleteTask()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                toggleCompletion()
            } label: {
                Label(task.isCompleted ? "Mark as Pending" : "Mark as Completed", systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark.circle")
            }
            .tint(task.isCompleted ? .yellow : .green)
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
        withAnimation {
            viewContext.delete(task)
            try? viewContext.save()
        }
    }
    
    private func toggleCompletion() {
        task.isCompleted.toggle()
        try? viewContext.save()
    }
}
