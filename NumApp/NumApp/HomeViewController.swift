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
            let fileSize = try Constants.fileManager.attributesOfItem(atPath: url.path)[.size] as? Double
            
            let fileSizeMB = (fileSize ?? 0.0) * 0.000001;
            
            if fileSizeMB == 0 {
                let NoDataFileErrorAlert = UIAlertController(
                    title: "File is empty",
                    message: "File hasn't data. Choose another file",
                    preferredStyle: .alert
                )
                NoDataFileErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(NoDataFileErrorAlert, animated: true, completion: nil)
            }
            
            if fileSizeMB <= 95 {
                
                fetchDataAndCalculateStatistics(from: url)
                
            }
            
            if fileSizeMB > 95 {
                let TooBigFileErroralert = UIAlertController(
                    title: "File is too big",
                    message: "File must be less than 95 MB ",
                    preferredStyle: .alert
                )
                TooBigFileErroralert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(TooBigFileErroralert, animated: true, completion: nil)
            }
            
            
        } catch {
            print("Error getting file attributes: \(error)")
        }
    }
    
    func fetchDataAndCalculateStatistics(from url: URL) {
        
        do {
            Task.init{
                
                let text = try  String(contentsOf: url, encoding: .utf8)
                let listNumbers = text.components(separatedBy: "\n")
                
                for strNumber in listNumbers {
                    if let currentNumber = Int(strNumber) {
                        if Constants.max_number < currentNumber {
                            Constants.max_number = currentNumber
                        }
                        
                        if Constants.min_number > currentNumber {
                            Constants.min_number = currentNumber
                        }
                        
                        Constants.sum += currentNumber
                        Constants.count += 1
                        
                        if Constants.count.isMultiple(of: 2) {
                            Constants.median = (Constants.median + currentNumber) / 2
                        } else {
                            Constants.median = currentNumber
                        }
                        
                        Constants.average = Double(Constants.sum) / Double(Constants.count);
                    }
                }
                
            }
            
            let StatisticsAlert = UIAlertController(
                title: "Statistic of text file with numbers",
                message: "Loading...",
                preferredStyle: .alert
            )
            
            StatisticsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(StatisticsAlert, animated: true) {
                
                let calculatingStaticsprogressView = UIProgressView(progressViewStyle: .default)
                calculatingStaticsprogressView.frame = CGRect(x: 10, y: 90, width: 250, height:2)
                calculatingStaticsprogressView.progress = 0.0
                StatisticsAlert.view.addSubview(calculatingStaticsprogressView)
                
                DispatchQueue.global(qos: .background).async {
                    for i in 0...5 {
                        DispatchQueue.main.async {
                            calculatingStaticsprogressView.progress = Float(i) / 5.0
                        }
                        sleep(1)
                    }
                    
                    DispatchQueue.main.async {
                        calculatingStaticsprogressView.isHidden = true
                        StatisticsAlert.message = "Maximum value: \(Constants.max_number)\nMinimum value: \(Constants.min_number)\nMedian: \(Constants.median)\nAverage: \(Constants.average)"
                        sleep(1)
                    }
                }
            }
            
        }
        
    }
}
