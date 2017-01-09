import UIKit
import AVFoundation

class FavoriteBtnViewController: UIViewController {
    
    override func viewDidLoad() {
        let width = (self.view.frame.width - 44) / 4
        let x = width / 2
        let y = self.view.frame.height / 2 - 22
        
        var btnRect = CGRect(x: x, y: y, width: 44, height: 44)
        // star button
        
        let starButton = DOFavoriteButton(frame: btnRect, image: UIImage(named: "star"))
        starButton.addTarget(self, action: #selector(FavoriteBtnViewController.tappedButton), for: .touchUpInside)
        self.view.addSubview(starButton)
        btnRect.origin.x += width
        
        // heart button
        let heartButton = DOFavoriteButton(frame: btnRect, image: UIImage(named: "heart"))
        heartButton.imageColorOn = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        heartButton.circleColor = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        heartButton.lineColor = UIColor(red: 226/255, green: 96/255, blue: 96/255, alpha: 1.0)
        heartButton.addTarget(self, action: #selector(FavoriteBtnViewController.tappedButton), for: .touchUpInside)
        self.view.addSubview(heartButton)
        btnRect.origin.x += width
        
        // like button
        let likeButton = DOFavoriteButton(frame: btnRect, image: UIImage(named: "like"))
        likeButton.imageColorOn = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
        likeButton.circleColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
        likeButton.lineColor = UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1.0)
        likeButton.addTarget(self, action: #selector(FavoriteBtnViewController.tappedButton), for: .touchUpInside)
        self.view.addSubview(likeButton)
        btnRect.origin.x += width
        
        // smile button
        let smileButton = DOFavoriteButton(frame: btnRect
            , image: UIImage(named: "smile"))
        smileButton.imageColorOn = UIColor(red: 45/255, green: 204/255, blue: 112/255, alpha: 1.0)
        smileButton.circleColor = UIColor(red: 45/255, green: 204/255, blue: 112/255, alpha: 1.0)
        smileButton.lineColor = UIColor(red: 45/255, green: 195/255, blue: 106/255, alpha: 1.0)
        smileButton.addTarget(self, action: #selector(FavoriteBtnViewController.tappedButton), for: .touchUpInside)
        self.view.addSubview(smileButton)
        
//        self.heartButton.addTarget(self, action: #selector(ViewController.tappedButton), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedButton(sender: DOFavoriteButton) {
        if sender.isSelected {
            sender.deselect()
        } else {
            sender.select()
        }
    }
}
