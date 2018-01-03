//
//  SmartAPI.swift
//  SmartFhirDemo
//
//  Created by Fede on 29/12/2017.
//  Copyright © 2017 Lateral View. All rights reserved.
//

import UIKit
import SMART

class SmartAPI: NSObject {
    
    static let shared = SmartAPI()
    
    let smart : Client
    
    let STU3SandboxURL = "https://sb-fhir-stu3.smarthealthit.org/smartstu3/open"
    let redirectURL = "smartfhirdemo://callback"
    let clientId = "39613a79-c2ca-4336-a6e1-e18660df985c"
    
    private struct Keys {
        static let clientId = "client_id"
        static let redirect = "redirect"
    }
    
    override init() {
        // Create the client
        smart = Client(
            baseURL: URL(string: STU3SandboxURL)!,
            settings: [
                Keys.clientId: clientId,
                Keys.redirect: redirectURL
                ])
        
        //Set client auth properties
        smart.authProperties.granularity = .patientSelectNative
        smart.authProperties.embedded = true
    }
    
    //MARK : - Auth
    
    func auth(completion: @escaping (_ patient : Patient?, _ error : Error?) -> Void) {
        smart.authorize { (patient, error) in
            completion(patient, error)
        }
    }
    
    //MARK : - MedicationRequest
    
    func getMedicationRequests(patient: Patient, completion: @escaping (_ medicationRequests : [MedicationRequest]?, _ error : Error?) -> Void) {
        
        //Search medication requests for the selected patient
        MedicationRequest.search(["patient": patient.id!.string])
            .perform(smart.server, callback: { (bundle, error) in
                if nil != error {
                    //Error
                    print("Error while trying to get medication requests")
                    completion(nil, error)
                }
                else {
                    var medRequestsArray = [MedicationRequest]()
                    //Success
                    let medRequests = bundle?.entry?
                        .filter() { return $0.resource is MedicationRequest }
                        .map() { return $0.resource as! MedicationRequest }
                    //Append medication requests
                    if medRequests != nil {
                        for med in medRequests! {
                            medRequestsArray.append(med)
                        }
                    }
                    completion(medRequestsArray, nil)
                }
            })
    }
    
    //MARK : - Medication
    
    func getMedication(medicationRequest: MedicationRequest, completion : @escaping (_ medication : Medication?, _ error : Error?) -> Void) {
        
        Medication.search(["_id" : medicationRequest.medicationReference!.reference!.string]).perform(SmartAPI.shared.smart.server) { (bundle, error) in
            if error != nil {
                //Error
                print("Error while trying to get medication")
                completion(nil, error)
            } else {
                let med = bundle?.entry?
                    .filter() { return $0.resource is Medication }
                    .map() { return $0.resource as! Medication }
                completion(med?.first, nil)
            }
        }
    }
    
}
