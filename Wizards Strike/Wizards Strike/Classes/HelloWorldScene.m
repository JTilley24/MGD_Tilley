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

// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation HelloWorldScene
{
    CCSprite *_cauldron;
    CCPhysicsNode *_physics;
    int score;
    CCLabelTTF *scoreLabel;
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
    
    // Create Background Image
    CCSprite *background = [CCSprite spriteWithImageNamed:@"back2.png"];
    background.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    [self addChild:background];
    
    // Create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Verdana-Bold" fontSize:18.0f];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.85f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];
    
    //Add Score Label
    score = 00;
    scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d",score] fontName:@"Verdana-Bold" fontSize:18.0f];
    scoreLabel.positionType = CCPositionTypeNormalized;
    scoreLabel.position = ccp(0.15f, 0.95f);
    [self addChild:scoreLabel];
    
    //Create Wizard Sprite
    CCSprite *wizard = [CCSprite spriteWithImageNamed:@"wizard.png"];
    wizard.position = ccp(self.contentSize.width - wizard.contentSize.width/2 , wizard.contentSize.height/2);
    [self addChild:wizard];
    
    //Setup Physics
    _physics = [CCPhysicsNode node];
    _physics.gravity = ccp(0,0);
    _physics.collisionDelegate = self;
    [self addChild:_physics];
    
    // Add Cauldron Sprite
    _cauldron = [CCSprite spriteWithImageNamed:@"Cauldron.png"];
    _cauldron.position  = ccp(self.contentSize.width/2, _cauldron.contentSize.height/2);
    _cauldron.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _cauldron.contentSize} cornerRadius:0];
    _cauldron.physicsBody.type = CCPhysicsBodyTypeStatic;
    _cauldron.physicsBody.collisionGroup = @"cauldronGroup";
    _cauldron.physicsBody.collisionType = @"cauldronCollision";
    [_physics addChild:_cauldron];
   
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
    [self schedule:@selector(addGems) interval:2.0f];
    [self schedule:@selector(addPumpkin) interval:6.0f];
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
    CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    
    // Move Cauldron to touch location
    CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:1.0f position:moveLoc];
    [_cauldron runAction:actionMove];
}

//Add Gems to Scene
-(void) addGems
{
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
    [[OALSimpleAudio sharedInstance] playEffect:@"poofSFX.mp3"];
    [[OALSimpleAudio sharedInstance] playEffect:@"jingleSFX.mp3"];
    [self setScore];
    return YES;
}

//Collision Detection between Pumpkin and Cauldron
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair pumpkinCollision:(CCNode *)pumpkin cauldronCollision:(CCNode *)cauldron
{
    [pumpkin removeFromParent];
    [[OALSimpleAudio sharedInstance] playEffect:@"pumpkinSFX.mp3"];
    
    return YES;
}

//Set Score on Gem to Cauldron Collision
-(void)setScore
{
    score = score + 75;
    [scoreLabel setString:[NSString stringWithFormat:@"Score: %d", score]];
}
// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

// -----------------------------------------------------------------------
@end
