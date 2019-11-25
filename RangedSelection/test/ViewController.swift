import UIKit
import JTAppleCalendar

class ViewController: UIViewController {
    
    @IBOutlet var calendarView: JTAppleCalendarView!
    
    @IBOutlet weak var pickYear: UIDatePicker!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var availableEventsLbl: UILabel!
    
    @IBOutlet weak var noeventLbl: UILabel!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var monthBTN: UIButton!
    

    let formatter = DateFormatter()
    
    var calendarDataSource: [String:String] = [:]
//    var formatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd-MMM-yyyy"
//        return formatter
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        
        calendarView.allowsMultipleSelection = false
        calendarView.isRangeSelectionUsed = true
        
        pickYear.addTarget(self, action: #selector(ViewController.datePickerValueChanged), for: UIControl.Event.valueChanged)
            self.view.endEditing(true)
        
        populateDataSource()

    }
    
    
    // change month label
    @IBAction func month_btn_Action(_ sender: Any) {
        
        pickYear.isHidden = false
    
    }
     
    
    // Events dates
    func populateDataSource() {
        // update the datrasource
        calendarDataSource = [
            "07-Jan-2018": " SomeData",
            "15-Jan-2018": " SomeMoreData",
            "15-Feb-2018": " MoreData",
            "21-Feb-2018": " onlyData",
        ]
        calendarView.reloadData()
    }
    
    //hide pickerview
    @IBAction func hidePickerBtn(_ sender: Any) {
        
        pickYear.isHidden = true
    }
    
    
    
    //change month label based on selected dates
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = Calendar.current.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        // 0 indexed array
        let year = Calendar.current.component(.year, from: startDate)
        monthLabel.text = monthName + " " + String(year)
    }
    
    
    //change pickervalue
    @objc func datePickerValueChanged(datePicker: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        let dateValue = dateFormatter.string(from: datePicker.date)
        
        monthLabel.text = dateValue
        
    }
    
    
    // configure all functions
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellEvents(cell: cell, cellState: cellState)
    }
    
    
    //text color of dates
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.black
        } else {
            cell.dateLabel.textColor = UIColor.gray
        }
    }
    

    //show events
    func handleCellEvents(cell: DateCell, cellState: CellState) {
//        let dateString = formatter.string(from: cellState.date)
        if calendarDataSource.count < 1 {
            cell.dotView.isHidden = true
            noeventLbl.isHidden = true
            print("no events")
        } else {
            cell.dotView.isHidden = false
            availableEventsLbl.isHidden = false
            tableView.isHidden = false
            print("available events")
        }
    }
    
    //for dotView
//    func handleDotView(cell: DateCell, cellState: CellState) {
//        cell.dotView.isHidden = !cellState.isSelected
//        switch Month.self {
//        case .January:
//             availableEventsLbl.text = calendarDataSource["07-Jan-2018"]
//
//        }
//
//    }
    
    // select particular date
    func handleCellSelected(cell: DateCell, cellState: CellState) {
        cell.selectedView.isHidden = !cellState.isSelected
        switch cellState.selectedPosition() {
        case .left:
            cell.selectedView.layer.cornerRadius = 20
            cell.selectedView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        case .middle:
            cell.selectedView.layer.cornerRadius = 0
            cell.selectedView.layer.maskedCorners = []
        case .right:
            cell.selectedView.layer.cornerRadius = 20
            cell.selectedView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        case .full:
            cell.selectedView.layer.cornerRadius = 20
            cell.selectedView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        default: break
        }
    }
}

//MARK:- Extensions

//Date formatter
extension ViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        
        let startDate = formatter.date(from: "2019 01 01")!
        let endDate = formatter.date(from: "2030 02 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate,endDate: endDate)
        return parameters
    }
}

//date cells
extension ViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    
    
     func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let key   = Array(self.calendarDataSource.keys)[indexPath.row]
        let value = Array(self.calendarDataSource.values)[indexPath.row]
        cell.textLabel?.text = key + value
        return cell
    }
    
    
    
    
}
