//
//  UIImage+Blur.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-23.
//  Originally created by Bryan Clark https://github.com/bryanjclark/ios-darken-image-with-cifilter
//

#import "UIImage+Blur.h"
#import <CoreImage/CoreImage.h>

@implementation UIImage (Blur)

+(UIImage *)darkenedAndBlurredImageForImage:(UIImage *)image {
    CGFloat scaleFactor = 1.0f;

    if (AppDelegate.device == TLAppDelegateDeviceIPhone3GS || AppDelegate.device == TLAppDelegateDeviceIPhone4) {
        scaleFactor = 0.25f;
    } else if (AppDelegate.device == TLAppDelegateDeviceIPhone4S) {
        scaleFactor = 0.5f;
    }

    CIImage *inputImage = [[[CIImage alloc] initWithImage:image] imageByApplyingTransform:CGAffineTransformMakeScale(scaleFactor, 0.25f)];

    CIContext *context = [CIContext contextWithOptions:nil];

    //First, create some darkness
    CIFilter *blackGenerator = [CIFilter filterWithName:@"CIConstantColorGenerator"];
    CIColor *black = [CIColor colorWithString:@"0.0 0.0 0.0 0.92"];
    [blackGenerator setValue:black forKey:@"inputColor"];
    CIImage *blackImage = [blackGenerator valueForKey:@"outputImage"];

    //Second, apply that black
    CIFilter *compositeFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [compositeFilter setValue:blackImage forKey:@"inputImage"];
    [compositeFilter setValue:inputImage forKey:@"inputBackgroundImage"];
    CIImage *darkenedImage = [compositeFilter outputImage];

    //Third, blur the image
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setDefaults];
    [blurFilter setValue:@(40 * scaleFactor) forKey:@"inputRadius"];
    [blurFilter setValue:darkenedImage forKey:kCIInputImageKey];
    CIImage *blurredImage = [blurFilter outputImage];

    CGImageRef cgimg = [context createCGImage:blurredImage fromRect:inputImage.extent];
    UIImage *blurredAndDarkenedImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);

    return blurredAndDarkenedImage;
}

@end
