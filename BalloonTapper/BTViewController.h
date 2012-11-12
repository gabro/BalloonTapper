//
//  BTViewController.h
//  BalloonTapper
//
//  Created by Gabriele Petronella on 10/19/12.
//  Copyright (c) 2012 HCI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _GameMode {
    GameModeInflate = 0,
    GameModeMove
} GameMode;

@interface BTViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIButton *restartButton;


- (IBAction)startMoveMode;
- (IBAction)startInflateMode;
- (IBAction)restart;

@end
