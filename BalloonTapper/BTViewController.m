//
//  BTViewController.m
//  BalloonTapper
//
//  Created by Gabriele Petronella on 10/19/12.
//  Copyright (c) 2012 HCI. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#import "BTViewController.h"
#import "BTSession.h"
#import "BTTap.h"
#import "BTAPI.h"

#define BALLOON_RADIUS 200
#define ANIMATED NO
#define ANIMATION_DURATION 0.2f
#define GAME_LENGTH INFINITY

#define TAP_MODE_LIMIT 20
#define INFLATE_MODE_LIMIT MIN(self.view.frame.size.height, self.view.frame.size.width)

#define INFLATE_FACTOR 1.05f
#define DEFLATE_FACTOR 1.0125f
#define EXPLOSION_MULTIPLIER 4



@interface BTViewController ()
@property (nonatomic, strong) UIView * baloon;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, strong) BTSession * session;
@property (nonatomic, strong) AVAudioPlayer * avSound;
@property (nonatomic, strong) NSTimer * deflateTimer;
@property (nonatomic, assign) GameMode gameMode;
@end

@implementation BTViewController {
    CGFloat _currentInflation;
}

- (id)initWithGameMode:(GameMode)gameMode {
    if (self = [super init]) {
        _gameMode = gameMode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.restartButton.hidden = YES;
    
    if (self.gameMode == GameModeInflate) {
        _currentInflation = 1.0f;
        self.deflateTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                             target:self
                                                           selector:@selector(deflateBalloon)
                                                           userInfo:nil
                                                            repeats:YES];
    }
}


- (void)startGame {
    [[BTAPI sharedInstance] startSessionCompletion:^(BTSession *newSession) {
        self.session = newSession;
        [self startAnimation];
    } failure:^(NSError * error) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Couldn't reach the server"
                                                        delegate:nil
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil, nil];
        [alert show];
        self.session = [BTSession session];
        [self startAnimation];
    }];
}

- (void)startAnimation {
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         for (UILabel * label in self.labels) {
                             label.alpha = 0.0f;
                         }
                         for (UIButton * button in self.buttons) {
                             button.alpha = 0.0f;
                         }
                     } completion:^(BOOL finished) {
                         for (UILabel * label in self.labels) {
                             [label removeFromSuperview];
                         }
                         for (UIButton * button in self.buttons) {
                             [button removeFromSuperview];
                         }
                         [self initializeBalloon];
                         [self initializeTapReceiver];
                         [NSTimer scheduledTimerWithTimeInterval:GAME_LENGTH
                                                          target:self
                                                        selector:@selector(endGame)
                                                        userInfo:nil
                                                         repeats:NO];
                         [self startMusic];
                     }];
}

- (void)endGame {
//    [[BTAPI sharedInstance] postSession:self.session completion:^{
//        NSLog(@"Sent!");
//    } failure:^(NSError *error) {
//        NSLog(@"%@", error);
//    }];

    [self stopMusic];
    [self.baloon removeFromSuperview];
    [self.deflateTimer invalidate];
    self.restartButton.hidden = NO;
}

- (void)initializeBalloon {
    // Create the balloon
    CGRect baloonFrame = CGRectMake(0, 0, BALLOON_RADIUS, BALLOON_RADIUS);
    self.baloon = [[UIView alloc] initWithFrame:baloonFrame];
    self.baloon.layer.cornerRadius = BALLOON_RADIUS / 2;
    self.baloon.backgroundColor = [UIColor redColor];
    self.baloon.alpha = 0.0f;
    self.baloon.center = self.gameMode == GameModeInflate ? self.view.center : [self randomPoint];
    
    // Add the balloon to the view
    [self.view addSubview:self.baloon];

    // Fade the balloon in
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.baloon.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         // Keep trace of the starting time
                         self.startTime = [NSDate timeIntervalSinceReferenceDate];
                     }];
}

- (void)initializeTapReceiver {
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(balloonPressed)];
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self.view];
    return CGRectContainsPoint(self.baloon.frame, touchPoint);
}

