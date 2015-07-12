//
//  TokenViewController.m
//  BBFrameworks
//
//  Created by William Towe on 7/11/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "TokenViewController.h"

#import <BBFrameworks/BBToken.h>
#import <BBFrameworks/BBFoundation.h>

@interface TokenModel : NSObject
@property (copy,nonatomic) NSString *string;
@end

@implementation TokenModel

@end

@interface TokenViewController () <BBTokenTextViewDelegate>
@property (strong,nonatomic) BBTokenTextView *tokenTextView;
@end

@implementation TokenViewController

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

- (NSString *)title {
    return [self.class rowClassTitle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self setTokenTextView:[[BBTokenTextView alloc] initWithFrame:CGRectZero]];
    [self.tokenTextView setDelegate:self];
    [self.view addSubview:self.tokenTextView];
}
- (void)viewDidLayoutSubviews {
    [self.tokenTextView setFrame:CGRectMake(8.0, [self.topLayoutGuide length] + 8.0, CGRectGetWidth(self.view.bounds) - 16.0, CGRectGetHeight(self.view.bounds) - [self.bottomLayoutGuide length] - [self.topLayoutGuide length] - 16.0)];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tokenTextView becomeFirstResponder];
}

- (id)tokenTextView:(BBTokenTextView *)tokenTextView representedObjectForEditingText:(NSString *)editingText {
    TokenModel *retval = [[TokenModel alloc] init];
    
    [retval setString:editingText];
    
    return retval;
}
- (NSArray *)tokenTextView:(BBTokenTextView *)tokenTextView shouldAddRepresentedObjects:(NSArray *)representedObjects atIndex:(NSInteger)index {
    NSMutableArray *retval = [representedObjects mutableCopy];
    
    for (TokenModel *model in representedObjects) {
        if ([model.string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]].length == 0) {
            [retval removeObject:model];
        }
    }
    
    return retval;
}
- (NSString *)tokenTextView:(BBTokenTextView *)tokenTextView displayTextForRepresentedObject:(id)representedObject {
    return [(TokenModel *)representedObject string];
}

+ (NSString *)rowClassTitle {
    return @"Tokens";
}

@end
