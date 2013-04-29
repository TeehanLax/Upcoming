//
//  TLRootViewController.m
//  Layout Test
//
//  Created by Ash Furrow on 2013-04-12.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLRootViewController.h"

#import "TLHeaderViewController.h"
#import "TLUpcomingEventViewController.h"

#import "UIImage+Blur.h"
#import "TLProfiling.h"

#import <BlocksKit.h>
#import <EXTScope.h>

@interface TLRootViewController ()

// Two view controllers: one for the header and one for the day list.
@property (nonatomic, strong) TLHeaderViewController *headerViewController;
@property (nonatomic, strong) TLEventViewController *dayListViewController;
@property (nonatomic, strong) TLUpcomingEventViewController *footerViewController;

// This is an overlay view added to our view hierarchy when the header menu is pulled down.
@property (nonatomic, strong) UIImageView *dayListOverlayView;

// Gesture recognizers to reveal/hide the headeer menu.
@property (nonatomic, strong) UIPanGestureRecognizer *panHeaderDownGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panHeaderUpGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) UIPanGestureRecognizer *panFooterUpGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panFooterDownGestureRecognizer;

// Used to receive translations from the downward pan gesture recognizer on the header.
@property (nonatomic, strong) RACSubject *downwardHeaderPanSubject;
// Used to receive translations from the upward pan gesture recognizer on the header.
@property (nonatomic, strong) RACSubject *upwardHeaderPanSubject;
// Used to receive ratios of translation for shrinking the day list view controller's view.
@property (nonatomic, strong) RACSubject *dayListBlurSubject;
// Used to receive ratios of translation for moving the header view controller's view.
@property (nonatomic, strong) RACSubject *headerMovementSubject;
// Used to receive ratios of translation for changing the alpha of the overlay view which covers the day list view
@property (nonatomic, strong) RACSubject *dayListOverlaySubject;
// Used to enable/disable gesture recognizers
@property (nonatomic, strong) RACSubject *menuFinishedTransitionSubject;

@property (nonatomic, strong) RACSubject *upwardFooterPanSubject;
@property (nonatomic, strong) RACSubject *downwardFooterPanSubject;
@property (nonatomic, strong) RACSubject *footerMovementSubject;
@property (nonatomic, strong) RACSubject *footerFinishedTransitionSubject;

@end

@implementation TLRootViewController

