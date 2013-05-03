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

// Two subjects used to receive translations from the gesture recognizers
@property (nonatomic, strong) RACSubject *headerPanSubject;
@property (nonatomic, strong) RACSubject *footerPanSubject;

// Used to receive ratios of translation for changing the alpha of the overlay view which covers the day list view
@property (nonatomic, strong) RACSubject *dayListAndHeaderOverlaySubject;
@property (nonatomic, strong) RACSubject *dayListOverlaySubject;

// Used to enable/disable gesture recognizers and view interactivity
@property (nonatomic, strong) RACSubject *headerFinishedTransitionSubject;
@property (nonatomic, strong) RACSubject *footerFinishedTransitionSubject;


@end

@implementation TLRootViewController

// This is the height of the hidden portion of the menu.
// The total height of the header is kHeaderHeight + kMaximumTranslationThreshold.
static const CGFloat kMaximumHeaderTranslationThreshold = 320.0f;

// We have to use a #define here to get the compiler to expand this macro
#define kMaximumFooterTranslationThreshold (-CGRectGetMidY(self.view.bounds) - CGRectGetHeight(self.footerViewController.view.bounds) / 2.0f)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) return nil;
    
    // Set up our view controllers.
    self.dayListViewController = [[TLEventViewController alloc] initWithNibName:@"TLEventViewController" bundle:nil];
    self.dayListViewController.delegate = self;
    [self addChildViewController:self.dayListViewController];
    
    self.headerViewController = [[TLHeaderViewController alloc] initWithNibName:@"TLHeaderViewController" bundle:nil];
    [self addChildViewController:self.headerViewController];
    
    self.footerViewController = [[TLUpcomingEventViewController alloc] initWithNibName:@"TLUpcomingEventViewController" bundle:nil];
    [self addChildViewController:self.footerViewController];
    
    
    @weakify(self);
        
    // These subjects are responsible for adding/removing the overlay view to our hierarchy.
    // We're using an explicit subject here because it maintains state (whether or not the overlay view is in the hierarchy).
    self.dayListOverlaySubject = [RACSubject subject];
    [self.dayListOverlaySubject subscribeNext:^(id x) {
        @strongify(self);
        if ([x boolValue])
        {
            // Using 1.0 scale here because after blurring, we won't need the extra (Retina) pixels.
            
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0);
            [self.dayListViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            self.dayListOverlayView.image = [UIImage darkenedAndBlurredImageForImage:image];
            
            [self.view insertSubview:self.dayListOverlayView aboveSubview:self.dayListViewController.view];
            [AppDelegate playPullMenuOutSound];
        }
        else if (self.dayListOverlayView.superview)
        {
            self.dayListOverlayView.image = nil;
            [self.dayListOverlayView removeFromSuperview];
            [self.headerViewController scrollTableViewToTop];
            [AppDelegate playPushMenuInSound];
        }
    }];
    
    self.dayListAndHeaderOverlaySubject = [RACSubject subject];
    [self.dayListAndHeaderOverlaySubject subscribeNext:^(id x) {
        @strongify(self);
        if ([x boolValue])
        {
            // Using 1.0 scale here because after blurring, we won't need the extra (Retina) pixels.
            
            // First grab the image of the day list view
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0);
            [self.dayListViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *dayListImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            // The grab the image of the header view
            UIGraphicsBeginImageContextWithOptions(self.headerViewController.view.bounds.size, NO, 0);
            [self.headerViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *headerImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            // Finally, composite the two images together.
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0);
            [dayListImage drawInRect:self.view.bounds];
            [headerImage drawInRect:CGRectOffset(self.headerViewController.view.bounds, 0, -CGRectGetHeight(self.headerViewController.view.bounds) + kHeaderHeight)];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            self.dayListOverlayView.image = [UIImage darkenedAndBlurredImageForImage:image];
            
            [self.view insertSubview:self.dayListOverlayView aboveSubview:self.headerViewController.view];
            
            [AppDelegate playPullMenuOutSound];
        }
        else if (self.dayListOverlayView.superview)
        {
            self.dayListOverlayView.image = nil;
            [self.dayListOverlayView removeFromSuperview];
            [self.headerViewController scrollTableViewToTop];
            [AppDelegate playPushMenuInSound];
        }
    }];
    
    
    //These subjects are responsible for calculating the frame of the header and footer
    self.headerPanSubject = [RACSubject subject];
    
    RACSignal *headerOpenRatioSubject = [self.headerPanSubject
                                         map:^id(NSNumber *translation) {
                                             
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
                                             
                                             return @(effectiveRatio);
                                         }];
        
    RACSignal *headerFrameSignal = [headerOpenRatioSubject map:^id(id value) {
        
        // This is the ratio of the movement. 0 is closed and 1 is open.
        // Values less than zero are treated as zero.
        // Values greater than one are valid and will be extrapolated beyond the fully open menu.
        CGFloat ratio = [value floatValue];
        
        CGRect headerFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kHeaderHeight + ratio * kMaximumHeaderTranslationThreshold);
        
        if (ratio < 0)
        {
            headerFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kHeaderHeight);
        }
        
        return [NSValue valueWithCGRect:headerFrame];
    }];
    
    RAC(self.headerViewController.view.frame) = headerFrameSignal;
    
    self.footerPanSubject = [RACSubject subject];
    
    RACSignal *footerOpenRatioSubject = [self.footerPanSubject
                                         map:^id(id translation) {
                                             
                                             @strongify(self);
                                             
                                             CGFloat verticalTranslation = [translation floatValue];
                                             
                                             CGFloat targetTranslation = kMaximumFooterTranslationThreshold;
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
                                             
                                             return @(effectiveRatio);
                                         }];
    
    // Need to combine latest on the two signals since the footer moves with both
    RACSignal *footerFrameSignal = [[RACSignal combineLatest:@[[headerOpenRatioSubject startWith:@(0)], [footerOpenRatioSubject startWith:@(0)]]
                                                      reduce:^id(NSNumber *headerRatio, NSNumber *footerRatio){
                                                          if (headerRatio.floatValue > 0) return @(-headerRatio.floatValue);
                                                          if (footerRatio.floatValue > 0) return footerRatio;
                                                          return @(0);
                                                      }]
                                    map:^id(id value) {
                                        @strongify(self);
                                        
                                        // This is the ratio of the movement. 0 is closed and 1 is open.
                                        // Values less than zero are treated as zero.
                                        // Values greater than one are valid and will be extrapolated beyond the fully open menu.
                                        CGFloat ratio = [value floatValue];
                                        
                                        CGFloat targetTranslation = kMaximumFooterTranslationThreshold;
                                        CGRect footerFrame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - TLUpcomingEventViewControllerHiddenHeight + ratio * targetTranslation, CGRectGetWidth(self.view.bounds), TLUpcomingEventViewControllerTotalHeight);
                                        
                                        return [NSValue valueWithCGRect:footerFrame];
                                    }];
    
    RAC(self.footerViewController.view.frame) = footerFrameSignal;
    
    
    // This subject is responsible for calculating the alpha value of the overlay view
    RACSignal *dayListBlurSubject = [[RACSignal combineLatest:@[[headerOpenRatioSubject startWith:@(0)], [footerOpenRatioSubject startWith:@(0)]]
                                                       reduce:^id(NSNumber *headerRatio, NSNumber *footerRatio){
                                                           return @(MAX(headerRatio.floatValue, footerRatio.floatValue));
                                                       }]
                                     map:^id(id value) {
                                         // This is the ratio of the movement. 0 is full sized and 1 is fully shrunk.
                                         CGFloat ratio = [value floatValue];
                                         
                                         if (ratio > 1.0f)
                                         {
                                             ratio = 1.0f;
                                         }
                                         else if (ratio < 0.0f)
                                         {
                                             ratio = 0.0f;
                                         }
                                         
                                         return @(ratio);
                                     }];
    
    RAC(self.dayListOverlayView.alpha) = dayListBlurSubject;

    
    // These subjects are responsible for mapping this value to other signals and state (ugh).
    self.headerFinishedTransitionSubject = [RACReplaySubject subject];
    [self.headerFinishedTransitionSubject subscribeNext:^(NSNumber *menuIsOpenNumber) {
        @strongify(self);
        
        BOOL menuIsOpen = menuIsOpenNumber.boolValue;
        
        if (menuIsOpen)
        {
            [self.headerViewController flashScrollBars];
        }
        
        if (!menuIsOpen)
        {
            [self.dayListOverlaySubject sendNext:menuIsOpenNumber];
        }
    }];
    
    self.footerFinishedTransitionSubject = [RACReplaySubject subject];
    [self.footerFinishedTransitionSubject subscribeNext:^(NSNumber *menuIsOpenNumber) {
        @strongify(self);
        
        BOOL menuIsOpen = menuIsOpenNumber.boolValue;
        
        if (!menuIsOpen)
        {
            [self.dayListAndHeaderOverlaySubject sendNext:menuIsOpenNumber];
        }
    }];
    
    RACSignal *canOpenMenuSignal = [RACSignal combineLatest:@[[self.headerFinishedTransitionSubject startWith:@(NO)], [self.footerFinishedTransitionSubject startWith:@(NO)]]
                                                     reduce:^(NSNumber *headerIsOpen, NSNumber *footerIsOpen) {
                                                         return @(!headerIsOpen.boolValue && !footerIsOpen.boolValue);
                                                     }];
    
    RAC(self.panHeaderDownGestureRecognizer.enabled) = canOpenMenuSignal;
    RAC(self.panFooterUpGestureRecognizer.enabled) = canOpenMenuSignal;
    RAC(self.dayListViewController.view.userInteractionEnabled) = canOpenMenuSignal;
    RAC(self.panFooterDownGestureRecognizer.enabled) = self.footerFinishedTransitionSubject;
    RAC(self.panHeaderUpGestureRecognizer.enabled) = self.headerFinishedTransitionSubject;
    RAC(self.tapGestureRecognizer.enabled) = self.headerFinishedTransitionSubject;
    
        
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
    
    self.dayListOverlayView = [[UIImageView alloc] init];
    self.dayListOverlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    self.dayListOverlayView.frame = self.view.frame;
    self.dayListOverlayView.userInteractionEnabled = YES; //this will absorb any interaction while in the view hierarchy
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up our gesture recognizers.
    // These mostly grab their translations and feed them into the appropriate subjects.
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [UIView animateWithDuration:0.25f animations:^{
            [self.headerPanSubject sendNext:@(0)];
        } completion:^(BOOL finished) {
            [self.headerFinishedTransitionSubject sendNext:@(NO)];
        }];
    }];
    self.tapGestureRecognizer.delegate = self;
    [self.dayListOverlayView addGestureRecognizer:self.tapGestureRecognizer];
    
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
            [self.headerPanSubject sendNext:@(translation.y)];
        }
        else if (state == UIGestureRecognizerStateEnded)
        {
            // Determine the direction the finger is moving and ensure if it was moving down, that it exceeds the minimum threshold for opening the menu.
            BOOL movingDown = ([recognizer velocityInView:self.view].y > 0 && translation.y > kMoveDownThreshold);
            
            // Animate the change
            [UIView animateWithDuration:0.25f animations:^{
                if (movingDown)
                {
                    [self.headerPanSubject sendNext:@(kMaximumHeaderTranslationThreshold)];
                }
                else
                {
                    [self.headerPanSubject sendNext:@(0)];
                }
            } completion:^(BOOL finished) {
                [self.headerFinishedTransitionSubject sendNext:@(movingDown)];
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
            [self.headerPanSubject sendNext:@(kMaximumHeaderTranslationThreshold + translation.y)];
        }
        else if (state == UIGestureRecognizerStateEnded)
        {
            // Determine the direction the finger is moving
            BOOL movingDown = ([recognizer velocityInView:self.view].y > 0);
            
            // Animate the change
            [UIView animateWithDuration:0.25f animations:^{
                if (movingDown)
                {
                    [self.headerPanSubject sendNext:@(kMaximumHeaderTranslationThreshold)];
                }
                else
                {
                    [self.headerPanSubject sendNext:@(0)];
                }
            } completion:^(BOOL finished) {
                [self.headerFinishedTransitionSubject sendNext:@(movingDown)];
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
            [self.dayListAndHeaderOverlaySubject sendNext:@(YES)];
        }
        else if (state == UIGestureRecognizerStateChanged)
        {
            [self.footerPanSubject sendNext:@(translation.y)];
        }
        else if (state == UIGestureRecognizerStateEnded)
        {
            // Determine the direction the finger is moving and ensure if it was moving down, that it exceeds the minimum threshold for opening the menu.
            BOOL movingUp = [recognizer velocityInView:self.view].y < 0;
            
            // Animate the change
            [UIView animateWithDuration:0.25f animations:^{
                if (movingUp)
                {
                    [self.footerPanSubject sendNext:@(kMaximumFooterTranslationThreshold)];
                }
                else
                {
                    [self.footerPanSubject sendNext:@(0)];
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
            [self.footerPanSubject sendNext:@(kMaximumFooterTranslationThreshold + translation.y)];
        }
        else if (state == UIGestureRecognizerStateEnded)
        {
            // Determine the direction the finger is moving
            BOOL movingDown = ([recognizer velocityInView:self.view].y > 0);
            
            // Animate the change
            [UIView animateWithDuration:0.25f animations:^{
                if (movingDown)
                {
                    [self.footerPanSubject sendNext:@(CGRectGetHeight(self.view.bounds) - TLUpcomingEventViewControllerHiddenHeight)];
                }
                else
                {
                    [self.footerPanSubject sendNext:@(kMaximumFooterTranslationThreshold)];
                }
            } completion:^(BOOL finished) {
                [self.footerFinishedTransitionSubject sendNext:@(!movingDown)];
            }];
        }
    }];
    self.panFooterDownGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.panFooterDownGestureRecognizer];
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

-(void)userDidInteractWithDayListView:(TLEventViewController *)controller updateTimeHour:(NSInteger)hour minute:(NSInteger)minute event:(EKEvent *)event
{
    [self.headerViewController updateHour:hour minute:minute event:event];
}

@end
