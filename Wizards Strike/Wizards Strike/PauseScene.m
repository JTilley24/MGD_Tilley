//
//  PauseScene.m
//  Wizards Strike
//
//  Created by Justin Tilley on 6/19/14.
//  Copyright 2014 Justin Tilley. All rights reserved.
//

#import "PauseScene.h"
#import "IntroScene.h"

@implementation PauseScene
{
    CCSpriteBatchNode *spriteSheet;
}
+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    PauseScene *pauseLayer = [PauseScene node];
    [scene addChild: pauseLayer];
    return scene;
}

-(id) init
{
    if((self = [super init])){
        //Add Pause Label
        CCLabelTTF *pausedLabel = [CCLabelTTF labelWithString:@"PAUSED" fontName:@"Verdana-Bold" fontSize:20.0f];
        pausedLabel.positionType = CCPositionTypeNormalized;
        pausedLabel.position = ccp(0.5f, 0.85f);
        [self addChild:pausedLabel];
       
        //Check if iPad or iPhone
        NSInteger device = [[CCConfiguration sharedConfiguration] runningDevice];
        if(device == CCDeviceiPad){
            spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites@2x.png"];
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites@2x.plist"];
        }else{
            spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png"];
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
        }
        
        //Add Resume Button
        CCButton *resumeButton = [CCButton buttonWithTitle:@"" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"resume-button.png"]];
        resumeButton.position = ccp(self.contentSize.width/2, self.contentSize.height/2 + resumeButton.contentSize.height);
        [resumeButton setTarget:self selector:@selector(resumePressed)];
        [self addChild:resumeButton];
        
        //Add Quit Button
        CCButton *quitButton = [CCButton buttonWithTitle:@"" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"quit-button.png"]];
        quitButton.position = ccp(self.contentSize.width/2, self.contentSize.height/2 - quitButton.contentSize.height);
        [quitButton setTarget:self selector:@selector(quitPressed)];
        [self addChild:quitButton];
        
    }
    return self;
}

//Back to Main Menu
-(void) quitPressed
{
    CCScene *intro = [IntroScene scene];
    [[CCDirector sharedDirector] replaceScene:intro];
}

//Return to Game
-(void) resumePressed
{
    [[CCDirector sharedDirector] popScene];
}

@end