// This is the height of the hidden portion of the menu.
// The total height of the header is kHeaderHeight + kMaximumTranslationThreshold.
static const CGFloat kMaximumHeaderTranslationThreshold = 320.0f;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) return nil;
    
    // Set up our view controllers.
    self.dayListViewController = [[TLEventViewController alloc] initWithNibName:@"TLEventViewController" bundle:nil];
    self.dayListViewController.delegate = self;
    [self addChildViewController:self.dayListViewController];
    
    self.headerViewController = [[TLHeaderViewController alloc] initWithNibName:@"TLHeaderViewController" bundle:nil];
    [self addChildViewController:self.headerViewController];
    
    self.footerViewController = [[TLUpcomingEventViewController alloc] init];
    [self addChildViewController:self.footerViewController];
    
    
    @weakify(self);
    
    // Set up our RAC subjects for passing messages.
    
    // This subject is responsible for adding/removing the overlay view to our hierarchy
    self.dayListOverlaySubject = [RACSubject subject];
    [self.dayListOverlaySubject subscribeNext:^(id x) {
        @strongify(self);
        if ([x boolValue])
        {
            // Using 1.0 scale here because after blurring, we won't need the extra (Retina) pixels.
            
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 1.0);
            [self.dayListViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            self.dayListOverlayView.image = [UIImage darkenedAndBlurredImageForImage:image];
            
            [self.view insertSubview:self.dayListOverlayView aboveSubview:self.dayListViewController.view];
        }
        else
        {
            self.dayListOverlayView.image = nil;
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
        
        CGRect headerFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kHeaderHeight + ratio * kMaximumHeaderTranslationThreshold);
        CGRect footerFrame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - TLUpcomingEventViewControllerHiddenHeight + ratio * kMaximumHeaderTranslationThreshold, CGRectGetWidth(self.view.bounds), TLUpcomingEventViewControllerTotalHeight);
        
        if (ratio < 0)
        {            
            headerFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kHeaderHeight);
            footerFrame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - TLUpcomingEventViewControllerHiddenHeight, CGRectGetWidth(self.view.bounds), TLUpcomingEventViewControllerTotalHeight);;
        }
        
        self.headerViewController.view.frame = headerFrame;
        self.footerViewController.view.frame = footerFrame;
    }];
    
    // This subject is repsonisble for shrinking the day list view controller's view via a CAAffineTransform.
    self.dayListBlurSubject = [RACSubject subject];
    [self.dayListBlurSubject subscribeNext:^(id x) {
        @strongify(self);
        
        // This is the ratio of the movement. 0 is full sized and 1 is fully shrunk.
        CGFloat ratio = [x floatValue];
        
        self.dayListOverlayView.alpha = ratio;
    }];
    
    // This subject is responsible for receiving translations from a gesture recognizers and turning
    // thos values into ratios. These ratios are fead into other signals.
    self.downwardHeaderPanSubject = [RACSubject subject];
    [self.downwardHeaderPanSubject subscribeNext:^(NSNumber *translation) {
        @strongify(self);
        CGFloat verticalTranslation = [translation floatValue];
        
        CGFloat effectiveRatio = 0.0f;
        
        if (verticalTranslation <= 0)
        {
            effectiveRatio = 0.0f;
        }
        else if (verticalTranslation <= kMaximumHeaderTranslationThreshold)
        {
            effectiveRatio = fabsf(verticalTranslation / kMaximumHeaderTranslationThreshold);
        }
        else
        {
            CGFloat overshoot = verticalTranslation - kMaximumHeaderTranslationThreshold;
            CGFloat y = 2 * sqrtf(overshoot + 1) - 2;
            effectiveRatio = 1.0f + (y / kMaximumHeaderTranslationThreshold);
        }
        
        [self.dayListBlurSubject sendNext:@(effectiveRatio)];
        [self.headerMovementSubject sendNext:@(effectiveRatio)];
    }];
    
    // This subject is responsible for receiving translations from a gesture recognizers and turning
    // thos values into ratios. These ratios are fead into other signals.
    self.upwardHeaderPanSubject = [RACSubject subject];
    [self.upwardHeaderPanSubject subscribeNext:^(NSNumber *translation) {
        @strongify(self);
        
        CGFloat verticalTranslation = [translation floatValue];

        CGFloat effectiveRatio = 1.0f;
        
        if (verticalTranslation >= 0)
        {
            CGFloat overshoot = verticalTranslation;
            CGFloat y = 2 * sqrtf(overshoot + 1) - 2;
            effectiveRatio = 1.0f + (y / kMaximumHeaderTranslationThreshold);
        }
        else if (verticalTranslation > -kMaximumHeaderTranslationThreshold)
        {
            effectiveRatio = fabsf((verticalTranslation + kMaximumHeaderTranslationThreshold) / kMaximumHeaderTranslationThreshold);
        }
        else
        {
            effectiveRatio = 0.0f;
        }

        [self.dayListBlurSubject sendNext:@(effectiveRatio)];
        [self.headerMovementSubject sendNext:@(effectiveRatio)];
    }];
    
    // This subject is responsible for mapping this value to other signals and state (ugh). 
    self.menuFinishedTransitionSubject = [RACReplaySubject subject];
    [self.menuFinishedTransitionSubject subscribeNext:^(NSNumber *menuIsOpenNumber) {
        
        BOOL menuIsOpen = menuIsOpenNumber.boolValue;
        
        if (!menuIsOpen)
        {
            [self.dayListOverlaySubject sendNext:menuIsOpenNumber];
        }
        
        self.panHeaderDownGestureRecognizer.enabled = !menuIsOpen;
        self.panHeaderUpGestureRecognizer.enabled = menuIsOpen;
        self.tapGestureRecognizer.enabled = menuIsOpen;
        self.dayListViewController.view.userInteractionEnabled = !menuIsOpen;
    }];
    
    
    // Footer gesture recognizer subjects
    
    self.footerMovementSubject = [RACSubject subject];
    [self.footerMovementSubject subscribeNext:^(id x) {
        
        // This is the ratio of the movement. 0 is closed and 1 is open.
        // Values less than zero are treated as zero.
        // Values greater than one are valid and will be extrapolated beyond the fully open menu.
        CGFloat ratio = [x floatValue];
        
        CGFloat targetTranslation = -CGRectGetMidY(self.view.bounds) - CGRectGetHeight(self.footerViewController.view.bounds) / 2.0f;
        CGRect footerFrame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - TLUpcomingEventViewControllerHiddenHeight + ratio * targetTranslation, CGRectGetWidth(self.view.bounds), TLUpcomingEventViewControllerTotalHeight);
        
        if (ratio < 0)
        {
            footerFrame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - TLUpcomingEventViewControllerHiddenHeight, CGRectGetWidth(self.view.bounds), TLUpcomingEventViewControllerTotalHeight);;
        }
        
        self.footerViewController.view.frame = footerFrame;
    }];
    
    self.downwardFooterPanSubject = [RACSubject subject];
    [self.downwardFooterPanSubject subscribeNext:^(NSNumber *translation) {
        @strongify(self);
        
        CGFloat verticalTranslation = [translation floatValue];
        
        CGFloat targetTranslation = -CGRectGetMidY(self.view.bounds) - CGRectGetHeight(self.footerViewController.view.bounds) / 2.0f;
        CGFloat effectiveRatio = 1.0f;
        
        if (verticalTranslation > 0)
        {
            effectiveRatio = ((targetTranslation + verticalTranslation) / targetTranslation);
        }
        else
        {
            CGFloat overshoot = fabsf(verticalTranslation);
            CGFloat y = 2 * sqrtf(overshoot + 1) - 2;
            effectiveRatio = 1.0f + (y / fabsf(targetTranslation));
        }
        
        [self.footerMovementSubject sendNext:@(effectiveRatio)];
    }];
    
    self.upwardFooterPanSubject = [RACSubject subject];
    [self.upwardFooterPanSubject subscribeNext:^(NSNumber *translation) {
        @strongify(self);
        
        CGFloat verticalTranslation = [translation floatValue];
        
        CGFloat targetTranslation = -CGRectGetMidY(self.view.bounds) - CGRectGetHeight(self.footerViewController.view.bounds) / 2.0f;
        CGFloat effectiveRatio = 0.0f;
        
        if (verticalTranslation < targetTranslation)
        {
            
            CGFloat overshoot = fabsf(verticalTranslation) - fabsf(targetTranslation);
            CGFloat y = 2 * sqrtf(overshoot + 1) - 2;
            effectiveRatio = 1.0f + (y / fabsf(targetTranslation));
        }
        else
        {
            effectiveRatio = verticalTranslation / targetTranslation;
        }
        
        [self.footerMovementSubject sendNext:@(effectiveRatio)];
    }];
    
    self.footerFinishedTransitionSubject = [RACReplaySubject subject];
    [self.footerFinishedTransitionSubject subscribeNext:^(NSNumber *menuIsOpenNumber) {
        
        BOOL menuIsOpen = menuIsOpenNumber.boolValue;
                
        self.panFooterUpGestureRecognizer.enabled = !menuIsOpen;
        self.panFooterDownGestureRecognizer.enabled = menuIsOpen;
        
        self.dayListViewController.view.userInteractionEnabled = !menuIsOpen;
    }];
    
    return self;
}

