//
//  ViewController.swift
//  ClockApp
//
//  Created by Taylor Grafft on 2/5/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var backgroundAMPM: UIImageView!
    
    @IBOutlet weak var timeLeft: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var timerButton: UIButton!
    
    var audioPlayer = AVAudioPlayer()
    
    @IBAction func timerButtonTapped(_ sender: Any) {
        if timerButton.title(for: .normal) == "Stop Music" {
            audioPlayer.stop()
            timerButton.setTitle("Start Timer", for: .normal)
        } else {
            startTimer()
        }
    }
    
    private var countdownTimer: Timer?
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the current time
        getCurrentTime()
        
        let soundPath = Bundle.main.path(forResource: "alarm", ofType: "wav")
        let soundURL = URL(fileURLWithPath: soundPath!)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print(error)
        }


    }

    //fucntion to start the timer
    private func startTimer() {
        let selectedDate = datePicker.date
        let calendar = Calendar.current
        let selectedMinutes = calendar.component(.minute, from: selectedDate)
        let selectedSeconds = calendar.component(.second, from: selectedDate)
        let selectedHours = calendar.component(.hour, from: selectedDate)
        var targetTime = Double(selectedHours * 3600 + selectedMinutes * 60 + selectedSeconds)
        if targetTime <= 0 {
            timeLeft.text = "Timer Expired!"
            return
        }
        timerButton.isEnabled = false
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[weak self] _ in
            if let strongSelf = self {
                strongSelf.updateTimeLeft(targetTime: &targetTime)
            }
        }
    }


    private func updateTimeLeft(targetTime: inout Double) {
        targetTime -= 1.0
        if targetTime <= 0 {
            self.timeLeft.text = "Timer Expired!"
            audioPlayer.play()
            audioPlayer.numberOfLoops = -1
            self.timerButton.setTitle("Stop Music", for: .normal)
            timerButton.isEnabled = true
            countdownTimer?.invalidate()
        } else {
            let hours = Int(targetTime / 3600)
            let minutes = Int((targetTime.truncatingRemainder(dividingBy: 3600)) / 60)
            let seconds = Int((targetTime.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60))
            self.timeLeft.text = String(format: "Time Remaining: %02d:%02d:%02d", hours, minutes, seconds)
        }
    }


    
    private func getCurrentTime() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.currentTime), userInfo: nil, repeats: true)
    }

    @objc func currentTime() {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        //Change background based off AM or PM
        self.backgroundAMPM.backgroundColor = hour >= 12 ? UIColor.black : UIColor.white
        //Also set the UIDatePicker's background and text
        self.datePicker.backgroundColor = hour >= 12 ? UIColor.black : UIColor.white
        self.datePicker.setValue(hour >= 12 ? UIColor.white : UIColor.black, forKey: "textColor")
        
        //Change text labels to white so you can see them
        if hour >= 12 {
            self.currentTimeLabel.textColor = .white
            self.timeLeft.textColor = .white
            //self.view.backgroundColor = .black
        } else {
            self.currentTimeLabel.textColor = .black
            self.timeLeft.textColor = .black
            //self.view.backgroundColor = .white
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, dd MMM yyyy HH:mm:ss"
        currentTimeLabel.text = formatter.string(from: Date())
    }
    
    
}
