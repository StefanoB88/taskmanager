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
    var updateTaskCounts: () -> Void
    
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
                        .accessibilityIdentifier("addTaskTitle")
                        .accessibilityLabel("Task Title")
                        .accessibilityHint("Enter a title for the task")
                    
                    TextField("Description", text: $description)
                        .padding()
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(true)
                        .accessibilityIdentifier("addTaskDescription")
                        .accessibilityLabel("Task Description")
                        .accessibilityHint("Enter a brief description of the task")
                    
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(priorities, id: \.self) { priority in
                            Text(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accessibilityIdentifier("addTaskPriority")
                    .accessibilityLabel("Task Priority")
                    .accessibilityHint("Select the priority level for the task")
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                        .accessibilityLabel("Task Due Date")
                        .accessibilityHint("Select a due date for the task")
                }
                
                Section {
                    Button("Save Task") {
                        addTask()
                    }
                    .disabled(title.isEmpty)
                    .accessibilityIdentifier("saveTaskButton")
                    .accessibilityLabel("Save Task")
                    .accessibilityHint("Saves the task and returns to the previous screen")
                }
            }
            .navigationTitle("Add Task")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            }
            .accessibilityLabel("Cancel")
            .accessibilityHint("Dismisses the add task screen without saving"))
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
        
        updateTaskCounts()
    }
}
