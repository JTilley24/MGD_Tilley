//
//  HelloWorldScene.m
//  Wizards Strike
//  MGD Term 1406
//  Created by Justin Tilley on 6/4/14.
//  Copyright Justin Tilley 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "HelloWorldScene.h"
#import "IntroScene.h"
#import "CCAnimation.h"
#import "PauseScene.h"
#import "GameOverScene.h"
// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation HelloWorldScene
{
    CCSprite *_cauldron;
    CCPhysicsNode *_physics;
    CCNode *bottom;
    CCSpriteBatchNode *spriteSheet;
    NSString *backImage;
    BOOL *scheduledAction;
    float fontSize;
    int lives;
    NSMutableArray *livesArray;
    int count;
    int score;
    int multiplier;
    CCLabelTTF *scoreLabel;
    OALSimpleAudio *audio;
    CCSprite *_darkCloud;
    CCActionAnimate *darkCloudAction;
    CCSprite *_blueCloud;
    CCActionAnimate *blueCloudAction;
    CCSprite *wizard;
    CCActionAnimate *wizardStartAction;
    CCActionAnimate *wizardEndAction;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (HelloWorldScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    //Check for iPad or iPhone
    NSInteger device = [[CCConfiguration sharedConfiguration] runningDevice];
    if(device == CCDeviceiPad){
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprite_sheet@2x.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprite_sheet@2x.plist"];
        fontSize = 18.0f;
        backImage = @"back@2x.png";
    }else{
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprite_sheet.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprite_sheet.plist"];
        fontSize = 10.0f;
        backImage = @"back.png";
    }
    
    [self addChild:spriteSheet];

    // Create Background Image
    CCSprite *background = [CCSprite spriteWithImageNamed:backImage];
    background.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    [self addChild:background];
    
    // Create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Pause ]" fontName:@"Verdana-Bold" fontSize:fontSize];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.85f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onPauseClicked:)];
    [self addChild:backButton];
    
    //Add Score Label
    score = 00;
    scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d",score] fontName:@"Verdana-Bold" fontSize:fontSize];
    scoreLabel.positionType = CCPositionTypeNormalized;
    scoreLabel.position = ccp(0.10f, 0.95f);
    [self addChild:scoreLabel];
    
    //Add Lives
    lives = 4;
    livesArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < lives; i++){
        CCSprite *heart = [CCSprite spriteWithImageNamed:@"heart.png"];
        heart.position = ccp((i+2)*heart.contentSize.width, self.contentSize.height - heart.contentSize.height * 3);
        [livesArray addObject:heart];
        [self addChild:heart];
    }
    
    //Create Wizard Sprite and Animation
    wizard = [CCSprite spriteWithImageNamed:@"wizard_01.png"];
    wizard.position = ccp(self.contentSize.width - wizard.contentSize.width/2 , wizard.contentSize.height/2);
    
    NSMutableArray *wizardFrames = [NSMutableArray array];
    
    for(int i = 1; i < 4; i++){
        NSString *sheetIndex = [NSString stringWithFormat:@"wizard_0%d.png", i];
        [wizardFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:sheetIndex]];
    }
    CCAnimation *wizardStartAnimate = [CCAnimation animationWithSpriteFrames:wizardFrames delay:0.2f];
    CCAnimation *wizardEndAnimate = [CCAnimation animationWithSpriteFrames:[[wizardFrames reverseObjectEnumerator] allObjects] delay:0.1f];
    wizardStartAction = [CCActionAnimate actionWithAnimation:wizardStartAnimate];
    wizardEndAction = [CCActionAnimate actionWithAnimation:wizardEndAnimate];
    [self addChild:wizard];
    
    //Setup Physics
    _physics = [CCPhysicsNode node];
    _physics.gravity = ccp(0,0);
    //_physics.debugDraw = YES;
    _physics.collisionDelegate = self;
    [self addChild:_physics];
   
    // Add Cauldron Sprite
    _cauldron = [CCSprite spriteWithImageNamed:@"Cauldron.png"];
    _cauldron.position  = ccp(self.contentSize.width/2, _cauldron.contentSize.height/2);
    _cauldron.physicsBody = [CCPhysicsBody bodyWithRect:CGRectMake(_cauldron.contentSize.width * 0.125, _cauldron.contentSize.height/1.6, _cauldron.contentSize.width * 0.75, _cauldron.contentSize.height/4) cornerRadius:0];
    _cauldron.physicsBody.type = CCPhysicsBodyTypeStatic;
    _cauldron.physicsBody.collisionGroup = @"cauldronGroup";
    _cauldron.physicsBody.collisionType = @"cauldronCollision";
    [_physics addChild:_cauldron];
   
    //Set Cloud Animations
    [self setCloudAnimate];
    
    //Setup Audio Effects
    audio = [OALSimpleAudio sharedInstance];
    [audio preloadEffect:@"poofSFX.mp3"];
    [audio preloadEffect:@"jingleSFX.mp3"];
    [audio preloadEffect:@"pumpkinSFX.mp3"];
    [audio preloadEffect:@"thunder.mp3"];
    
    //Set Bottom of Scene as a Physics Body for Collision
    CGRect bottomRect = CGRectMake(0, -10, self.contentSize.width, 10);
    bottom = [CCNode node];
    bottom.physicsBody = [CCPhysicsBody bodyWithRect:bottomRect cornerRadius:0];
    bottom.physicsBody.type = CCPhysicsBodyTypeStatic;
    bottom.physicsBody.collisionGroup = @"bottomGroup";
    bottom.physicsBody.collisionType = @"bottomCollision";
    [_physics addChild:bottom];
    
    //Set Multiplier
    multiplier = 1;
    
    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    //Set Timers for Adding Gems and Pumpkins
    if(!scheduledAction){
        [self schedule:@selector(addGems) interval:2.0f];
        [self schedule:@selector(addPumpkin) interval:6.25f];
    }
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //Check if Cauldron already moving
    if([_cauldron numberOfRunningActions] > 0){
        [_cauldron stopAllActions];
    }
    
    //Get Touch Location
    CGPoint touchLoc = [touch locationInNode:self];
    CGPoint moveLoc = CGPointMake(touchLoc.x, _cauldron.contentSize.height/2);
    if(touchLoc.x > self.contentSize.width - _cauldron.contentSize.width/2){
        moveLoc = CGPointMake(self.contentSize.width - _cauldron.contentSize.width/2, _cauldron.contentSize.height/2);
    }else if(touchLoc.x < _cauldron.contentSize.width/2){
        moveLoc = CGPointMake(_cauldron.contentSize.width/2, _cauldron.contentSize.height/2);
    }
    
    
    // Move Cauldron to touch location
    CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:1.0f position:moveLoc];
    [_cauldron runAction:actionMove];
}

