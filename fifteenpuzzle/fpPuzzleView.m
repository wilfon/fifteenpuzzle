//
//  fpPuzzleView.m
//  fifteenpuzzle
//
//  Created by wil on 2013-05-23.
//  Copyright (c) 2013 wil. All rights reserved.
//

#import "fpPuzzleView.h"

@interface fpPuzzleView ()
{
    UIImageView* _grid[4][4];
    BOOL _hasImage;
    
    CGRect _emptyFrame;
}

@end

@implementation fpPuzzleView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // init
        CGSize imageViewSize = CGSizeMake(self.frame.size.width / 4, self.frame.size.height / 4);
        for (int i = 0; i < 4; ++i)
        {
            for (int j = 0; j < 4; ++j)
            {
                if (i == 3 && j == 3)
                {
                    _emptyFrame = CGRectMake(imageViewSize.width * j, imageViewSize.height * i, imageViewSize.width, imageViewSize.height);
                    break;
                }
                
                CGRect imageViewFrame = CGRectMake(imageViewSize.width * j, imageViewSize.height * i, imageViewSize.width, imageViewSize.height);
                UIImageView* imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
                
                CGRect labelFrame = CGRectMake(0, 0, imageViewSize.width, 30);

                UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
                label.textAlignment = NSTextAlignmentRight;
                label.shadowColor = [UIColor whiteColor];
                label.shadowOffset = CGSizeMake(1, 1);
                label.backgroundColor = [UIColor clearColor];
                [imageView addSubview:label];
                
                [self addSubview:imageView];
                
                _grid[i][j] = imageView;
            }
        }
        
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(handleTap:)];
        [self addGestureRecognizer:tapRecognizer];
        tapRecognizer.delegate = self;
        
        UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(handleSwipe:)];
        [self addGestureRecognizer:swipeRight];
        swipeRight.delegate = self;
        UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(handleSwipe:)];
        [self addGestureRecognizer:swipeLeft];
        swipeLeft.delegate = self;
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        UISwipeGestureRecognizer* swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(handleSwipe:)];
        [self addGestureRecognizer:swipeDown];
        swipeDown.delegate = self;
        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
        UISwipeGestureRecognizer* swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(handleSwipe:)];
        [self addGestureRecognizer:swipeUp];
        swipeUp.delegate = self;
        swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
        
        _hasImage = FALSE;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

-(void)resetLayout
{
    CGPoint bottomCorner = CGPointMake(_emptyFrame.size.width * 3, _emptyFrame.size.height * 3);
    if (!CGPointEqualToPoint(_emptyFrame.origin, bottomCorner))
    {
        int i, j;
        [self findIndicesForPoint:_emptyFrame.origin row:&i column:&j];

        UIImageView* view = _grid[3][3];
        _grid[i][j] = view;
        _grid[3][3] = nil;
        
        CGRect frame = view.frame;
        frame.origin = _emptyFrame.origin;
        view.frame = frame;
        
        _emptyFrame.origin = bottomCorner;
    }
}

-(void)setImage:(UIImage*)image
{
    // make sure we have all our image views in their proper place
    [self resetLayout];
    
    // break up the image
    CGImageRef cgImage = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(cgImage) / 4, CGImageGetHeight(cgImage) / 4);
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:15];
    
    for (int i = 0; i < 4; ++i)
    {
        for (int j = 0; j < 4; ++j)
        {
            if (i == 3 && j == 3)
                break;
            
            CGRect cropRect = CGRectMake(imageSize.width * j, imageSize.height * i, imageSize.width, imageSize.height);
            CGImageRef croppedImage = CGImageCreateWithImageInRect(cgImage, cropRect);
            
            UIImageView* imageView = _grid[i][j];
            imageView.image = [UIImage imageWithCGImage:croppedImage];
            
            NSInteger tag = i * 4 + j + 1;
            imageView.tag = tag;
            UILabel* label = (UILabel*)[imageView.subviews objectAtIndex:0];
            label.text = [NSString stringWithFormat:@"%d", tag];
            
            [array addObject:imageView];
        }
    }
    _hasImage = TRUE;
    
    // randomize
    for (int i = 0; i < 4; ++i)
    {
        for (int j = 0; j < 4; ++j)
        {
            if (i == 3 && j == 3)
                break;
            
            int r = arc4random() % array.count;
            UIImageView* imageView = [array objectAtIndex:r];
            CGRect frame = imageView.frame;
            frame.origin = CGPointMake(frame.size.width * j, frame.size.height * i);
            imageView.frame = frame;
            
            _grid[i][j] = imageView;
            
            [array removeObjectAtIndex:r];
            
        }
    }
}
- (BOOL)hasImage
{
    return _hasImage;
}

- (void)findIndicesForPoint:(CGPoint)point row:(int*)i column:(int*)j
{
    CGFloat tileWidth = self.frame.size.width / 4;
    CGFloat tileHeight = self.frame.size.height / 4;
    *i = point.y / tileHeight;
    *j = point.x / tileWidth;
}