- (void)balloonPressed {
    if (self.gameMode == GameModeInflate) {
        [self inflateBalloon];
    } else {
        [self moveBalloon:[self randomPoint] animated:ANIMATED];
    }
    NSTimeInterval relativeTime = [NSDate timeIntervalSinceReferenceDate] - self.startTime;
    BTTap * tap = [BTTap tapWithTime:relativeTime];
    tap.tapId = [NSString stringWithFormat:@"%i", self.session.taps.count + 1];
    [self.session addTap:tap];
    
    [[BTAPI sharedInstance] postTap:tap toSession:self.session completion:^{} failure:^(NSError * error) {
        NSLog(@"Could not send the tap");
        //TODO retry
    }];
    
    NSLog(@"%@", tap);
    
    [self checkGameEnd];
}

- (void)checkGameEnd {
    NSLog(@"tap limit exceeded %@", self.gameMode == GameModeMove && self.session.tapCount > TAP_MODE_LIMIT ? @"yes" : @"no");
    switch (self.gameMode) {
        case GameModeMove:
            if (self.session.tapCount > TAP_MODE_LIMIT)
                [self endGame];
            break;
            
        case GameModeInflate:
            if (self.baloon.frame.size.width > INFLATE_MODE_LIMIT) {
                [self explodeBalloonAndEndGame];
            }
            break;
            
        default:
            break;
    }        
}

- (void)explodeBalloonAndEndGame {
    [UIView animateWithDuration:0.4f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.baloon.layer.affineTransform = CGAffineTransformMakeScale(_currentInflation*EXPLOSION_MULTIPLIER, _currentInflation*EXPLOSION_MULTIPLIER);
                         self.baloon.alpha = 0.1f;
                         NSLog(@"Exploding ballon");
                     } completion:^(BOOL finished){
                         [self endGame];
                     }];
}

- (void)inflateBalloon {
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.baloon.layer.affineTransform = CGAffineTransformMakeScale(_currentInflation*INFLATE_FACTOR, _currentInflation*INFLATE_FACTOR);
                         _currentInflation *= INFLATE_FACTOR;
//                         NSLog(@"Inflate %f", _currentInflation);
                     } completion:nil];
}

- (void)deflateBalloon {
    if (_currentInflation > 1.0f) {
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.baloon.layer.affineTransform = CGAffineTransformMakeScale(_currentInflation/DEFLATE_FACTOR, _currentInflation/DEFLATE_FACTOR);
                             _currentInflation /= DEFLATE_FACTOR;
//                             NSLog(@"Deflate %f", _currentInflation);
                         } completion:nil];
    }
}


- (void)moveBalloon:(CGPoint)center animated:(BOOL)animated {
    NSTimeInterval duration = animated ? ANIMATION_DURATION : 0.0f;
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.baloon.center = center;
                     } completion:nil];
}

- (CGPoint)randomPoint {
    int xBound = self.view.bounds.size.width - BALLOON_RADIUS * 2;
    int yBound = self.view.bounds.size.height - BALLOON_RADIUS * 2;
    CGFloat x = (CGFloat) (arc4random() % xBound) + BALLOON_RADIUS;
    CGFloat y = (CGFloat) (arc4random() % yBound) + BALLOON_RADIUS;
    
    return CGPointMake(x, y);
}

- (void)startMusic {
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"baiao"
                                              withExtension:@"mp3"];
    NSError * error;
    self.avSound = [[AVAudioPlayer alloc]
                    initWithContentsOfURL:soundURL error:&error];
    if (error) NSLog(@"%@", error);
    
    [self.avSound play];
}

- (void)stopMusic {
    if ([self.avSound isPlaying])
        [self.avSound stop];
}

- (IBAction)startMoveMode {
    self.gameMode = GameModeMove;
    [self startGame];
}

- (IBAction)startInflateMode {
    self.gameMode = GameModeInflate;
    [self startGame];
}

- (IBAction)restart {
    for (UILabel * label in self.labels) {
        label.alpha = 1.0f;
    }
    for (UIButton * button in self.buttons) {
        button.alpha = 1.0f;
    }
    self.restartButton.hidden = YES;
}


@end
