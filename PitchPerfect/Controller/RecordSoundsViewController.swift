//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Jon Sweeney on 3/15/21.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    // MARK: IBOutlets
    @IBOutlet weak var recordingLbl: UILabel!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var stopRecordingBtn: UIButton!
    
    // MARK: Audio Recorder: AVAudioRecorder
    var audioRecorder: AVAudioRecorder!
    
    // MARK: Override Methods

    // View will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stopRecordingBtn.isEnabled = false
    }

    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.SegueId.stopRecording {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }

    // MARK: Methods
    
    // Start Recording
    @IBAction func recordAudio(_ sender: UIButton) {
        configureRecordUI(recording: true)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))

        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)

        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    // Stop Recording
    @IBAction func stopRecording(_ sender: UIButton) {
        configureRecordUI(recording: false)
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    // Finish Recording
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: K.SegueId.stopRecording, sender: audioRecorder.url)
        } else {
            showAlert(K.AlertMsgs.RecordingFailedTitle, message: K.AlertMsgs.RecordingFailedMessage)
        }
    }
    
    // Config Record UI
    func configureRecordUI(recording: Bool) {
        stopRecordingBtn.isEnabled = recording // to enable or disable button
        recordBtn.isEnabled = !recording // opposite of state of stop btn
        recordingLbl.text = recording ? "Recording in Progress" : "Tap to Record"
    }
    
    // Show Alert to User
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: K.AlertMsgs.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

