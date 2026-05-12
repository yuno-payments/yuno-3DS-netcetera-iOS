//
//  dummy.m
//  Yuno3DSNetceteraWrapper
//

#import "dummy.h"

@implementation Dummy
@end

// Swift Package Manager needs at least one source file in a target.
// This wrapper exists to attach linkerSettings and additional dependencies
// to the Yuno3DSNetcetera binary target (which cannot declare them itself).
