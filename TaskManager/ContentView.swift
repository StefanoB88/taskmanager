//
//  ContentView.swift
//  EasyTask
//
//  Created by Stefano on 11.03.25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTask: TaskEntity?
    @State private var isPulsing = false
    
    // Sorting
    @State private var sortBy: SortOption = .priority
    @State private var showSortOptions = false
    @State private var sortDirection: Bool = true // true = ascending, false = descending
    
    // AccentColor
    @AppStorage("accentColor") private var accentColorHex: String = "#0000FF" // Default iOS Blue
    var accentColor: Color {
        return Color.fromHex(accentColorHex)
    }
    
    @State private var showAddTaskView = false
    @State private var filter: TaskFilter = .all
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: TaskEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.order, ascending: true)],
        animation: .default
    ) private var tasks: FetchedResults<TaskEntity>
    
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
    
    @State var completedTasks: Int = 0
    @State var totalTasks: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Task Manager")
                        .font(.title)
                        .fontWeight(.bold)
                        .accessibilityLabel("Task Manager Title")
                    Spacer()
                    CircularProgressIndicator(completedTasks: $completedTasks, totalTasks: $totalTasks)
                        .frame(width: 50, height: 50)
                        .padding(.top, 5)
                        .accessibilityLabel("Task completion progress")
                        .accessibilityValue("\(completedTasks) of \(totalTasks) tasks completed")
                }
                .padding()
                
                Picker("Filter", selection: $filter) {
                    Text("All").tag(TaskFilter.all)
                    Text("Completed").tag(TaskFilter.completed)
                    Text("Pending").tag(TaskFilter.pending)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List {
                    if filteredTasks.isEmpty {
                        VStack {
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                            Text("No tasks yet!")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .accessibilityLabel("No tasks available")
                                .accessibilityHint("Add a new task to get started")
                            Text("Stay productive! Add your first task now.")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .listRowSeparator(.hidden)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        LazyVStack {
                            ForEach(filteredTasks.sorted(by: sortTasks), id: \.self) { task in
                                TaskRow(task: task, updateTaskCounts: updateTaskCounts)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                                            selectedTask = task
                                        }
                                    }
                            }
                            .onMove(perform: moveTask)
                        }
                    }
                }
                .sheet(item: $selectedTask) { task in
                    TaskDetailView(task: task, updateTaskCounts: updateTaskCounts)
                }
                .listStyle(PlainListStyle())
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPulsing = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPulsing = false
                        }
                    }
                    showAddTaskView.toggle()
                }) {
                    Label("Add Task", systemImage: "plus")
                        .font(.title2)
                        .padding()
                        .background(accentColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                }
                .accessibilityLabel("Add a new task")
                .accessibilityHint("Opens a form to create a new task")
                .padding()
                .sheet(isPresented: $showAddTaskView) {
                    AddTaskView(updateTaskCounts: updateTaskCounts)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .onAppear {
                updateTaskCounts()  // Call this when the view appears
            }
            .onChange(of: filter) {
                updateTaskCounts()  // Call this when the filter changes
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            showSortOptions.toggle()
                        }) {
                            Image(systemName: "arrow.up.arrow.down.circle.fill")
                                .font(.title2)
                                .foregroundColor(accentColor)
                        }
                        .accessibilityLabel("Sort Tasks")
                        .accessibilityHint("Tap to change the sorting order of tasks")
                        
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(accentColor)
                        }
                    }
                }
            }
            .actionSheet(isPresented: $showSortOptions) {
                ActionSheet(
                    title: Text("Sort Tasks"),
                    buttons: [
                        .default(Text("Priority")) {
                            sortBy = .priority
                            sortDirection.toggle()
                        },
                        .default(Text("Due Date")) {
                            sortBy = .dueDate
                            sortDirection.toggle()
                        },
                        .default(Text("Alphabetically")) {
                            sortBy = .alphabetical
                            sortDirection.toggle()
                        },
                        .cancel()
                    ]
                )
            }
        }
        .accentColor(accentColor)
    }
    
    private func updateTaskCounts() {
        completedTasks = filteredTasks.filter { $0.isCompleted }.count
        totalTasks = filteredTasks.count
    }
    
    private func moveTask(from source: IndexSet, to destination: Int) {
        var tasksArray = filteredTasks
        tasksArray.move(fromOffsets: source, toOffset: destination)
        
        for (index, task) in tasksArray.enumerated() {
            task.order = Int16(index)
        }
        
        try? viewContext.save()
    }
    
    private func sortTasks(lhs: TaskEntity, rhs: TaskEntity) -> Bool {
        switch sortBy {
        case .priority:
            let lhsPriority = priorityStringToNumber(lhs.priority)
            let rhsPriority = priorityStringToNumber(rhs.priority)
            
            if sortDirection {
                return lhsPriority < rhsPriority
            } else {
                return lhsPriority > rhsPriority
            }
        case .dueDate:
            if sortDirection {
                return lhs.dueDate ?? Date() < rhs.dueDate ?? Date()
            } else {
                return lhs.dueDate ?? Date() > rhs.dueDate ?? Date()
            }
        case .alphabetical:
            if sortDirection {
                return lhs.title?.localizedStandardCompare(rhs.title ?? "") == .orderedAscending
            } else {
                return lhs.title?.localizedStandardCompare(rhs.title ?? "") == .orderedDescending
            }
        }
    }
    
    private func priorityStringToNumber(_ priority: String?) -> Int {
        switch priority?.lowercased() {
        case "high":
            return 3
        case "medium":
            return 2
        case "low":
            return 1
        default:
            return 0
        }
    }
}

enum TaskFilter: String, CaseIterable {
    case all, completed, pending
}

enum SortOption: String, CaseIterable {
    case priority, dueDate, alphabetical
}
