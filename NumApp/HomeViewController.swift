import UIKit
import UniformTypeIdentifiers

class HomeViewController: UIViewController, UIDocumentPickerDelegate, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet weak var selectFileBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func selectFileDevice(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.text])
        documentPicker.delegate = self
        documentPicker.shouldShowFileExtensions = true
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        do {
            let fileSize = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Double
            let fileSizeMB = (fileSize ?? 0.0) * 0.000001
            
            if fileSizeMB == 0 {
                showStatisticsAlert(title: "File is empty", message: "File hasn't data. Choose another file")
                return
            }
            
            if fileSizeMB > 95 {
                showStatisticsAlert(title: "File is too big", message: "File must be less than 95 MB")
                return
            }
            
            fetchDataAndCalculateStatistics(from: url)
            
        } catch {
            print("Error getting file attributes: \(error)")
        }
    }
    
    func fetchDataAndCalculateStatistics(from url: URL) {
        let statisticsAlert = UIAlertController(
            title: "Statistic of text file with numbers",
            message: "Loading...",
            preferredStyle: .alert
        )
        
        statisticsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(statisticsAlert, animated: true) {
            let calculatingStaticsprogressView = UIProgressView(progressViewStyle: .default)
            calculatingStaticsprogressView.frame = CGRect(x: 10, y: 90, width: 250, height: 2)
            calculatingStaticsprogressView.progress = 0.0
            statisticsAlert.view.addSubview(calculatingStaticsprogressView)
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let text = try String(contentsOf: url, encoding: .utf8)
                    let listNumbers = text.components(separatedBy: .newlines).compactMap { Int($0) }
                    
                    guard !listNumbers.isEmpty else {
                        DispatchQueue.main.async {
                            statisticsAlert.dismiss(animated: true) {
                                self.showStatisticsAlert(title: "No valid numbers", message: "The file does not contain valid numbers.")
                            }
                        }
                        return
                    }
                    
                    let maxNumber = listNumbers.max() ?? 0
                    let minNumber = listNumbers.min() ?? 0
                    let sum = listNumbers.reduce(0, +)
                    let count = listNumbers.count
                    let average = Double(sum) / Double(count)
                    let median = self.calculateMedian(from: listNumbers)
                    
                    
                    DispatchQueue.main.async {
                        
                        calculatingStaticsprogressView.isHidden = true
                        
                        statisticsAlert.message = "Maximum value: \(maxNumber)\nMinimum value: \(minNumber)\nMedian: \(median)\nAverage: \(average)"
                    }
                    
                } catch {
                    print("Error reading file: \(error)")
                    DispatchQueue.main.async {
                        statisticsAlert.dismiss(animated: true) {
                            self.showStatisticsAlert(title: "Error", message: "Failed to read the file.")
                        }
                    }
                }
            }
        }
    }
    
    func calculateMedian(from numbers: [Int]) -> Double {
        let sortedNumbers = numbers.sorted()
        let count = sortedNumbers.count
        
        if count % 2 == 0 {
            return Double(sortedNumbers[count / 2 - 1] + sortedNumbers[count / 2]) / 2.0
        } else {
            return Double(sortedNumbers[count / 2])
        }
    }
    
    func showStatisticsAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
