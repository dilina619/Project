//
//
//  Created by DILINA PERERA on 21/05/2017.
//  Copyright © 2017 DILINA PERERA. All rights reserved.
//
import UIKit
import FaveButton

@IBDesignable
class ItemView: UIView {
    
    @IBOutlet weak var ItemButton: UIButton!
    
    var view: UIView!
    var removeFromSuperViewClosure:((Int, Bool)->())!
    var markCount = 0
    var timer:Timer?
    
    let colors = [
        DotColors(first: color(0xef5350), second: color(0xef5350)),
        DotColors(first: color(0xef5350), second: color(0xef5350)),
        DotColors(first: color(0xef5350), second: color(0xef5350)),
        DotColors(first: color(0xef5350), second: color(0xef5350)),
        DotColors(first: color(0xef5350), second: color(0xef5350))
    ]
    
    @IBInspectable var itemImageName:String?{
        get {
            return self.ItemButton.title(for: .normal)
        }
        set(itemText) {
            self.ItemButton.setImage(UIImage(named:itemText!), for: .normal)
            if (self.markCount == -2) {
                self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.dismiss), userInfo: nil, repeats: false)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func tapAction(_ sender: UIButton) {
        self.isUserInteractionEnabled = false
        if (self.timer != nil) {
            self.timer!.invalidate()
        }
        self.removeFromSuperViewClosure(self.tag, true)
    }
    
    // MARK:- Private Methods
    
    func dismiss () {
        self.timer!.invalidate()
        self.isUserInteractionEnabled = false
        self.removeFromSuperViewClosure(self.tag, false)
        
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
}

extension ItemView: FaveButtonDelegate {
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool){
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]?{
        return (self.markCount == -2) ? self.colors: nil
    }
}

func color(_ rgbColor: Int) -> UIColor{
    return UIColor(
        red:   CGFloat((rgbColor & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbColor & 0x00FF00) >> 8 ) / 255.0,
        blue:  CGFloat((rgbColor & 0x0000FF) >> 0 ) / 255.0,
        alpha: CGFloat(1.0)
    )
}




