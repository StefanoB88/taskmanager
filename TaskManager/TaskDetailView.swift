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
    
    var task: TaskEntity
    
    @State private var title: String
    @State private var description: String
    @State private var selectedPriority: String
    @State private var dueDate: Date
    
    private let priorities = ["Low", "Medium", "High"]
    
    init(task: TaskEntity) {
        self.task = task
        _title = State(initialValue: task.title ?? "")
        _description = State(initialValue: task.taskDescription ?? "")
        _selectedPriority = State(initialValue: task.priority ?? "Low")
        _dueDate = State(initialValue: task.dueDate ?? Date())
    }
    
    var body: some View {
        Form {
            Section(header: Text("Task Details")) {
                TextField("Title", text: $title)
                    .padding()
                
                TextField("Description", text: $description)
                    .padding()
                
                Picker("Priority", selection: $selectedPriority) {
                    ForEach(priorities, id: \.self) { priority in
                        Text(priority)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
            }
            
            Section {
                Button("Save Changes") {
                    saveChanges()
                }
                
                Button(role: .destructive) {
                    deleteTask()
                } label: {
                    Text("Delete Task")
                }
            }
        }
        .navigationTitle("Task Details")
        .navigationBarItems(trailing: Button("Cancel") {
            dismiss()
        })
    }
    
    private func saveChanges() {
        task.title = title
        task.taskDescription = description
        task.priority = selectedPriority
        task.dueDate = dueDate
        
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
            try? viewContext.save()
            dismiss()
        }
    }
}
