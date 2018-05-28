//
//
//  Created by DILINA PERERA on 21/05/2017.
//  Copyright © 2017 DILINA PERERA. All rights reserved.
//
import UIKit
import AVFoundation
import AudioToolbox

class HomeController: UIViewController {

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var timmerCountLabel: UILabel!
    @IBOutlet weak var drawingView: UIView!
    @IBOutlet weak var startView: UIView!
    
    var timer:Timer!
    var itemViews:[ItemView] = [ItemView]()
    var itemsCount = 0
    var player: AVAudioPlayer!
    var score:Int = 0
    var gameTimer:Timer!
    var gameTimeCount = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        self.startView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.startAction(recognizer:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.clearAll()
        self.startView.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    // MARK:- Private Methods
    func clearAll () {
        self.timmerCountLabel.text = "20"
        self.totalLabel.text = "0"
        self.itemsCount = 0
        self.score = 0
        self.gameTimeCount = 20
        
        for item in self.itemViews {
            item.removeFromSuperview()
        }
        
        if (self.drawingView.subviews.count > 0) {
            for view in self.drawingView.subviews {
                view.removeFromSuperview()
            }
        }
        self.itemViews.removeAll()
    }
    
    func startAction(recognizer:UITapGestureRecognizer) {
        self.setView(view: self.startView, hidden: true)
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {() -> Void in
            view.isHidden = hidden
            }, completion: { _ in
    
                self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.displayItems), userInfo: nil, repeats: true)
                self.gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.globalTimmerAction), userInfo: nil, repeats: true)
        })
    }
    
    func playMusic(name:String) {
        if let path = Bundle.main.path(forResource:name, ofType:nil) {
            let url = URL(fileURLWithPath: path)
            do {
                let sound = try AVAudioPlayer(contentsOf: url)
                player = sound
                sound.play()
            } catch {
                
                print("couldn't load file")
            }
        }
    }
    
    func randomRect() ->CGRect {
        let width = self.drawingView.frame.size.width
        let height = self.drawingView.frame.size.height
        
        let x = arc4random_uniform(UInt32(width - 70)) + 0;
        let y = arc4random_uniform(UInt32(height - 70)) + 0;
        
        return CGRect(x: Int(x), y: Int(y), width: 70, height: 70)
    }
    
    func isConflictWithOthers(rect:CGRect) ->Bool {
        var isConflict = false
        for itemView in self.itemViews {
            if (rect.intersects(itemView.frame)) {
                isConflict = true
                break
            }
        }
        
        return isConflict
    }
    
    func globalTimmerAction() {
        self.gameTimeCount = self.gameTimeCount - 1
        DispatchQueue.main.async {
            self.timmerCountLabel.text = "\(self.gameTimeCount)"
        }

        if (self.gameTimeCount == 0) {
            self.timer.invalidate()
            self.gameTimer.invalidate()
            
            let controller:ScoreController = self.storyboard?.instantiateViewController(withIdentifier: "ID_ScoreController") as! ScoreController
            controller.score = self.score
            
            self.playMusic(name: "GameOver.wav")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func displayItems() {
        if (self.itemViews.count > 7) {
            return
        }
        let randomRect = self.randomRect()
        if (self.isConflictWithOthers(rect: randomRect)) {
            self.displayItems()
        }
        else {
            let item = ItemView(frame: randomRect)
            item.tag = itemsCount
            
            item.removeFromSuperViewClosure = { (tag, isCount) in
                if  let item = self.findItem(itemId: tag) {
                    if (isCount) {
                        self.score = self.score + item.markCount
                        self.score = (self.score > 0) ? self.score: 0
                        self.totalLabel.text = "\(self.score)"
                        var musicFileName:String = ""
                        if (item.markCount == -2) {
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                            musicFileName = "Pop1.mp3"
                        }
                        else {
                            musicFileName = "Pop2.mp3"
                        }
                        self.playMusic(name:musicFileName)
                    }
                    self.itemViews.remove(object: item)
                }
            }
            
            self.findItemName(success: { (imageName, imageMark) in
                item.markCount = imageMark
                item.itemImageName = imageName
            })

            itemsCount = itemsCount + 1
            DispatchQueue.main.async {
               self.drawingView.addSubview(item)
            }
            
            item.playAnimation()
            self.itemViews.append(item)
        }
    }

    func findItemName(success:(String, Int)->()) {
        let number = arc4random_uniform(UInt32(5)) + 1;
        var imageName = "Star"
        var marksCount = 0
        
        switch number {
         case 1:
            marksCount = 1
            break
         case 2:
            marksCount = 1
            break
            
         case 3:
            marksCount = -2
            imageName = "Bomb"
            break
            
         case 4:
            marksCount = 1
            break
            
         case 5:
            marksCount = 1
            break
            
        default: break
            
        }

        success(imageName, marksCount)
    }
    
    func findItem(itemId:Int) -> ItemView? {
        var item:ItemView?
        let itemPredicate = NSPredicate(format: "tag = %i", itemId)
        let filteredItemsViews = (self.itemViews as NSArray).filtered(using: itemPredicate) as! [ItemView]
        
        if (filteredItemsViews.count > 0) {
            item = filteredItemsViews.first
        }
        
        return item
    }
}

extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

extension UIView {
    func playAnimation() {
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "opacity");
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.1
        
        self.layer.add(animation, forKey: nil)
    }
}
