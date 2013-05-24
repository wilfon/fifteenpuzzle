//
//  fpViewController.m
//  fifteenpuzzle
//
//  Created by wil on 2013-05-23.
//  Copyright (c) 2013 wil. All rights reserved.
//

#import "fpViewController.h"
#import "fpPuzzleView.h"
#import "UIImage+Resize.h"

@interface fpViewController ()

@property(nonatomic, strong) IBOutlet UIButton* playButton;
@property(nonatomic, strong) IBOutlet fpPuzzleView* puzzleView;
@property(nonatomic, strong) IBOutlet UILabel* label;
@property(nonatomic, strong) IBOutlet UIButton* checkButton;

@end

@implementation fpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.puzzleView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

#define IMAGE_URL @"http://25.media.tumblr.com/66c27676d6e9c6c71deac9c70b40da37/tumblr_mm20s6IOO91s4yg05o1_r1_1280.jpg"

- (IBAction)playButtonClicked:(id)sender
{
    //
    UIActivityIndicatorView* activityWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityWheel.center = self.playButton.center;
    [self.view addSubview:activityWheel];
    [activityWheel startAnimating];
    
    self.label.text = @"Tap tile or swipe";
    
    // grab image in the background. using external code to do resizing...
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    dispatch_async(queue, ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:IMAGE_URL]];
        UIImage* image = [UIImage imageWithData:data];
        NSInteger imageSize = 300 * [UIScreen mainScreen].scale;
        UIImage* croppedImage = [image thumbnailImage:imageSize transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.imageView.image = croppedImage;
            [self.puzzleView setImage:croppedImage];
            [activityWheel removeFromSuperview];
        });
    });
}

- (IBAction)checkButtonClicked:(id)sender
{
    [self.puzzleView printGrid];
}

- (void)puzzleDidFinish
{
    self.label.text = @"A WINNER IS YOU";
}

@end
