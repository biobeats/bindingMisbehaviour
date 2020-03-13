import SwiftUI
import SwiftDate

private struct PickerController: UIViewRepresentable {
    @Binding var selectedDate: Date
    let minDate = 1970

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        return picker
    }

    func updateUIView(_ uiView: UIPickerView, context: Context) {
        // Just refresh the ccomponents
        uiView.reloadAllComponents()
        // With just the above, the rows are not selected correctly when setting selectedDate
        uiView.selectRow(selectedDate.day - 1, inComponent: 0, animated: false)
        uiView.selectRow(selectedDate.month - 1, inComponent: 1, animated: false)
        uiView.selectRow(selectedDate.year - minDate, inComponent: 2, animated: false)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selDate: $selectedDate)
    }

    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        @Binding var selectedDate : Date
        let minDate = 1970

        init(selDate: Binding<Date>) {
            self._selectedDate = selDate
            super.init()
        }

        func pickerView(_ pickerView: UIPickerView,
                        viewForRow row: Int,
                        forComponent component: Int, reusing view: UIView?) -> UIView {
            print("In row build function curr date is: \(selectedDate)")
            let v = view as? UILabel ?? UILabel()
            switch component {
            case 0:
                v.text = String(row + 1)
            case 1:
                v.text = String(row + 1)
            default:
                v.text = String(row + minDate)
            }
            return v
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 3
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0:
                let year = selectedDate.year
                let month = selectedDate.month
                return Date(year: year,
                            month: month,
                            day: 1, hour: 0, minute: 0).monthDays
            case 1:
                return 12
            default:
                return Date().year - minDate + 1
            }
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            // Make sure we don't select like 30th of Feb
            let firstOfMonth = Date(year: pickerView.selectedRow(inComponent: 2) + minDate,
                                    month: pickerView.selectedRow(inComponent: 1) + 1,
                                    day: 1, hour: 0, minute: 0)
            var day = pickerView.selectedRow(inComponent: 0) + 1
            if day > firstOfMonth.monthDays {
                day = firstOfMonth.monthDays
            }

            // Update the current date
            selectedDate = Date(year: pickerView.selectedRow(inComponent: 2) + minDate,
                                month: pickerView.selectedRow(inComponent: 1) + 1,
                                day: day, hour: 0, minute: 0)
            print("After did select row function curr date is: \(selectedDate)")
        }
    }
}

struct CustomPicker: View {
    @State private var selectedDate = Date()

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(selectedDate.toFormat("dd MMM yyyy"))
                .padding(20)
            Divider()
            PickerController(selectedDate: $selectedDate)
                .padding(20)
        }
    }
}

struct StyledPicker_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CustomPicker()
        }
        .previewLayout(.fixed(width: 500, height: 300))
    }
}
