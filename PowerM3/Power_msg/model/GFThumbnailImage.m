//
//  GFThumbnailImage.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/22.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFThumbnailImage.h"

@implementation GFThumbnailImage

+ (BOOL)allowsReverseTransformation {
    return YES;
}

+ (Class)transformedValueClass {
    return [NSData class];
}

- (id)transformedValue:(id)value {
    return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value {
    return [[UIImage alloc] initWithData:value];
}
@end
