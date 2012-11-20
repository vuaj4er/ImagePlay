//
//  PhotoEditor.h
//  Two
//
//  Created by vuaj4er on 12/11/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum
{
    PhotoHorizontal,
    PhotoVertical
} PhotoOrientation;

@interface PhotoEditor

+ (UIImage *)PhotoWindow:(NSArray *)imageArray
        withOrientation:(PhotoOrientation)orientation 
                  Range:(CGRect) range;
+ (UIImage *)PhotoCombine:(UIImage *)frontImage
                  Image:(UIImage *)endImage
        withOrientation:(PhotoOrientation)orientation;
+ (UIImage *)PhotoCut:(UIImage *)image
               inRect:(CGRect)rect;

@end
