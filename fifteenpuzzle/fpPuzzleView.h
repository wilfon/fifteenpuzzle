//
//  fpPuzzleView.h
//  fifteenpuzzle
//
//  Created by wil on 2013-05-23.
//  Copyright (c) 2013 wil. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol fpPuzzleViewDelegate <NSObject>

@required
- (void)puzzleDidFinish;

@end

@interface fpPuzzleView : UIView <UIGestureRecognizerDelegate>

@property(nonatomic, weak) id<fpPuzzleViewDelegate> delegate;

- (void)setImage:(UIImage*)image;
- (BOOL)hasImage;

- (BOOL)checkFinished;
- (void)printGrid;

@end
