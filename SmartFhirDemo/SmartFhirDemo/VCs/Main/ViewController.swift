//
//  ViewController.swift
//  SmartFhirDemo
//
//  Created by Fede on 29/12/2017.
//  Copyright © 2017 Lateral View. All rights reserved.
//

import UIKit
import SMART

class ViewController: UIViewController {

    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var meds = [MedicationRequest]()
    
    let toMedRequestDetailSegueId = "toMedRequestDetail"
    let medicationRequestsTitle = "Medication Requests"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toMedRequestDetailSegueId {
            let selectedMedRequest = meds[(self.tableView.indexPathForSelectedRow?.row)!]
            let vc = segue.destination as! MedicationDetailVC
            vc.medicationRequest = selectedMedRequest
        }
    }
    
    func connectWithFHIR() {
    
        //Authenticate
        SmartAPI.shared.auth { (patient, error) in
            DispatchQueue.main.async {
                if nil != error || nil == patient  {
                    //Error
                    print("Error while trying to connect to SMART FHIR")
                    self.connectBtn.isHidden = false
                    self.tableView.isHidden = true
                } else {
                    //Success
                    print("Successfully connected to SMART FHIR")
                    
                    //Hide connect to FHIR button
                    self.connectBtn.isHidden = true
                    self.tableView.isHidden = false
                    
                    
                    //Set patient name as title
                    self.title = patient?.humanName
                    
                    
                    //Get Medication Requests
                    self.getMedicationRequests(patient: patient!)
                }
            }
        }
    }
    
    func getMedicationRequests (patient : Patient) {
        SmartAPI.shared.getMedicationRequests(patient: patient) { (medRequests, error) in
            DispatchQueue.main.async {
                if (error == nil) {
                    //Show Medication Requests
                    self.meds = medRequests!
                }
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK : - Actions
    
    @IBAction func didTapConnect(_ sender: UIButton) {
        connectWithFHIR()
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.meds.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return medicationRequestsTitle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MedicationRequestCell.cellID, for: indexPath) 
        let medRequest = meds[indexPath.row] as MedicationRequest
        cell.textLabel?.text = medRequest.status?.rawValue
        return cell
    }
    
}

