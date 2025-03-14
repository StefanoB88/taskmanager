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
    
    private let priorities = ["Low", "Medium", "High"]
    
    var body: some View {
        Form {
            Section(header: Text("Task Details")) {
                TextField("Title", text: Binding(
                    get: { task.title ?? "" },
                    set: { task.title = $0 }
                ))
                .padding()
                
                TextField("Description", text: Binding(
                    get: { task.taskDescription ?? "" },
                    set: { task.taskDescription = $0 }
                ))
                .padding()
                
                Picker("Priority", selection: Binding(
                    get: { task.priority ?? "Low" },
                    set: { task.priority = $0 }
                )) {
                    ForEach(priorities, id: \.self) { priority in
                        Text(priority)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                DatePicker("Due Date", selection: Binding(
                    get: { task.dueDate ?? Date() },
                    set: { task.dueDate = $0 }
                ), displayedComponents: .date)
            }
            
            Section {
                Button("Save Changes") {
                    saveChanges()
                }
                
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Text("Delete Task")
                }
                .alert("Delete Task", isPresented: $showDeleteAlert) {
                    Button("Yes", role: .destructive) {
                        deleteTask()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to eliminate this task?")
                }
            }
        }
        .navigationTitle("Task Details")
        .navigationBarItems(trailing: Button("Cancel") {
            dismiss()
        })
    }
    
    private func saveChanges() {
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving task: \(error.localizedDescription)")
        }
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
    }
}
