//
//  TLRootViewController.m
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-12.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLRootViewController.h"

#import "TLDayListViewController.h"
#import "TLHeaderViewController.h"

#import <BlocksKit.h>
#import <EXTScope.h>

@interface TLRootViewController ()

// Two view controllers: one for the header and one for the day list.
@property (nonatomic, strong) TLHeaderViewController *headerViewController;
@property (nonatomic, strong) TLDayListViewController *dayListViewController;

// This is an overlay view added to our view hierarchy when the header menu is pulled down.
@property (nonatomic, strong) UIView *dayListOverlayView;

// Gesture recognizers to reveal/hide the headeer menu.
@property (nonatomic, strong) UIPanGestureRecognizer *panDownGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panUpGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

// Used to receive translations from the downward pan gesture recognizer.
@property (nonatomic, strong) RACSubject *downwardPanSubject;
// Used to receive translations from the upward pan gesture recognizer.
@property (nonatomic, strong) RACSubject *upwardPanSubject;
// Used to receive ratios of translation for shrinking the day list view controller's view.
@property (nonatomic, strong) RACSubject *dayListMovementSubject;
// Used to receive ratios of translation for moving the header view controller's view.
@property (nonatomic, strong) RACSubject *headerMovementSubject;
// Used to receive ratios of translation for changing the alpha of the overlay view which covers the day list view
@property (nonatomic, strong) RACSubject *dayListOverlaySubject;
// Used to enable/disable gesture recognizers
@property (nonatomic, strong) RACSubject *menuFinishedTransitionSubject;

@end

@implementation TLRootViewController

// This is the height of the hidden portion of the menu.
// The total height of the header is kHeaderHeight + kMaximumTranslationThreshold.
static const CGFloat kMaximumTranslationThreshold = 320.0f;

