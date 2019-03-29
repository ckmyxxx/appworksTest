//
//  ViewController.swift
//  awsTest
//
//  Created by Huang YenHan on 2019/3/29.
//  Copyright © 2019 HuangYenHan. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    var player : AVPlayer?
    let wrongUrlAlert = UIAlertController(title: "錯誤", message: "請輸入正確網址", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    var btnArr: [UIButton] = []
    var layer : AVPlayerLayer?
    var token : Any?
    @IBOutlet weak var userInputUrl: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var videoSlider: UISlider!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var finishLabel: UILabel!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var volumeBtn: UIButton!
    @IBOutlet weak var backwardBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var fullScreenBtn: UIButton!
    @IBOutlet weak var noVideoLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        btnArr = [volumeBtn, backwardBtn, playBtn, forwardBtn, fullScreenBtn]
        
        wrongUrlAlert.addAction(okAction)
        
        searchBtnSetting()
    
        addDismissKeyboardSetting()
  
        if UIDevice.current.orientation.isLandscape {
            
            fullScreenBtn.isSelected = true
            
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
            changeColor()

        }
        
    }
    
    @IBAction func videoSlidering(_ sender: UISlider) {
        
        updateSliderTime(sliderValue: videoSlider.value)
        
    }
    
    func addDismissKeyboardSetting(){
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func volumeBtnPressed(_ sender: UIButton) {
        
        volumeBtn.isSelected = !volumeBtn.isSelected
        
        if let player = player {
            
        player.isMuted = !player.isMuted
            
        }
    }
    
    @IBAction func backwardBtnPressed(_ sender: UIButton) {
        
        backwardBtn.isSelected = !backwardBtn.isSelected
        
        updateSliderTime(sliderValue: videoSlider.value - 10)
        
    }
    
    @IBAction func playBtnPressed(_ sender: UIButton) {
        
        playBtn.isSelected = !playBtn.isSelected

        if playBtn.isSelected {
            
            player?.play()
            
        } else {
            
            player?.pause()
            
        }
        
    }
    @IBAction func forwardBtnPressed(_ sender: UIButton) {
        
        forwardBtn.isSelected = !forwardBtn.isSelected
        
        updateSliderTime(sliderValue: videoSlider.value + 10)
        
    }
    
    @IBAction func fullScreenBtnPressed(_ sender: UIButton) {
        
        fullScreenBtn.isSelected = !fullScreenBtn.isSelected
    
        if UIDevice.current.orientation.isPortrait {
            
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            
        } else {
            
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }

        changeColor()
        
    }
    
    @IBAction func searchBtnPressed(_ sender: UIButton) {
        
        let userUrl = userInputUrl?.text
        
        if verifyUrl(urlString: userUrl) {
            
            let url = URL(string: userUrl!)
            
            self.player = AVPlayer(url: url!)
            
            layer = AVPlayerLayer(player: self.player)
            
            if let layer = layer {
                
                layer.frame = playView.bounds
                
                layer.removeFromSuperlayer()
                
                playView.layer.addSublayer(layer)
                
                updatePlayerUI()
                
                addPlayerObserver()
                
                userInputUrl.resignFirstResponder()
                
                playBtn.isSelected = true
                
                player?.play()
            }
            
        } else {

            present(wrongUrlAlert, animated: true, completion: nil)
        }

    }
    
    func verifyUrl (urlString: String?) -> Bool {
        
        if let urlString = urlString {
            
            if let url = NSURL(string: urlString) {
                
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        
        return false
    }
    
    func updateSliderTime(sliderValue: Float){
        
        let seconds = Int64(sliderValue)
        
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
      
        player?.seek(to: targetTime)
        
        currentLabel.text = formatConversion(time: Float64(seconds))
    }

    
    func searchBtnSetting(){
        
        searchBtn.layer.cornerRadius = 10
        
        searchBtn.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        
        searchBtn.layer.borderWidth = 1
    }
    
    func changeColor() {
        
        if fullScreenBtn.isSelected {
            
            currentLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            finishLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            playView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            for btn in btnArr {
                
                btn.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
            }
            
        } else {
            
            currentLabel.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            
            finishLabel.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            
            playView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            
            for btn in btnArr {
                
                btn.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                
            }
            
        }
        
    }
    
    func addPlayerObserver(){
        
        token = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self](CMTime) in
            
            if self?.player?.currentItem?.status == .readyToPlay {
                
                let currentTime = CMTimeGetSeconds((self?.player?.currentTime())!)
                
                self?.videoSlider.value = Float(currentTime)
                
                self?.currentLabel.text = self?.formatConversion(time: currentTime)
                
            }
            
        })
    }
    
    func updatePlayerUI() {
        
        if let duration = player?.currentItem?.asset.duration {
        
        let seconds = CMTimeGetSeconds(duration)
       
        finishLabel.text = formatConversion(time: seconds)
            
        videoSlider.minimumValue = 0
       
        videoSlider.maximumValue = Float(seconds)
       
        videoSlider.isContinuous = true
            
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if (UIDevice.current.orientation.isLandscape) {

            fullScreenBtn.isSelected = true
            
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
            DispatchQueue.main.async {
                
                self.layer?.frame = self.playView.frame
                
                self.layer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                
                self.view.layoutIfNeeded()
      
            }
            
        } else {
            
            fullScreenBtn.isSelected = false
            
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
             DispatchQueue.main.async {
                
                self.layer?.frame = self.playView.frame
                
                self.layer?.frame.origin = self.playView.bounds.origin
                
                self.layer?.videoGravity = AVLayerVideoGravity.resizeAspect
                
                self.view.layoutIfNeeded()
                
            }
        }
        
        changeColor()
        
    }

}

extension ViewController {
    
    func formatConversion(time:Float64) -> String {
        
        let songLength = Int(time)
        
        let minutes = Int(songLength / 60) // 求 songLength 的商，為分鐘數
        
        let seconds = Int(songLength % 60) // 求 songLength 的餘數，為秒數
        
        var time = ""
        
        if minutes < 10 {
            
            time = "0\(minutes):"
            
        } else {
            
            time = "\(minutes)"
            
        }
        if seconds < 10 {
            
            time += "0\(seconds)"
            
        } else {
            
            time += "\(seconds)"
            
        }
        
        return time
    }
}