//Add Gems to Scene
-(void) addGems
{
    scheduledAction = true;
    //Set Gem Sprite to Random Gem Image
    int randomGem = ((arc4random() % 5) + 1);
    NSString *gemName = [[NSString alloc] initWithFormat:@"Gems0%d.png", randomGem];
    CCSprite *gem = [CCSprite spriteWithImageNamed:gemName];
    
    //Get Random X-Position
    int minX = gem.contentSize.width/2;
    int maxX = self.contentSize.width - minX;
    int rangeX = maxX - minX;
    int randomX = ((arc4random() % rangeX) + minX);
   
    gem.position = CGPointMake(randomX, self.contentSize.height + gem.contentSize.height/2);
    gem.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:gem.contentSize.width/2.0f andCenter:gem.anchorPointInPoints];
    gem.physicsBody.collisionGroup = @"gemGroup";
    gem.physicsBody.collisionType = @"gemCollision";
    [_physics addChild:gem];
    
    //Move Gem to Bottom of Scene
    CCAction *gemMove = [CCActionMoveTo actionWithDuration:2.5f position:CGPointMake(randomX, -gem.contentSize.height/2)];
    CCAction *gemRemove = [CCActionRemove action];
    [gem runAction:[CCActionSequence actionWithArray:@[gemMove, gemRemove]]];
    
}

