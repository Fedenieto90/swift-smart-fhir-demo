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
    var observations = [Observation]()
    var conditions = [Condition]()
    var diagnosticReports = [DiagnosticReport]()
    var encounters = [Encounter]()
    var appointments = [Appointment]()
    
    let toMedRequestDetailSegueId = "toMedRequestDetail"
    let medicationRequestsTitle = "Medication Requests"
    let observationsTitle = "Observations"
    let conditionsTitle = "Conditions"
    let diagnosticReportTitle = "Diagnostic Reports"
    let encountersTitle = "Encounter"
    let appointmentsTitle = "Appointments"
    
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
                    
                    //Get Observations
                    self.getObservations(patient: patient!)
                    
                    //Get Conditions
                    self.getConditions(patient: patient!)
                    
                    //Get Diagnostic Reports
                    self.getDiagnositcReport(patient: patient!)
                    
                    //Get encounters
                    self.getEncounters(patient: patient!)
                    
                    //Get appointments
                    self.getAppointments(patient: patient!)
                }
            }
        }
    }
    
    func getMedicationRequests (patient: Patient) {
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
    
    func getObservations(patient: Patient) {
        SmartAPI.shared.getObservations(patient: patient, completion: { (observations, error) in
            DispatchQueue.main.async {
                if (error == nil) {
                    //Show Observations
                    self.observations = observations!
                }
                self.tableView.reloadData()
            }
        })
    }
    
    func getConditions(patient: Patient) {
        SmartAPI.shared.getConditions(patient: patient) { (conditions, error) in
            DispatchQueue.main.async {
                if (error == nil) {
                    //Show Observations
                    self.conditions = conditions!
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func getDiagnositcReport(patient: Patient) {
        SmartAPI.shared.getDiagnosticReport(patient: patient) { (diagnosticReports, error) in
            DispatchQueue.main.async {
                if (error == nil) {
                    //Show Observations
                    self.diagnosticReports = diagnosticReports!
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func getEncounters(patient: Patient) {
        SmartAPI.shared.getEncounters(patient: patient) { (encounters, error) in
            DispatchQueue.main.async {
                if (error == nil) {
                    //Show Observations
                    self.encounters = encounters!
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func getAppointments(patient: Patient) {
        SmartAPI.shared.getAppointments(patient: patient) { (appointments, error) in
            DispatchQueue.main.async {
                if (error == nil) {
                    //Show Observations
                    self.appointments = appointments!
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return meds.count
        case 1:
            return observations.count
        case 2:
            return conditions.count
        case 3:
            return diagnosticReports.count
        case 4:
            return encounters.count
        case 5:
            return appointments.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
          return medicationRequestsTitle
        case 1:
            return observationsTitle
        case 2:
            return conditionsTitle
        case 3:
            return diagnosticReportTitle
        case 4:
            return encountersTitle
        case 5:
            return appointmentsTitle
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MedicationRequestCell.cellID, for: indexPath)
            let medRequest = meds[indexPath.row] as MedicationRequest
            cell.textLabel?.text = medRequest.status?.rawValue.capitalized
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ObservationCell.cellID, for: indexPath) as! ObservationCell
            let observation = observations[indexPath.row] as Observation
            cell.textLabel?.text = ""
            let code = observation.code?.text?.string ?? ""
            let value = observation.valueQuantity?.value ?? ""
            cell.textLabel?.text = code+": \(value)"
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ConditionCell.cellID, for: indexPath) as! ConditionCell
            let condition = self.conditions[indexPath.row] as Condition
            cell.textLabel?.text = condition.code?.text?.string
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: DiagnosticReportCell.cellID, for: indexPath) as! DiagnosticReportCell
            let diagnostic = self.diagnosticReports[indexPath.row] as DiagnosticReport
            cell.textLabel?.text = diagnostic.status?.rawValue
            return cell
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: EncounterCell.cellID, for: indexPath) as! EncounterCell
            let encounter = self.encounters[indexPath.row]
            cell.textLabel?.text = encounter.class?.code?.string
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AppointmentCell.cellID, for: indexPath) as! AppointmentCell
            let encounter = self.encounters[indexPath.row]
            cell.textLabel?.text = encounter.class?.code?.string
            return cell
        }
    }
}

