//
//
//  Created by DILINA PERERA on 21/05/2017.
//  Copyright © 2017 DILINA PERERA. All rights reserved.
//
import UIKit

class ScoreController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var bestScoreLabel: UILabel!
    @IBOutlet weak var totalScoreLabel: UILabel!

    private static let BEST_SCORE:String = "BEST_SCORE"
    private static let TOTAL_SCORE:String = "TOTAL_SCORE"
    
    var score:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scoreLabel.text = "\(self.score)"
        self.syncAndShowScore()    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Private Methods
    
    func syncAndShowScore() {
        
        var bestScore = UserDefaults.standard.integer(forKey: ScoreController.BEST_SCORE)
        var totalScore = UserDefaults.standard.integer(forKey: ScoreController.TOTAL_SCORE)
        
        bestScore = (self.score > bestScore) ? self.score: bestScore
        totalScore = totalScore + self.score
        
        UserDefaults.standard.set(bestScore, forKey: "BEST_SCORE")
        UserDefaults.standard.set(totalScore, forKey: "TOTAL_SCORE")
        UserDefaults.standard.synchronize()
        
        self.bestScoreLabel.text = "\(bestScore)"
        self.totalScoreLabel.text = "\(totalScore)"
    }

    @IBAction func shareAction(_ sender: UIButton) {
        let textToShare = "Wow!, I scored \(self.scoreLabel.text!) on Blast Stars! 😎"
        let myWebsite =  NSURL(string: "https://google.lk")!
        
        if let image = UIImage(named: "Icon_Share")  {
            
            let activityVC = UIActivityViewController(activityItems: [textToShare ,myWebsite, image], applicationActivities: [])
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.print, UIActivityType.openInIBooks]
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func tryAgainAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
