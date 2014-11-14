//
//  GameSelectViewController.swift
//  Sloth Drop
//
//  Created by Brian Doore on 11/8/14.
//  Copyright (c) 2014 Brian Doore. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class GameSelectViewController: UIViewController {
    
    
//    @IBAction func didTapClassic(sender: UIButton) {
//    
//        
//        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        
//        //let ClassicVC = storyboard.instantiateViewControllerWithIdentifier(<#identifier: String#>)
//        
//        let classicVC = self.storyboard?.instantiateViewControllerWithIdentifier("ClassicGameViewController") as UIViewController
//        
//        self.presentViewController(classicVC, animated: true, completion: nil)
//        
//        
//        //self.present
//
//    }
//
//    
//    @IBAction func didTapTimed(sender: UIButton) {
//        
//        
//        let timedVC = self.storyboard?.instantiateViewControllerWithIdentifier("TimedGameViewController") as UIViewController
//        
//        self.presentViewController(timedVC, animated: true, completion: nil)
//
//        
//    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "timed"){
            (segue.destinationViewController as TimedGameViewController).gameType = TimedGameViewController.GameType.Timed
        }
        else if (segue.identifier == "classic"){
            (segue.destinationViewController as TimedGameViewController).gameType = TimedGameViewController.GameType.Classic
        }
    }
    
}


