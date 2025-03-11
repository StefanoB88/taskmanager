//
//  AddTaskView.swift
//  TaskManager
//
//  Created by Stefano on 11.03.25.
//

import SwiftUI
import CoreData

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedPriority: String = "Low"
    @State private var dueDate = Date()
    
    private let priorities = ["Low", "Medium", "High"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                        .padding()
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(true)
                    
                    TextField("Description", text: $description)
                        .padding()
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(true)
                    
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(priorities, id: \.self) { priority in
                            Text(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
                
                Section {
                    Button("Save Task") {
                        addTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("Add Task")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func addTask() {
        let newTask = TaskEntity(context: viewContext)
        newTask.title = title
        newTask.taskDescription = description
        newTask.priority = selectedPriority
        newTask.dueDate = dueDate
        newTask.isCompleted = false
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving task: \(error.localizedDescription)")
        }
    }
}
