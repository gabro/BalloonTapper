//
//  BTViewController.h
//  BalloonTapper
//
//  Created by Gabriele Petronella on 10/19/12.
//  Copyright (c) 2012 HCI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;

@end
