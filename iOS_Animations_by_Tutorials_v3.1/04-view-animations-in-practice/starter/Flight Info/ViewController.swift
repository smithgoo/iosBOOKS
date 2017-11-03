/*
 * Copyright (c) 2014-2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import QuartzCore

enum AnimationDirection: Int {
    case positive = 1
    case negative = -1
}

// A delay function
func delay(seconds: Double, completion: @escaping ()-> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

class ViewController: UIViewController {
    
    @IBOutlet var bgImageView: UIImageView!
    
    @IBOutlet var summaryIcon: UIImageView!
    @IBOutlet var summary: UILabel!
    
    @IBOutlet var flightNr: UILabel!
    @IBOutlet var gateNr: UILabel!
    @IBOutlet var departingFrom: UILabel!
    @IBOutlet var arrivingTo: UILabel!
    @IBOutlet var planeImage: UIImageView!
    
    @IBOutlet var flightStatus: UILabel!
    @IBOutlet var statusBanner: UIImageView!
    
    var snowView: SnowView!
    
    //MARK: view controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //adjust ui
        summary.addSubview(summaryIcon)
        summaryIcon.center.y = summary.frame.size.height/2
        
        //add the snow effect layer
        snowView = SnowView(frame: CGRect(x: -150, y:-100, width: 300, height: 50))
        let snowClipView = UIView(frame: view.frame.offsetBy(dx: 0, dy: 50))
        snowClipView.clipsToBounds = true
        snowClipView.addSubview(snowView)
        view.addSubview(snowClipView)
        
        //start rotating the flights
        changeFlight(to: londonToParis)
    }
    
    //MARK: custom methods
    
    func changeFlight(to data: FlightData, animated: Bool = false) {
        
        // populate the UI with the next flight's data
        summary.text = data.summary
        flightNr.text = data.flightNr
        gateNr.text = data.gateNr
        departingFrom.text = data.departingFrom
        arrivingTo.text = data.arrivingTo
        flightStatus.text = data.flightStatus
        
        if animated {
            fade(imageView: bgImageView,
                 toImage: UIImage(named: data.weatherImageName)!,
                 showEffects: data.showWeatherEffects)
            
            let direction: AnimationDirection = data.isTakingOff ? .positive : .negative
            cubeTransition(label: flightNr, text: data.flightNr, direction: direction)
            cubeTransition(label: gateNr, text: data.gateNr, direction: direction)
            
            let offsetDeparting = CGPoint(x: CGFloat(direction.rawValue) * 80.0, y: 0.0)
            moveLabel(label: departingFrom, text: data.departingFrom, offset: offsetDeparting)
            
            let offsetArriving = CGPoint(x: 0.0, y: CGFloat(direction.rawValue * 50))
            moveLabel(label: arrivingTo, text: data.arrivingTo, offset: offsetArriving)
            
            statusChanged(status: data.flightStatus, direction: direction)
        } else {
            bgImageView.image = UIImage(named: data.weatherImageName)
            snowView.isHidden = !data.showWeatherEffects
            flightNr.text = data.flightNr
            gateNr.text = data.gateNr
            departingFrom.text = data.departingFrom
            arrivingTo.text = data.arrivingTo
            flightStatus.text = data.flightStatus
        }
        
        // schedule next flight
        delay(seconds: 3.0) {
            self.changeFlight(to: data.isTakingOff ? parisToRome : londonToParis, animated: true)
        }
    }
    
    func fade(imageView: UIImageView, toImage: UIImage, showEffects: Bool) {
        UIView.transition(with: imageView, duration: 1.0, options: .transitionCrossDissolve, animations: {
            imageView.image = toImage
        }, completion: nil)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
            self.snowView.alpha = showEffects ? 1.0 : 0.0;
        }, completion: nil)
    }
    
    func cubeTransition(label: UILabel, text: String, direction: AnimationDirection) {
        let auxLabel = UILabel(frame: label.frame)
        auxLabel.text = text
        auxLabel.font = label.font
        auxLabel.textAlignment = label.textAlignment
        auxLabel.textColor = label.textColor
        auxLabel.backgroundColor = label.backgroundColor
        
        let offset = CGFloat(direction.rawValue) * label.frame.size.height / 2.0
        auxLabel.transform = CGAffineTransform(scaleX: 1.0, y: 0.1).concatenating(CGAffineTransform(translationX: 0.0, y: offset))
        label.superview?.addSubview(auxLabel)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut
            , animations: { 
                auxLabel.transform = .identity
                label.transform = CGAffineTransform(scaleX: 1.0, y: 0.1).concatenating(CGAffineTransform(translationX: 0.0, y: -offset))
        }, completion: { _ in
            label.text = auxLabel.text
            label.transform = .identity
            
            auxLabel.removeFromSuperview()
        });
    }
    
    func moveLabel(label: UILabel, text: String, offset: CGPoint) {
        let auxLabel = UILabel(frame: label.frame)
        auxLabel.text = text
        auxLabel.font = label.font
        auxLabel.textAlignment = label.textAlignment
        auxLabel.textColor = label.textColor
        auxLabel.backgroundColor = UIColor.clear
        
        auxLabel.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
        auxLabel.alpha = 0
        view.addSubview(auxLabel)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: { 
            label.transform = CGAffineTransform(translationX: offset.x, y:
                offset.y)
            label.alpha = 0.0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseIn, animations: { 
            auxLabel.transform = .identity
            auxLabel.alpha = 1.0
        }) { _ in
            auxLabel.removeFromSuperview()
            
            label.text = text
            label.alpha = 1.0
            label.transform = .identity
        }
    }
    
    func statusChanged(status:String, direction: AnimationDirection) {
        let auxLabel = UILabel(frame: flightStatus.frame)
        auxLabel.text = flightStatus.text
        auxLabel.font = flightStatus.font
        auxLabel.textAlignment = flightStatus.textAlignment
        auxLabel.textColor = flightStatus.textColor
        auxLabel.backgroundColor = UIColor.clear
        auxLabel.alpha = 0.0
        flightStatus.superview?.addSubview(auxLabel)
        
        let offset = CGFloat(direction.rawValue) * statusBanner.frame.size.height / 2.0
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: { 
            self.flightStatus.transform = CGAffineTransform(translationX: 0, y:
                offset)
            self.flightStatus.alpha = 0.0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseIn, animations: { 
            auxLabel.alpha = 1.0
            auxLabel.transform = CGAffineTransform(translationX: 0, y:offset)
        }) { _ in
            auxLabel.removeFromSuperview()
            
            self.flightStatus.text = status
            self.flightStatus.alpha = 1.0
            self.flightStatus.transform = .identity
        }
    }
}
