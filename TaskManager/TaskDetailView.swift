//
//  TaskDetailView.swift
//  TaskManager
//
//  Created by Stefano on 11.03.25.
//

import SwiftUI

struct TaskDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var task: TaskEntity
    
    @State private var showDeleteAlert = false
    
    var updateTaskCounts: () -> Void
    
    private let priorities = ["Low", "Medium", "High"]
    
    var body: some View {
        Form {
            Section(header: Text("Task Details")) {
                TextField("Title", text: Binding(
                    get: { task.title ?? "" },
                    set: { task.title = $0 }
                ))
                .padding()
                .accessibilityLabel("Task Title")
                .accessibilityHint("Enter a title for the task")
                
                TextField("Description", text: Binding(
                    get: { task.taskDescription ?? "" },
                    set: { task.taskDescription = $0 }
                ))
                .padding()
                .accessibilityLabel("Task Description")
                .accessibilityHint("Enter a brief description of the task")
                
                Picker("Priority", selection: Binding(
                    get: { task.priority ?? "Low" },
                    set: { task.priority = $0 }
                )) {
                    ForEach(priorities, id: \.self) { priority in
                        Text(priority)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .accessibilityLabel("Task Priority")
                .accessibilityHint("Select the priority level for the task")
                
                DatePicker("Due Date", selection: Binding(
                    get: { task.dueDate ?? Date() },
                    set: { task.dueDate = $0 }
                ), displayedComponents: .date)
                .accessibilityLabel("Task Due Date")
                .accessibilityHint("Select a due date for the task")
            }
            
            Section {
                Button("Save Changes") {
                    saveChanges()
                }
                .disabled(task.title?.isEmpty ?? true)
                .accessibilityLabel("Save Changes")
                .accessibilityHint("Saves the task details and returns to the task list")
                
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Text("Delete Task")
                }
                .accessibilityLabel("Delete Task")
                .accessibilityHint("Deletes the task permanently")
                .alert("Delete Task", isPresented: $showDeleteAlert) {
                    Button("Yes", role: .destructive) {
                        deleteTask()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to delete this task?")
                }
            }
        }
        .navigationTitle("Task Details")
        .navigationBarItems(trailing: Button("Cancel") {
            dismiss()
        }
        .accessibilityLabel("Cancel")
        .accessibilityHint("Dismisses the task details screen without saving"))
    }
    
    private func saveChanges() {
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving task: \(error.localizedDescription)")
        }
        
        updateTaskCounts()
    }
    
    private func deleteTask() {
        withAnimation {
            viewContext.delete(task)
            do {
                try viewContext.save()
                dismiss()
            } catch {
                print("Error deleting task: \(error.localizedDescription)")
            }
        }
        
        updateTaskCounts()
    }
}