// The shrink percentage of the day list VC's view while the menu is open.
static const CGFloat kMaximumShrinkTranslation = 0.1f;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) return nil;
    
    // Set up our view controllers.
    self.dayListViewController = [[TLDayListViewController alloc] init];
    [self addChildViewController:self.dayListViewController];
    
    self.headerViewController = [[TLHeaderViewController alloc] initWithNibName:@"TLHeaderViewController" bundle:nil];
    [self addChildViewController:self.headerViewController];
    
    // Keep this view around for later
    self.dayListOverlayView = [[UIView alloc] initWithFrame:self.dayListViewController.view.frame];
    self.dayListOverlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    self.dayListOverlayView.frame = self.view.frame;
    self.dayListOverlayView.alpha = 0.0f;
    
    @weakify(self);
    
    // Set up our RAC subjects for passing messages.
    
    // This subject is responsible for adding/removing the overlay view to our hierarchy
    self.dayListOverlaySubject = [RACSubject subject];
    [self.dayListOverlaySubject subscribeNext:^(id x) {
        @strongify(self);
        if ([x boolValue])
        {
            [self.view insertSubview:self.dayListOverlayView aboveSubview:self.dayListViewController.view];
        }
        else
        {
            [self.dayListOverlayView removeFromSuperview];
            [self.headerViewController scrollTableViewToTop];
        }
    }];
    
    // This subject is responsible for moving the actual header up and down
    self.headerMovementSubject = [RACSubject subject];
    [self.headerMovementSubject subscribeNext:^(id x) {
        @strongify(self);
        
        // This is the ratio of the movement. 0 is closed and 1 is open.
        // Values less than zero are treated as zero.
        // Values greater than one are valid and will be extrapolated beyond the fully open menu.
        CGFloat ratio = [x floatValue];
        
        CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kHeaderHeight + ratio * kMaximumTranslationThreshold);
        
        if (ratio < 0)
        {
            frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kHeaderHeight);
        }
        
        self.headerViewController.view.frame = frame;
    }];
    
    // This subject is repsonisble for shrinking the day list view controller's view via a CAAffineTransform.
    self.dayListMovementSubject = [RACSubject subject];
    [self.dayListMovementSubject subscribeNext:^(id x) {
        @strongify(self);
        
        // This is the ratio of the movement. 0 is full sized and 1 is fully shrunk.
        CGFloat ratio = [x floatValue];
        
        self.dayListOverlayView.alpha = ratio;
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        
        if (ratio > 0.01)
        {
            transform = CGAffineTransformMakeScale(1.0f - ratio * kMaximumShrinkTranslation, 1.0f - ratio * kMaximumShrinkTranslation);
        }
        
        self.dayListViewController.view.transform = transform;
    }];
    
    // This subject is responsible for receiving translations from a gesture recognizers and turning
    // thos values into ratios. These ratios are fead into other signals.
    self.downwardPanSubject = [RACSubject subject];
    [self.downwardPanSubject subscribeNext:^(NSNumber *translation) {
        @strongify(self);
        CGFloat verticalTranslation = [translation floatValue];
        
        CGFloat effectiveRatio = 0.0f;
        
        if (verticalTranslation <= 0)
        {
            effectiveRatio = 0.0f;
        }
        else if (verticalTranslation <= kMaximumTranslationThreshold)
        {
            effectiveRatio = fabsf(verticalTranslation / kMaximumTranslationThreshold);
        }
        else
        {
            CGFloat overshoot = verticalTranslation - kMaximumTranslationThreshold;
            CGFloat y = 2 * sqrtf(overshoot + 1) - 2;
            effectiveRatio = 1.0f + (y / kMaximumTranslationThreshold);
        }
        
        [self.dayListMovementSubject sendNext:@(effectiveRatio)];
        [self.headerMovementSubject sendNext:@(effectiveRatio)];
    }];
    
    // This subject is responsible for receiving translations from a gesture recognizers and turning
    // thos values into ratios. These ratios are fead into other signals.
    self.upwardPanSubject = [RACSubject subject];
    [self.upwardPanSubject subscribeNext:^(NSNumber *translation) {
        @strongify(self);
        
        CGFloat verticalTranslation = [translation floatValue];

        CGFloat effectiveRatio = 1.0f;
        
        if (verticalTranslation >= 0)
        {
            CGFloat overshoot = verticalTranslation;
            CGFloat y = 2 * sqrtf(overshoot + 1) - 2;
            effectiveRatio = 1.0f + (y / kMaximumTranslationThreshold);

        }
        else if (verticalTranslation > -kMaximumTranslationThreshold)
        {
            effectiveRatio = fabsf((verticalTranslation + kMaximumTranslationThreshold) / kMaximumTranslationThreshold);
        }
        else
        {
            effectiveRatio = 0.0f;
        }

        [self.dayListMovementSubject sendNext:@(effectiveRatio)];
        [self.headerMovementSubject sendNext:@(effectiveRatio)];
    }];
    
    // This subject is responsible for mapping this value to other signals and state (ugh). 
    self.menuFinishedTransitionSubject = [RACReplaySubject subject];
    [self.menuFinishedTransitionSubject subscribeNext:^(NSNumber *menuIsOpenNumber) {
        [self.dayListOverlaySubject sendNext:menuIsOpenNumber];
        
        BOOL menuIsOpen = menuIsOpenNumber.boolValue;
        self.panDownGestureRecognizer.enabled = !menuIsOpen;
        self.panUpGestureRecognizer.enabled = menuIsOpen;
        self.tapGestureRecognizer.enabled = menuIsOpen;
        self.dayListViewController.view.userInteractionEnabled = !menuIsOpen;
    }];
    
    return self;
}

