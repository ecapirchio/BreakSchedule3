import SwiftUI

struct ContentView: View {
    // States for Home Screen
    @State private var name = ""
    @State private var shiftStart: Date = Date()
    @State private var shiftEnd: Date = Date()
    @State private var employees: [Employee] = []
    @State private var schedule: [Schedule] = []

    // States for Picker Visibility
    @State private var isShiftStartPickerVisible = false
    @State private var isShiftEndPickerVisible = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Break Schedule")
                    .font(.largeTitle)
                    .bold()

                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Shift Start")
                        .font(.headline)

                    if isShiftStartPickerVisible {
                        DatePicker(
                            "Select Shift Start",
                            selection: $shiftStart,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .transition(.scale) // Smooth transition
                    } else {
                        Button(action: {
                            isShiftStartPickerVisible.toggle()
                        }) {
                            Text("Tap to Set Shift Start: \(formattedDate(shiftStart))")
                                .foregroundColor(.blue)
                                .padding(.vertical)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Shift End")
                        .font(.headline)

                    if isShiftEndPickerVisible {
                        DatePicker(
                            "Select Shift End",
                            selection: $shiftEnd,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .transition(.scale) // Smooth transition
                    } else {
                        Button(action: {
                            isShiftEndPickerVisible.toggle()
                        }) {
                            Text("Tap to Set Shift End: \(formattedDate(shiftEnd))")
                                .foregroundColor(.blue)
                                .padding(.vertical)
                        }
                    }
                }

                Button("Add Employee") {
                    addEmployee()
                }
                .buttonStyle(.borderedProminent)

                Button("Generate Schedule") {
                    generateSchedule()
                }
                .buttonStyle(.borderedProminent)

                Button("Reset All") {
                    resetData()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)

                if schedule.isEmpty {
                    Text("No schedule generated yet.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(schedule) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name: \(item.name)")
                                .font(.headline)
                            Text("Shift: \(item.shift)")
                            Text("First Break: \(item.firstBreak)")
                            Text("Lunch Break: \(item.lunchBreak)")
                            Text("Second Break: \(item.secondBreak)")
                        }
                        .padding()
                    }
                    .frame(height: 300) // Adjust as needed
                }
            }
            .padding()
            .animation(.easeInOut, value: isShiftStartPickerVisible || isShiftEndPickerVisible)
        }
    }

    // Helper Functions
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func addEmployee() {
        guard !name.isEmpty, shiftStart < shiftEnd else {
            print("Invalid input or shift start is after shift end")
            return
        }
        employees.append(Employee(name: name, shiftStart: shiftStart, shiftEnd: shiftEnd))
        name = ""
        shiftStart = Date()
        shiftEnd = Date()
        isShiftStartPickerVisible = false
        isShiftEndPickerVisible = false
    }

    private func generateSchedule() {
        guard !employees.isEmpty else {
            print("No employees to generate a schedule.")
            return
        }

        var occupiedBreaks: Set<String> = []
        func findNextAvailableTime(proposedTime: Date) -> Date {
            var time = proposedTime
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"

            while occupiedBreaks.contains(formatter.string(from: time)) {
                time.addTimeInterval(15 * 60) // Add 15 minutes
            }
            occupiedBreaks.insert(formatter.string(from: time))
            return time
        }

        schedule = employees.map { employee in
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"

            let shiftDuration = employee.shiftEnd.timeIntervalSince(employee.shiftStart) / 3600
            var firstBreak: Date? = nil
            var lunchBreak: Date? = nil
            var secondBreak: Date? = nil

            if shiftDuration < 6 {
                let midBreak = employee.shiftStart.addingTimeInterval(shiftDuration / 2 * 3600)
                firstBreak = findNextAvailableTime(proposedTime: midBreak)
            } else {
                firstBreak = findNextAvailableTime(proposedTime: employee.shiftStart.addingTimeInterval(2 * 3600))
                lunchBreak = findNextAvailableTime(proposedTime: employee.shiftStart.addingTimeInterval(4 * 3600))
                secondBreak = findNextAvailableTime(proposedTime: employee.shiftStart.addingTimeInterval(6 * 3600))
            }

            return Schedule(
                name: employee.name,
                shift: "\(formatter.string(from: employee.shiftStart)) - \(formatter.string(from: employee.shiftEnd))",
                firstBreak: firstBreak != nil ? formatter.string(from: firstBreak!) : "None",
                lunchBreak: lunchBreak != nil ? formatter.string(from: lunchBreak!) : "None",
                secondBreak: secondBreak != nil ? formatter.string(from: secondBreak!) : "None"
            )
        }

        print("Generated Schedule: \(schedule)")
    }

    private func resetData() {
        employees.removeAll()
        schedule.removeAll()
        isShiftStartPickerVisible = false
        isShiftEndPickerVisible = false
    }
}

// Data Models
struct Employee: Identifiable, Codable {
    let id = UUID()
    let name: String
    let shiftStart: Date
    let shiftEnd: Date
}

struct Schedule: Identifiable, Codable {
    let id = UUID()
    let name: String
    let shift: String
    let firstBreak: String
    let lunchBreak: String
    let secondBreak: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
