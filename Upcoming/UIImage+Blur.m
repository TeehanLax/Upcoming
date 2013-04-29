//
//  UIImage+Blur.m
//  Upcoming
//
//  Created by Ash Furrow on 2013-04-23.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "UIImage+Blur.h"
#import <CoreImage/CoreImage.h>

@implementation UIImage (Blur)

+ (UIImage *)darkenedAndBlurredImageForImage:(UIImage *)image
{
    CIImage *inputImage = [[[CIImage alloc] initWithImage:image] imageByApplyingTransform:CGAffineTransformMakeScale(0.25f, 0.25f)];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    //First, create some darkness
    CIFilter* blackGenerator = [CIFilter filterWithName:@"CIConstantColorGenerator"];
    CIColor* black = [CIColor colorWithString:@"0.0 0.0 0.0 0.75"];
    [blackGenerator setValue:black forKey:@"inputColor"];
    CIImage* blackImage = [blackGenerator valueForKey:@"outputImage"];
    
    //Second, apply that black
    CIFilter *compositeFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [compositeFilter setValue:blackImage forKey:@"inputImage"];
    [compositeFilter setValue:inputImage forKey:@"inputBackgroundImage"];
    CIImage *darkenedImage = [compositeFilter outputImage];
    
    //Third, blur the image
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setDefaults];
    [blurFilter setValue:@(0.5f) forKey:@"inputRadius"];
    [blurFilter setValue:darkenedImage forKey:kCIInputImageKey];
    CIImage *blurredImage = [blurFilter outputImage];
    
    CGImageRef cgimg = [context createCGImage:blurredImage fromRect:inputImage.extent];
    UIImage *blurredAndDarkenedImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    return blurredAndDarkenedImage;
}

@end