-(void)loadView
{
    [super loadView];
    
    // We'll set up the shadow for the day list view controller here, before it has to shrink.
    self.dayListViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    self.dayListViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    // Add the day list view controller's view to our hierarchy
    [self.view addSubview:self.dayListViewController.view];
    
    // Add the header view controller's view to our hierarchy
    self.headerViewController.view.frame = CGRectMake(0, -kMaximumHeaderTranslationThreshold, CGRectGetWidth(self.view.bounds), kHeaderHeight + kMaximumHeaderTranslationThreshold);
    [self.view addSubview:self.headerViewController.view];
    
    self.footerViewController.view.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - TLUpcomingEventViewControllerHiddenHeight, CGRectGetWidth(self.view.bounds), TLUpcomingEventViewControllerTotalHeight);
    [self.view addSubview:self.footerViewController.view];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up our gesture recognizers.
    // These mostly grab their translations and feed them into the appropriate subjects.
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [UIView animateWithDuration:0.25f animations:^{
            [self.downwardHeaderPanSubject sendNext:@(0)];
        } completion:^(BOOL finished) {
            [self.menuFinishedTransitionSubject sendNext:@(NO)];
        }];
    }];
    self.tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    
    // This is the number of points beyond which the user need to move their finger in order to trigger the menu moving down. 
    const CGFloat kMoveDownThreshold = 30.0f;
    
    self.panHeaderDownGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
        
        CGPoint translation = [recognizer translationInView:self.view];
        
        if (state == UIGestureRecognizerStateBegan)
        {
            [self.dayListOverlaySubject sendNext:@(YES)];
        }
        else if (state == UIGestureRecognizerStateChanged)
        {
            [self.downwardHeaderPanSubject sendNext:@(translation.y)];
        }
        else if (state == UIGestureRecognizerStateEnded)
        {
            // Determine the direction the finger is moving and ensure if it was moving down, that it exceeds the minimum threshold for opening the menu.
            BOOL movingDown = ([recognizer velocityInView:self.view].y > 0 && translation.y > kMoveDownThreshold);
            
            // Animate the change
            [UIView animateWithDuration:0.25f animations:^{
                if (movingDown)
                {
                    [self.downwardHeaderPanSubject sendNext:@(kMaximumHeaderTranslationThreshold)];
                }
                else
                {
                    [self.downwardHeaderPanSubject sendNext:@(0)];
                }
            } completion:^(BOOL finished) {
                [self.menuFinishedTransitionSubject sendNext:@(movingDown)];
            }];
        }
    }];
    self.panHeaderDownGestureRecognizer.delegate = self;
    [self.headerViewController.view addGestureRecognizer:self.panHeaderDownGestureRecognizer];
    
    self.panHeaderUpGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
        
        CGPoint translation = [recognizer translationInView:self.view];
        if (state == UIGestureRecognizerStateChanged)
        {
            [self.upwardHeaderPanSubject sendNext:@(translation.y)];
        }
        else if (state == UIGestureRecognizerStateEnded)
        {
            // Determine the direction the finger is moving
            BOOL movingDown = ([recognizer velocityInView:self.view].y > 0);
            
            // Animate the change
            [UIView animateWithDuration:0.25f animations:^{
                if (movingDown)
                {
                    [self.upwardHeaderPanSubject sendNext:@(0)];
                }
                else
                {
                    [self.upwardHeaderPanSubject sendNext:@(-kMaximumHeaderTranslationThreshold)];
                }
            } completion:^(BOOL finished) {
                [self.menuFinishedTransitionSubject sendNext:@(movingDown)];
            }];
        }
    }];
    self.panHeaderUpGestureRecognizer.delegate = self;
    [self.headerViewController.view addGestureRecognizer:self.panHeaderUpGestureRecognizer];
        
    self.panFooterUpGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
        
        CGPoint translation = [recognizer translationInView:self.view];
        
        if (state == UIGestureRecognizerStateBegan)
        {
            [self.dayListOverlaySubject sendNext:@(YES)];
        }
        else if (state == UIGestureRecognizerStateChanged)
        {
            [self.upwardFooterPanSubject sendNext:@(translation.y)];
        }
        else if (state == UIGestureRecognizerStateEnded)
        {
            // Determine the direction the finger is moving and ensure if it was moving down, that it exceeds the minimum threshold for opening the menu.
            BOOL movingUp = [recognizer velocityInView:self.view].y < 0;
            
            // Animate the change
            [UIView animateWithDuration:0.25f animations:^{
                if (movingUp)
                {
                    [self.upwardFooterPanSubject sendNext:@(-CGRectGetMidY(self.view.bounds) - CGRectGetHeight(self.footerViewController.view.bounds) / 2.0f)];
                }
                else
                {
                    [self.upwardFooterPanSubject sendNext:@(0)];
                }
            } completion:^(BOOL finished) {
                [self.footerFinishedTransitionSubject sendNext:@(movingUp)];
            }];
        }
    }];
    self.panFooterUpGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.panFooterUpGestureRecognizer];
    [self.dayListViewController.touchDown requireGestureRecognizerToFail:self.panFooterUpGestureRecognizer];
    
    self.panFooterDownGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
        
        CGPoint translation = [recognizer translationInView:self.view];
        if (state == UIGestureRecognizerStateChanged)
        {
            [self.downwardFooterPanSubject sendNext:@(translation.y)];
        }
        else if (state == UIGestureRecognizerStateEnded)
        {
            // Determine the direction the finger is moving
            BOOL movingDown = ([recognizer velocityInView:self.view].y > 0);
            
            // Animate the change
            [UIView animateWithDuration:0.25f animations:^{
                if (movingDown)
                {
                    [self.downwardFooterPanSubject sendNext:@(CGRectGetHeight(self.view.bounds) - TLUpcomingEventViewControllerHiddenHeight)];
                }
                else
                {
                    [self.downwardFooterPanSubject sendNext:@(0)];
                }
            } completion:^(BOOL finished) {
                [self.footerFinishedTransitionSubject sendNext:@(!movingDown)];
            }];
        }
    }];
    self.panFooterDownGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.panFooterDownGestureRecognizer];
    
    [self.menuFinishedTransitionSubject sendNext:@(NO)];
    [self.footerFinishedTransitionSubject sendNext:@(NO)];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.panHeaderUpGestureRecognizer)
    {
        // Only allow the pan up to take place on the header section of the header menu.
        return CGRectContainsPoint(CGRectMake(0, CGRectGetHeight(self.headerViewController.view.bounds) - kHeaderHeight, CGRectGetWidth(self.view.bounds), kHeaderHeight), [touch locationInView:self.view]);
    }
    else if (gestureRecognizer == self.tapGestureRecognizer)
    {        
        // Only allow the tap to take place in the area beneath the header menu.
        CGFloat menuHeight = kHeaderHeight + kMaximumHeaderTranslationThreshold;
        return CGRectContainsPoint(CGRectMake(0, menuHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - menuHeight), [touch locationInView:self.view]);
    }
    else if (gestureRecognizer == self.panFooterUpGestureRecognizer)
    {
        CGFloat headerTapHeight = 44.0f;
        return CGRectContainsPoint(CGRectMake(0, CGRectGetHeight(self.view.bounds) - headerTapHeight, CGRectGetWidth(self.view.bounds), headerTapHeight), [touch locationInView:self.view]);
    }
    else
    {
        // Otherwise return YES.
        return YES;
    }
}

#pragma mark - TLDayListViewControllerDelegate Methods

-(void)userDidBeginInteractingWithDayListViewController:(TLEventViewController *)controller
{
    [self.headerViewController hideHeaderView];
}

-(void)userDidEndInteractingWithDayListViewController:(TLEventViewController *)controller
{
    [self.headerViewController showHeaderView];
}

-(void)userDidInteractWithDayListView:(TLEventViewController *)controller updatingTimeRatio:(CGFloat)timeRatio
{
    [self.headerViewController updateTimeRatio:timeRatio];
}

@end
