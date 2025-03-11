//
//  ContentView.swift
//  EasyTask
//
//  Created by Stefano on 11.03.25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)],
        animation: .default
    ) private var tasks: FetchedResults<TaskEntity>
    
    @State private var showAddTaskView = false
    @State private var filter: TaskFilter = .all
    
    var filteredTasks: [TaskEntity] {
        switch filter {
        case .all:
            return tasks.map({ $0 })
        case .completed:
            return tasks.filter({ $0.isCompleted })
        case .pending:
            return tasks.filter({ !$0.isCompleted })
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Filter", selection: $filter) {
                    Text("All").tag(TaskFilter.all)
                    Text("Completed").tag(TaskFilter.completed)
                    Text("Pending").tag(TaskFilter.pending)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List {
                    ForEach(filteredTasks, id: \.self) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            TaskRow(task: Binding(
                                get: { task },
                                set: { newTask in
                                    task = newTask
                                    try? viewContext.save()
                                }))
                        }
                    }
                    .onDelete(perform: deleteTask)
                }
                .listStyle(PlainListStyle())
                
                Button(action: { showAddTaskView.toggle() }) {
                    Label("Add Task", systemImage: "plus")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                }
                .padding()
                .sheet(isPresented: $showAddTaskView) {
                    AddTaskView()
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .navigationTitle("Task Manager")
        }
    }
    
    private func deleteTask(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredTasks[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

enum TaskFilter: String, CaseIterable {
    case all, completed, pending
}
