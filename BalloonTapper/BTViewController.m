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

#define BALLOON_RADIUS 100
#define ANIMATED YES
#define ANIMATION_DURATION 0.2f
#define GAME_LENGTH 60.0f

@interface BTViewController ()
@property (nonatomic, strong) UIView * baloon;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, strong) BTSession * session;
@property (nonatomic, strong) AVAudioPlayer * avSound;
@end

@implementation BTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startGame:)];
    
    [self.view addGestureRecognizer:tapRecognizer];
}


- (void)startGame:(UIGestureRecognizer *)recognizer {
    [self.view removeGestureRecognizer:recognizer];
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         for (UILabel * label in self.labels) {
                             label.alpha = 0.0f;
                         }
                     } completion:^(BOOL finished) {
                         for (UILabel * label in self.labels) {
                             [label removeFromSuperview];
                         }
                         self.session = [BTSession session];
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
    [[BTAPI sharedInstance] postSession:self.session completion:^{
        NSLog(@"Sent!");
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    [self stopMusic];
}

- (void)initializeBalloon {
    // Create the balloon
    CGPoint initialCenter = [self randomPoint];
    CGRect baloonFrame = CGRectMake(initialCenter.x, initialCenter.y, BALLOON_RADIUS, BALLOON_RADIUS);
    self.baloon = [[UIView alloc] initWithFrame:baloonFrame];
    self.baloon.layer.cornerRadius = BALLOON_RADIUS / 2;
    self.baloon.backgroundColor = [UIColor redColor];
    self.baloon.alpha = 0.0f;
    
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
    [self moveBalloon:[self randomPoint] animated:ANIMATED];
    
    NSTimeInterval relativeTime = [NSDate timeIntervalSinceReferenceDate] - self.startTime;
    BTTap * tap = [BTTap tapWithTime:relativeTime];
    [self.session addTap:tap];
    
    NSLog(@"%@", tap);
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
    if (error) {
        NSLog(@"%@", error);
    }
    [self.avSound play];
}

- (void)stopMusic {
    if ([self.avSound isPlaying])
        [self.avSound stop];
}

@end