//Add Pumpkins to Scene
-(void) addPumpkin
{
    CCSprite *pumpkin = [CCSprite spriteWithImageNamed:@"pumpkin.png"];
    
    //Get Random X-Position
    int minX = pumpkin.contentSize.width/2;
    int maxX = self.contentSize.width - minX;
    int rangeX = maxX - minX;
    int randomX = ((arc4random() % rangeX) + minX);
    
    pumpkin.position = CGPointMake(randomX, self.contentSize.height + pumpkin.contentSize.height/2);
    pumpkin.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, pumpkin.contentSize} cornerRadius:10];
    pumpkin.physicsBody.collisionGroup = @"pumpkinGroup";
    pumpkin.physicsBody.collisionType = @"pumpkinCollision";
    [_physics addChild:pumpkin];
    
    //Move Pumpkin to Bottom of Scene
    CCAction *pumpkinMove = [CCActionMoveTo actionWithDuration:3.0f position:CGPointMake(randomX, -pumpkin.contentSize.height/2)];
    CCAction *pumpkinRemove = [CCActionRemove action];
    [pumpkin runAction:[CCActionSequence actionWithArray:@[pumpkinMove, pumpkinRemove]]];
}

//Collision Detection between Gems and Cauldron
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair gemCollision:(CCNode *)gem cauldronCollision:(CCNode *)cauldron
{
    [gem removeFromParent];
    [audio playEffect:@"poofSFX.mp3"];
    [audio playEffect:@"jingleSFX.mp3"];
    [self setMultiplier];
    [self setScore];
    if([_blueCloud numberOfRunningActions] < 1){
        [_blueCloud runAction:blueCloudAction];
    }
    
    return YES;
}

//Collision Detection between Pumpkin and Cauldron
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair pumpkinCollision:(CCNode *)pumpkin cauldronCollision:(CCNode *)cauldron
{
    [pumpkin removeFromParent];
    [audio playEffect:@"pumpkinSFX.mp3"];
    [self endMultiplier];
    [self removeLife];
    if([_darkCloud numberOfRunningActions] < 1){
        [_darkCloud runAction:darkCloudAction];
    }
    return YES;
}

//Collision Detection between Gems and Bottom of Scene
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair gemCollision:(CCNode *)nodeA bottomCollision:(CCNode *)nodeB
{
    [self endMultiplier];
    return YES;
}

//Set Score on Gem to Cauldron Collision
-(void)setScore
{
    int addScore = 75 * multiplier;
    score = score + addScore;
    NSString *multiplierString = [[NSString alloc] initWithFormat:@"x%d", multiplier];
    if(multiplier == 1){
        multiplierString = @"";
    }
    [scoreLabel setString:[NSString stringWithFormat:@"Score: %d %@", score, multiplierString]];
    if (score > 20000) {
        
        [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:@"win" withScore:[NSString stringWithFormat:@"Score: %d", score]]];
    }
}

//Set Multiplier
-(void)setMultiplier
{
    count++;
    if(count % 3 == 0){
        multiplier = count/3 + 1;
        //Show Bonus and Wizard Animation
        [self showBonus:[[NSString alloc] initWithFormat:@"x%d", multiplier]];
    }
}

//Remove Multiplier
-(void)endMultiplier
{
    count = 0;
    multiplier = 1;
    [scoreLabel setString:[NSString stringWithFormat:@"Score: %d", score]];
}

//Remove Life and Check if End of Game
-(void)removeLife
{
    lives--;
    [self removeChild:[livesArray lastObject] cleanup:YES];
    [livesArray removeLastObject];
    
    //End Game
    if(lives == 0){
        [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:@"lose" withScore:[NSString stringWithFormat:@"Score: %d", score]]];
    }
}

