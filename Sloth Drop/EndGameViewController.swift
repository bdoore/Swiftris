//
//  EndGameViewController.swift
//  Sloth Drop
//
//  Created by Brian Doore on 11/20/14.
//  Copyright (c) 2014 Brian Doore. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit


class EndGameViewController: UIViewController, GKGameCenterControllerDelegate{
    
    var leaderboardIdentifier = "Top_Classic_Scores"
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    var score: GKScore!
    
//    override init() {
//        super.init()
//        
//        scoreLabel.text = String(score.value)
//    }

//    required init(coder aDecoder: NSCoder) {
//        
//        super.init()
//        
//        scoreLabel.text = String(score.value)
//
//        //fatalError("init(coder:) has not been implemented")
//    }
//    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        
//        super.init()
//        
//        scoreLabel.text = String(score.value)
//        
//
//    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        scoreLabel.text = String(score.value)

        
        
        
    }
    

    @IBAction func gaemSelectPressed(sender: AnyObject) {
        
        var vc = self.presentingViewController
        
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            vc!.dismissViewControllerAnimated(false, completion: nil)
        })
    }
    
    @IBAction func leaderboardsPressed(sender: AnyObject) {
        
        self.showLeaderboardAndAchievements(true)
    }
    
    
    @IBAction func challengePressed(sender: UIButton) {
        
        self.challengeforScore(score)
        
    }
    
    
    
    func showLeaderboardAndAchievements(shouldShowLeaderboard: Bool) {
        var gcViewController = GKGameCenterViewController()
        
        gcViewController.gameCenterDelegate = self
        
        if(shouldShowLeaderboard) {
            gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards
            gcViewController.leaderboardIdentifier = self.leaderboardIdentifier
        } else {
            gcViewController.viewState = GKGameCenterViewControllerState.Achievements
        }
        
        self.presentViewController(gcViewController, animated: true, completion: nil)
    }
    
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        
        gameCenterViewController.dismissViewControllerAnimated(true, completion: {})
        
//        self.performSegueWithIdentifier("newGame", sender: self)
    }
    
    func challengeforScore (myScore : GKScore) {
        
        var friendScores = GKLeaderboard()
        
        friendScores.identifier = self.leaderboardIdentifier
        friendScores.playerScope = GKLeaderboardPlayerScope.FriendsOnly
        friendScores.range = NSMakeRange(1, 100)
        
        
        friendScores.loadScoresWithCompletionHandler { (objects: [AnyObject]!, error: NSError!) -> Void in
            var filter = NSPredicate(format: "value <\(myScore.value)", Int64())
            
            if (objects == nil){
                return
            }
            
            var lesserScores = objects.filter({ (score : AnyObject) -> Bool in
                var realScore : GKScore = score as GKScore
                
                if (realScore.value < myScore.value){
                    return true
                } else {
                    return false
                }
                
            })
            
            
            var playerArray : [GKPlayer] = []
            for otherScore : GKScore in lesserScores as [GKScore]{
                playerArray.append(otherScore.player)
            }
            
            
            var vc = myScore.challengeComposeControllerWithMessage("I challenge you to a duel", players: playerArray, completionHandler: { (vc : UIViewController!, yesOrNo: Bool, somethings : [AnyObject]!) -> Void in
                
                if (!yesOrNo){
                    vc.dismissViewControllerAnimated(true, completion: nil)
                }
                else{
                    println("hii")
                    vc.dismissViewControllerAnimated(true, completion: nil)
                }

            })
            self.presentViewController(vc, animated: true, completion: nil)
            
        }
    }




}