enum
{
    NO_MOVE = 0,
    MOVE_LEFT,
    MOVE_RIGHT,
    MOVE_UP,
    MOVE_DOWN
};

- (int)canMoveToEmpty:(CGRect)frame
{
    if (_emptyFrame.origin.x == frame.origin.x - frame.size.width &&
        _emptyFrame.origin.y == frame.origin.y)
        return MOVE_LEFT;
    
    if (_emptyFrame.origin.x == frame.origin.x + frame.size.width &&
        _emptyFrame.origin.y == frame.origin.y)
        return MOVE_RIGHT;
    
    if (_emptyFrame.origin.x == frame.origin.x &&
        _emptyFrame.origin.y == frame.origin.y - frame.size.height)
        return MOVE_UP;
    
    if (_emptyFrame.origin.x == frame.origin.x &&
        _emptyFrame.origin.y == frame.origin.y + frame.size.height)
        return MOVE_DOWN;
    
    return NO_MOVE;
}

- (void)moveTileAtRow:(int)i column:(int)j
{
    UIImageView* view = _grid[i][j];
    if (view)
    {
        int direction = [self canMoveToEmpty:view.frame];
        switch (direction)
        {
            case NO_MOVE:
                return;
            case MOVE_LEFT:
            {
                _grid[i][j - 1] = view;
                _grid[i][j] = nil;
            }
                break;
            case MOVE_RIGHT:
            {
                _grid[i][j + 1] = view;
                _grid[i][j] = nil;
            }
                break;
            case MOVE_UP:
            {
                _grid[i - 1][j] = view;
                _grid[i][j] = nil;
            }
                break;
            case MOVE_DOWN:
            {
                _grid[i + 1][j] = view;
                _grid[i][j] = nil;
            }
                break;
        }
        
        CGRect frame = view.frame;
        [UIView animateWithDuration:0.25 animations:^
         {
             view.frame = _emptyFrame;
             _emptyFrame = frame;
         }
                         completion:^(BOOL complete)
         {
             [self checkFinished];
         }];
    }
}

- (BOOL)checkFinished
{
    if (!_hasImage)
        return FALSE;
    
    for (int i = 0; i < 4; ++i)
    {
        for (int j = 0; j < 4; ++j)
        {
            if (i == 3 && j == 3)
                break;
            
            if (_grid[i][j].tag != i * 4 + j + 1)
                return FALSE;
        }
    }
    
    [self.delegate puzzleDidFinish];
    return TRUE;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return _hasImage;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return _hasImage;
}
- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // handling code
        CGPoint hitPoint = CGPointMake([sender locationInView:self].x, [sender locationInView:self].y);
        int i, j;
        [self findIndicesForPoint:hitPoint row:&i column:&j];
        [self moveTileAtRow:i column:j];
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        switch (sender.direction) {
            case UISwipeGestureRecognizerDirectionRight:
            {
                if (_emptyFrame.origin.x > 0)
                {
                    int i, j;
                    [self findIndicesForPoint:CGPointMake(_emptyFrame.origin.x - 1, _emptyFrame.origin.y)
                                          row:&i column:&j];
                    [self moveTileAtRow:i column:j];
                }
            }
                break;
            case UISwipeGestureRecognizerDirectionLeft:
            {
                if (_emptyFrame.origin.x + _emptyFrame.size.width <= self.frame.size.width)
                {
                    int i, j;
                    [self findIndicesForPoint:CGPointMake(_emptyFrame.origin.x + _emptyFrame.size.width, _emptyFrame.origin.y)
                                          row:&i column:&j];
                    [self moveTileAtRow:i column:j];
                }
            }
                break;
            case UISwipeGestureRecognizerDirectionDown:
            {
                if (_emptyFrame.origin.y > 0)
                {
                    int i, j;
                    [self findIndicesForPoint:CGPointMake(_emptyFrame.origin.x, _emptyFrame.origin.y - 1)
                                          row:&i column:&j];
                    [self moveTileAtRow:i column:j];
                }
            }
                break;
            case UISwipeGestureRecognizerDirectionUp:
            {
                if (_emptyFrame.origin.y + _emptyFrame.size.height < self.frame.size.height)
                {
                    int i, j;
                    [self findIndicesForPoint:CGPointMake(_emptyFrame.origin.x, _emptyFrame.origin.y + _emptyFrame.size.height)
                                          row:&i column:&j];
                    [self moveTileAtRow:i column:j];
                }
            }
                break;
            default:
                break;
        }
    }
    
}

- (void)printGrid
{
    for (int i = 0; i < 4; ++i)
    {
        NSLog(@"%d %d %d %d", _grid[i][0].tag, _grid[i][1].tag, _grid[i][2].tag, _grid[i][3].tag);
    }
}

@end