-(void)loadView
{
    [super loadView];
    
    // We'll set up the shadow for the day list view controller here, before it has to shrink.
    self.dayListViewController.view.frame = CGRectMake(0, kHeaderHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kHeaderHeight);
    self.dayListViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.dayListViewController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.dayListViewController.view.layer.shadowOpacity = 1.0f;
    self.dayListViewController.view.layer.shadowOffset = CGSizeMake(0, 1);
    self.dayListViewController.view.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.dayListViewController.view.bounds] CGPath];
    self.dayListViewController.view.layer.shadowRadius = 5.0f;
    self.dayListViewController.view.layer.masksToBounds = NO;
    // Add the day list view controller's view to our hierarchy
    [self.view addSubview:self.dayListViewController.view];
    
    // Add the header view controller's view to our hierarchy
    self.headerViewController.view.frame = CGRectMake(0, -kMaximumTranslationThreshold, CGRectGetWidth(self.view.bounds), kHeaderHeight + kMaximumTranslationThreshold);
    [self.view addSubview:self.headerViewController.view];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:33.0f/255.0f alpha:1.0f];
    
    // Set up our gesture recognizers.
    // These mostly grab their translations and feed them into the appropriate subjects.
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [UIView animateWithDuration:0.25f animations:^{
            [self.downwardPanSubject sendNext:@(0)];
        } completion:^(BOOL finished) {
            [self.menuFinishedTransitionSubject sendNext:@(NO)];
        }];
    }];
    self.tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    
    // This is the number of points beyond which the user need to move their finger in order to trigger the menu moving down. 
    const CGFloat kMoveDownThreshold = 30.0f;
    
    self.panDownGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
        
        CGPoint translation = [recognizer translationInView:self.view];
        
        if (state == UIGestureRecognizerStateBegan)
        {
            [self.dayListOverlaySubject sendNext:@(YES)];
        }
        else if (state == UIGestureRecognizerStateChanged)
        {
            [self.downwardPanSubject sendNext:@(translation.y)];
        }
        else if (state == UIGestureRecognizerStateEnded)
        {
            // Determine the direction the finger is moving and ensure if it was moving down, that it exceeds the minimum threshold for opening the menu.
            BOOL movingDown = ([recognizer velocityInView:self.view].y > 0 && translation.y > kMoveDownThreshold);
            
            // Animate the change
            [UIView animateWithDuration:0.25f animations:^{
                if (movingDown)
                {
                    [self.downwardPanSubject sendNext:@(kMaximumTranslationThreshold)];
                }
                else
                {
                    [self.downwardPanSubject sendNext:@(0)];
                }
            } completion:^(BOOL finished) {
                [self.menuFinishedTransitionSubject sendNext:@(movingDown)];
            }];
        }
    }];
    self.panDownGestureRecognizer.delegate = self;
    [self.headerViewController.view addGestureRecognizer:self.panDownGestureRecognizer];
    
    self.panUpGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
        
        CGPoint translation = [recognizer translationInView:self.view];
        if (state == UIGestureRecognizerStateChanged)
        {
            [self.upwardPanSubject sendNext:@(translation.y)];
        }
        else if (state == UIGestureRecognizerStateEnded)
        {
            // Determine the direction the finger is moving
            BOOL movingDown = ([recognizer velocityInView:self.view].y > 0);
            
            // Animate the change
            [UIView animateWithDuration:0.25f animations:^{
                if (movingDown)
                {
                    [self.upwardPanSubject sendNext:@(0)];
                }
                else
                {
                    [self.upwardPanSubject sendNext:@(-kMaximumTranslationThreshold)];
                }
            } completion:^(BOOL finished) {
                [self.menuFinishedTransitionSubject sendNext:@(movingDown)];
            }];
        }
    }];
    self.panUpGestureRecognizer.delegate = self;
    [self.headerViewController.view addGestureRecognizer:self.panUpGestureRecognizer];
    
    [self.menuFinishedTransitionSubject sendNext:@(NO)];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.panUpGestureRecognizer)
    {
        // Only allow the pan up to take place on the header section of the header menu.
        return CGRectContainsPoint(CGRectMake(0, CGRectGetHeight(self.headerViewController.view.bounds) - kHeaderHeight, CGRectGetWidth(self.view.bounds), kHeaderHeight), [touch locationInView:self.view]);
    }
    else if (gestureRecognizer == self.tapGestureRecognizer)
    {
        // Only allow the tap to take place in the area beneath the header menu. 
        CGFloat menuHeight = kHeaderHeight + kMaximumTranslationThreshold;
        return CGRectContainsPoint(CGRectMake(0, menuHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - menuHeight), [touch locationInView:self.view]);
    }
    else
    {
        // Otherwise return YES.
        return YES;
    }
}

@end
