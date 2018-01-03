//
//  MedicationDetailVC.swift
//  SmartFhirDemo
//
//  Created by Fede on 02/01/2018.
//  Copyright © 2018 Lateral View. All rights reserved.
//

import UIKit
import SMART

class MedicationDetailVC: UIViewController {
    
    @IBOutlet weak var medicationNameLbl: UILabel!
    
    var medicationRequest : MedicationRequest!

    override func viewDidLoad() {
        super.viewDidLoad()
        medicationNameLbl.text = ""
        
        //Search Medication
        getMedication()
    }
    
    func getMedication() {
        SmartAPI.shared.getMedication(medicationRequest: medicationRequest) { (medication, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.medicationNameLbl.text = medication?.code?.text?.string
                }
            }
        }
    }
}
