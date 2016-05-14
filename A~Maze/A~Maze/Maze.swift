//
//  Maze.swift
//  A~Maze
//
//  Created by Hidekazu Shidara on 5/24/15.
//  Copyright (c) 2015 Hidekazu Shidara. All rights reserved.
//

import UIKit
import Foundation
import SpriteKit

class Maze: SKScene {
    // Main Character.
    let runner = SKSpriteNode(imageNamed: "Spaceship")

    override func didMoveToView(view: SKView)
    {
        // Affects how fast the wall falls. Affects the gravity.
        self.physicsWorld.gravity           = CGVectorMake(0, -0.15)
        self.createRunner()
        self.routeA()

    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        let touch                   = touches.anyObject()! as UITouch
        let location                = touch.locationInNode(self)
        runner.position             = location
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent)
    {
        let touch                   = touches.anyObject()! as UITouch
        let location                = touch.locationInNode(self)
        runner.position             = location
    }
    
    // Creates the maze runner.
    func createRunner()
    {
        runner.setScale(0.15)
        runner.position                         = CGPointMake(200, 200)
        runner.name                             = "RunnerNode"
        runner.physicsBody                      = SKPhysicsBody(circleOfRadius: runner.size.width/2)
        
        runner.physicsBody?.usesPreciseCollisionDetection = true
        
        runner.physicsBody?.mass                = 1000.0
        runner.physicsBody?.density             = 100.0
        runner.physicsBody?.dynamic             = true // Will not change position
        runner.physicsBody?.pinned              = false
        runner.physicsBody?.allowsRotation      = false
        runner.physicsBody?.affectedByGravity   = false // Will not be affected by the gravitational field.
        
        self.addChild(runner)
    }
    
    // Creates the vertical wall.
    func createVerticalWall(xPlacement: CGFloat, yPlacement: CGFloat)-> SKSpriteNode // Returns the newly created vertical wall.
    {
        let wallSize                = CGSizeMake(35,250)
        let wallColor               = UIColor.darkGrayColor()
        let verticalWall            = SKSpriteNode(color: wallColor, size: wallSize)
        let verticalWallSize        = CGSizeMake(35, 250)  // Cuz the rectangleofsize needs a CGSize.
        
        verticalWall.position       = CGPointMake(xPlacement, yPlacement)
        verticalWall.name           = "verticalWall"
        verticalWall.physicsBody    = SKPhysicsBody(rectangleOfSize: verticalWallSize)
        
        verticalWall.physicsBody?.mass                              = 100000.0  // Makes it hard to move.
        verticalWall.physicsBody?.density                           = 100000.0
        verticalWall.physicsBody?.allowsRotation                    = false
        verticalWall.physicsBody?.usesPreciseCollisionDetection     = true
        
        self.addChild(verticalWall)
        return verticalWall
    }
    
    //Creates the horizontal wall.
    func createHorizontalWall(xPlacement: CGFloat, yPlacement: CGFloat)-> SKSpriteNode // Returns the newly created horizontal wall.
    {
        let wallSize                    = CGSizeMake(250,20)
        let wallColor                   = UIColor.darkGrayColor()
        let horizontalWall              = SKSpriteNode(color: wallColor, size: wallSize)
        let horizontalWallSize          = CGSizeMake(250, 20)

        horizontalWall.position         = CGPointMake(xPlacement, yPlacement)
        horizontalWall.name             = "HorizontalWall"
        horizontalWall.physicsBody      = SKPhysicsBody(rectangleOfSize: horizontalWallSize)
        
        horizontalWall.physicsBody?.density                         = 10000000.0
        horizontalWall.physicsBody?.mass                            = 10000000.0
        horizontalWall.physicsBody?.allowsRotation                  = false
        horizontalWall.physicsBody?.usesPreciseCollisionDetection   = true
        
        self.addChild(horizontalWall)
        return horizontalWall
    }
    // HorizontalWall.position = CGPointMake(self.xScale + 1, self.yScale + 1)
    
    // Decides when game ends. 
    // Collision handling in the sides of the screen too.
    override func update(currentTime: CFTimeInterval)// Called before each frame is rendered.
    {
        if(runner.position.y <= 0.0)    // Prints out a label that says game over. Freezes everything.
        {
            println("Game over.")
        }
        if(runner.position.x <= 0.0 || runner.position.x >= 1000.0)
        {
            println("Out of bounds")
        }
    }
    
    func routeA()
    {
        let actionSequence = SKAction.sequence([
            SKAction.runBlock({(self.patternOne())}),
            SKAction.waitForDuration(5.0),
            SKAction.runBlock({(self.patternOne())})
            ])
        runAction(actionSequence)

    }
    
    // Create a pattern.
    func patternOne()
    {
        self.createHorizontalWall(512 + 125, yPlacement: self.size.height + 135 + 125)
        self.createHorizontalWall(512 - 125, yPlacement: self.size.height + 135 + 125)
        self.createVerticalWall(280, yPlacement: self.size.height + 125)
        self.createVerticalWall(512.5, yPlacement: self.size.height + 125 - 100)
        self.createVerticalWall(745, yPlacement: self.size.height + 125)
    }
    func patternTwo()
    {
        
    }
    
}
