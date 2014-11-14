//
//  TimedGameViewController.swift
//  Sloth Drop
//
//  Created by Brian Doore on 11/5/14.
//  Copyright (c) 2014 Brian Doore. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

//protocol GKGameCenterControllerDelegate {
//    
//}


class TimedGameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate { //, GKGameCenterControllerDelegate {
    
    var scene: GameScene!
    var swiftris:Swiftris!
    
    var panPointReference:CGPoint?
    
    var timePassed : Double = 0
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    var gameCenterEnabled = false
    var leaderboardIdentifier = ""
    
    @IBOutlet weak var timeBox: UIView!
    
    var gameType : GameType = GameType.Classic
    
    enum GameType: Int {
        case Classic
        case Timed
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.authenticateLocalPlayer()
        
        // Configure the view.
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        scene.tick = didTick
        
        swiftris = Swiftris()
        swiftris.delegate = self

        swiftris.beginGame()
        
        // Present the scene.
        skView.presentScene(scene)
        
        if (self.gameType == GameType.Classic){
            self.timeBox.hidden = true
        }
        else if (self.gameType == GameType.Timed){
            self.timeBox.hidden = false
        }

    }


    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        swiftris.rotateShape()

    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            // #3
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                // #4
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        swiftris.dropShape()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        if let swipeRec = gestureRecognizer as? UISwipeGestureRecognizer {
            if let panRec = otherGestureRecognizer as? UIPanGestureRecognizer {
                return true
            }
        } else if let panRec = gestureRecognizer as? UIPanGestureRecognizer {
            if let tapRec = otherGestureRecognizer as? UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    func authenticateLocalPlayer() {
        var localPlayer = GKLocalPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if viewController != nil {
                self.presentViewController(viewController, animated: true, completion: nil)
            } else {
                if localPlayer.authenticated {
                    self.gameCenterEnabled = true
                    
                    localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier : String!, error : NSError!) -> Void in
                        if error != nil {
                            println(error.localizedDescription)
                        } else {
                            self.leaderboardIdentifier = leaderboardIdentifier
                        }
                    })
                    
                } else {
                    self.gameCenterEnabled = false
                }
            }
        }
    }
    
    func reportScore() {
        var score = GKScore(leaderboardIdentifier: self.leaderboardIdentifier)
        
        score.value = Int64(swiftris.score)
        
        println(score.value)
        
        GKScore.reportScores([score], withCompletionHandler: {(error) -> Void in
            let alert = UIAlertView(title: "Updated",
                                    message: "Score updated",
                                    delegate: self,
                                    cancelButtonTitle: "Ok")
            alert.show()
        })
        
    }
    
    func showLeaderboardAndAchievements(shouldShowLeaderboard: Bool) {
        var gcViewController = GKGameCenterViewController()
        
        //gcViewController.gameCenterDelegate = self
        
        if(shouldShowLeaderboard) {
            //gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards
            
            
        }
    }
    
    
    
    func didTick() {
        
        swiftris.letShapeFall()
        
        if(scene.lastTick != nil) {
            timePassed += scene.lastTick!.timeIntervalSinceNow * -1000.0
            
            swiftris.timeLeft = Int(100.0 - timePassed)
        }
        
        //var timePassed = scene.lastTick!.timeIntervalSinceNow * -1000.0
        
        NSLog("%i", swiftris.timeLeft)
        
        timeLabel.text = String(swiftris.timeLeft)
        
        if (self.gameType == GameType.Timed){
            if (swiftris.timeLeft == 0){
                
                swiftris.dropShape()
                //swiftris.removeAllBlocks()
                swiftris.endGame()
            }
        }
        
        
        

        //if (timePassed > 1) {
            
           // NSLog("%f", timePassed)
            
            
            
            //swiftris.timeLeft -= 1
        //}

    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        if let fallingShape = newShapes.fallingShape {
            self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
            self.scene.movePreviewShape(fallingShape) {
                // #2
                self.view.userInteractionEnabled = true
                self.scene.startTicking()
            }
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"
        timeLabel.text = "\(swiftris.timeLeft)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        timePassed = 0
        
        // The following is false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(swiftris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftris: Swiftris) {
        view.userInteractionEnabled = false
        
        self.reportScore()
        
        scene.stopTicking()
        scene.playSound("gameover.mp3")
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
//            swiftris.beginGame()
            self.performSegueWithIdentifier("endGame", sender: self)
        }
        
        
    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        levelLabel.text = "\(swiftris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound("levelup.mp3")
        
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        
        scene.stopTicking()
        scene.redrawShape(swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
        scene.playSound("drop.mp3")

        
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        self.view.userInteractionEnabled = false
        // #1
        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                // #2
                self.gameShapeDidLand(swiftris)
            }
            scene.playSound("bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    // #3
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!) {}
    }
}
