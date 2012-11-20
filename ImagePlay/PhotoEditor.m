//
//  PhotoEditor.m
//  Two
//
//  Created by vuaj4er on 12/11/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PhotoEditor.h"

@implementation PhotoEditor

#define INTERVAL_LEN 1
#define MAX_REPLACE 0.2

+ (UIImage *)PhotoWindow:(NSArray *)imageArray 
        withOrientation:(PhotoOrientation)orientation 
                  Range:(CGRect)range
{
    NSUInteger num = [imageArray count];
    if (num == 1) {
        UIImage *image = [imageArray lastObject];
        CGRect newRect = CGRectMake(0 + INTERVAL_LEN, 0 + INTERVAL_LEN, range.size.width - 2*INTERVAL_LEN, range.size.height - 2*INTERVAL_LEN);

        CGPoint centerPoint = CGPointMake(image.size.width/2, image.size.height/2);
        CGFloat imageRatio = image.size.width / image.size.height;
        CGFloat newRatio = newRect.size.width / newRect.size.height;
        CGRect cutRect;
        if (newRatio > imageRatio) {
            cutRect.size.width = image.size.width;
            cutRect.size.height = cutRect.size.width / newRatio;
        }
        else {
            cutRect.size.width = image.size.width * newRatio;
            cutRect.size.height = image.size.height;
        }
        cutRect.origin.x = centerPoint.x - cutRect.size.width/2;
        cutRect.origin.y = centerPoint.y - cutRect.size.height/2;
        image = [PhotoEditor PhotoCut:image inRect:cutRect];
        
        UIGraphicsBeginImageContext(CGSizeMake(range.size.width, range.size.height));
        [image drawInRect:newRect];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
                
        return newImage;
    }
    
    // random split place and image order
    NSUInteger mid = num / 2 + arc4random() % (num%2 + 1);
    NSMutableArray *newImageArray = [[NSMutableArray alloc] initWithArray:imageArray];
    [newImageArray insertObject:[imageArray lastObject] atIndex:(arc4random()%imageArray.count)];
    [newImageArray removeLastObject];
    
    NSRange frontRange;
    frontRange.location = 0;
    frontRange.length = mid - frontRange.location;
    NSArray *frontArray = [newImageArray subarrayWithRange:frontRange];

    NSRange endRange;
    endRange.location = mid;
    endRange.length = num - endRange.location;
    NSArray *endArray = [newImageArray subarrayWithRange:endRange];
    
    PhotoOrientation newOrientation;
    CGRect frontRect, endRect;
    if (orientation == PhotoHorizontal) {
        newOrientation = PhotoVertical;
        CGFloat d = 0;
        if (MAX_REPLACE) d = arc4random() % (int)(MAX_REPLACE*range.size.width);
        if (frontRange.length < endRange.length) d = -d;
        frontRect = CGRectMake(range.origin.x, range.origin.y, range.size.width/2 + d, range.size.height);
        endRect = CGRectMake(range.origin.x + range.size.width/2 + d, range.origin.y, range.size.width/2 - d, range.size.height);
    }
    else if (orientation == PhotoVertical) {
        newOrientation = PhotoHorizontal;
        CGFloat d = 0;
        if (MAX_REPLACE) d = arc4random() % (int)(MAX_REPLACE*range.size.height);
        if (frontRange.length < endRange.length) d = -d;
        frontRect = CGRectMake(range.origin.x, range.origin.y, range.size.width, range.size.height/2 + d);
        endRect = CGRectMake(range.origin.x, range.origin.y + range.size.height/2 + d, range.size.width, range.size.height/2 - d);
    }
    
    UIImage *frontImage = [PhotoEditor PhotoWindow:frontArray withOrientation:newOrientation Range:frontRect];
    UIImage *endImage = [PhotoEditor PhotoWindow:endArray withOrientation:newOrientation Range:endRect];

    return [PhotoEditor PhotoCombine:frontImage Image:endImage withOrientation:orientation];
}

+ (UIImage *)PhotoCombine:(UIImage *)frontImage
                    Image:(UIImage *)endImage
          withOrientation:(PhotoOrientation)orientation
{
    CGSize size;
    CGRect frontRect, endRect;
    if (orientation == PhotoHorizontal){
        size = CGSizeMake(frontImage.size.width + endImage.size.width, frontImage.size.height);
        frontRect = CGRectMake(0, 0, frontImage.size.width, frontImage.size.height);
        endRect = CGRectMake(frontImage.size.width, 0, endImage.size.width, endImage.size.height);
    }
    else {
        size = CGSizeMake(frontImage.size.width, frontImage.size.height + endImage.size.height);
        frontRect = CGRectMake(0, 0, frontImage.size.width, frontImage.size.height);
        endRect = CGRectMake(0, frontImage.size.height, endImage.size.width, endImage.size.height);
    }
    
    UIGraphicsBeginImageContext(size);
    if (frontImage) [frontImage drawInRect:frontRect];
    if (endImage) [endImage drawInRect:endRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)PhotoCut:(UIImage *)image
               inRect:(CGRect)rect
{
    CGImageRef cgImage = CGImageCreateWithImageInRect([image CGImage], rect);
    return [UIImage imageWithCGImage:cgImage];
}

@end
