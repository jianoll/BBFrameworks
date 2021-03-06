//
//  NSURL+BBKitExtensions.m
//  BBFrameworks
//
//  Created by William Towe on 5/13/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "NSURL+BBKitExtensions.h"
#import "BBFoundationDebugging.h"

@implementation NSURL (BBKitExtensions)

- (NSDate *)BB_creationDate; {
    NSError *outError;
    NSDate *retval = nil;
    
    if (![self getResourceValue:&retval forKey:NSURLCreationDateKey error:&outError]) {
        BBLogObject(outError);
    }
    
    return retval;
}
- (NSDate *)BB_contentModificationDate; {
    NSError *outError;
    NSDate *retval = nil;
    
    if (![self getResourceValue:&retval forKey:NSURLContentModificationDateKey error:&outError]) {
        BBLogObject(outError);
    }
    
    return retval;
}
- (BOOL)BB_isDirectory; {
    NSError *outError;
    NSNumber *retval = nil;
    
    if (![self getResourceValue:&retval forKey:NSURLIsDirectoryKey error:&outError]) {
        BBLogObject(outError);
    }
    
    return retval.boolValue;
}
- (NSString *)BB_typeIdentifier; {
    NSError *outError;
    NSString *retval = nil;
    
    if (![self getResourceValue:&retval forKey:NSURLTypeIdentifierKey error:&outError]) {
        BBLogObject(outError);
    }
    
    return retval;
}
#if (TARGET_OS_IPHONE)
- (UIImage *)BB_effectiveIcon {
#else
- (NSImage *)BB_effectiveIcon {
#endif
    NSError *outError;
#if (TARGET_OS_IPHONE)
    UIImage *retval = nil;
#else
    NSImage *retval = nil;
#endif
    
    if (![self getResourceValue:&retval forKey:NSURLEffectiveIconKey error:&outError]) {
        BBLogObject(outError);
    }
    
    return retval;
}

@end