//Set Cloud Animations
-(void)setCloudAnimate
{
    //Dark Cloud Animation for Pumpkin Collision
    NSMutableArray *darkCloudFrames = [NSMutableArray array];
    for(int i = 1; i<31; i++){
        NSString *sheetIndex = [NSString stringWithFormat:@"dark_cloud-%d.png", i];
        if(i < 10){
            sheetIndex = [NSString stringWithFormat:@"dark_cloud-0%d.png", i];
        }
        [darkCloudFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:sheetIndex]];
    }
    
    _darkCloud = [CCSprite spriteWithImageNamed:@"dark_cloud-01.png"];
    _darkCloud.position = ccp(_cauldron.contentSize.width/2, _cauldron.contentSize.height - 10);
    CCAnimation *darkCloudAnimate = [CCAnimation animationWithSpriteFrames:darkCloudFrames delay:0.04f];
    [darkCloudAnimate setRestoreOriginalFrame:YES];
    darkCloudAction = [CCActionAnimate actionWithAnimation:darkCloudAnimate];
    [_cauldron addChild:_darkCloud];
   
    //Blue Cloud Animation for Gem Collision
    NSMutableArray *blueCloudFrames = [NSMutableArray array];
    for(int i = 1; i<32; i++){
        NSString *sheetIndex = [NSString stringWithFormat:@" blue_cloud-%d.png", i];
        if(i < 10){
            sheetIndex = [NSString stringWithFormat:@" blue_cloud-0%d.png", i];
        }
        [blueCloudFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:sheetIndex]];
    }
    
    _blueCloud = [CCSprite spriteWithImageNamed:@" blue_cloud-01.png"];
    _blueCloud.position = ccp(_cauldron.contentSize.width/2, _cauldron.contentSize.height - 10);
    CCAnimation *blueCloudAnimate = [CCAnimation animationWithSpriteFrames:blueCloudFrames delay:0.04f];
    [blueCloudAnimate setRestoreOriginalFrame:YES];
    blueCloudAction = [CCActionAnimate actionWithAnimation:blueCloudAnimate];
    [_cauldron addChild:_blueCloud];
}
//Show Bonus Label and Wizard Animation
-(void)showBonus: (NSString *) bonus{
    CCLabelTTF *bonusLabel = [CCLabelTTF labelWithString:bonus fontName:@"Verdana-Bold" fontSize:fontSize];
    bonusLabel.position = ccp(_cauldron.position.x, _cauldron.position.y + _cauldron.contentSize.height);
   
    CCActionCallBlock *bonusStart = [CCActionCallBlock actionWithBlock:^{
        [wizard runAction:wizardStartAction];
    }];
    CCActionCallBlock *bonusSound = [CCActionCallBlock actionWithBlock:^{
        [audio playEffect:@"thunder.mp3"];
    }];
    CCActionFadeIn *bonusFadeIn = [CCActionFadeTo actionWithDuration:0.2 opacity:0.5];
    CCAction *bonusMove = [CCActionMoveTo actionWithDuration:2.0f position:ccp(scoreLabel.contentSize.width, self.contentSize.height - scoreLabel.contentSize.height)];
    CCAction *bonusRemove = [CCActionRemove action];
    CCActionCallBlock *bonusEnd = [CCActionCallBlock actionWithBlock:^{
        [wizard runAction:wizardEndAction];
    }];
    CCActionSequence *bonusSeq = [CCActionSequence actionWithArray:@[bonusStart, bonusSound, bonusFadeIn, bonusMove, bonusRemove, bonusEnd]];
    
    [self addChild:bonusLabel];
    [bonusLabel runAction:bonusSeq];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------
//Display Pause Scene
- (void)onPauseClicked:(id)sender
{
    if(![self paused]){
        CCScene *pauseScene = [PauseScene scene];
        [[CCDirector sharedDirector] pushScene:pauseScene];
    }
}

// -----------------------------------------------------------------------
@end
