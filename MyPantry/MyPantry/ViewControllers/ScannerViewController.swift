//
//  ScannerViewController.swiff
//
//  Created by Giacomo Orsi on 30/05/21.
//

import UIKit
import SPAlert

/// Handles a the view with barcode scanning
class ScannerViewController: UIViewController {
    
    @IBOutlet weak var addBarcodeManuallyButton: UIButton!
    @IBOutlet weak var scannerView: BarcodeScannerView! {
        didSet {
            scannerView.delegate = self
        }
    }

    var barcodeData: BarcodeData? = nil {
        didSet {
            if barcodeData != nil {
                self.performSegue(withIdentifier: "SearchBarcode", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !ServerModel.model.registered {
            SPAlert.present(title: "Errore", message: "È necessario essere registrati per aggiungere dei prodotti", preset: .error, completion: nil)
            addBarcodeManuallyButton.isEnabled = false
            return
        }
        
        addBarcodeManuallyButton.isEnabled = true
        
        #if !targetEnvironment(simulator)
        if !scannerView.isRunning {
            scannerView.startScanning()
        }
        #endif
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if scannerView.isRunning {
            scannerView.stopScanning()
        }
    }
}

extension ScannerViewController: BarcodeScannerViewDelegate {
    func barcodeScanningDidStop() {
        print("interrotto scanning")
    }
    func barcodeScanningDidFail() {
        print("errore")
    }
    
    func barcodeScanningSucceededWithCode(_ str: String?) {
        self.barcodeData = BarcodeData(codeString: str)
    }
}

extension ScannerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchBarcode", let viewController = segue.destination as? InsertBarcodeViewController {
            viewController.barcode = self.barcodeData?.codeString
        } else if segue.identifier == "AddBarcodeManually" {
            scannerView.stopScanning()
        }
    }
}
