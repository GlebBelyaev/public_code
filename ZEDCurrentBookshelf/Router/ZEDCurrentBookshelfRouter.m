//
//  ZEDCurrentZEDBookshelfRouter.m
//  beebooks.ios
//
//  Created by g.belyaev on 02/07/2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import "ZEDCurrentBookshelfRouter.h"

#import "ZEDAboutBookModuleInput.h"
#import "ZEDAddToBookshelfActionSheetModuleInput.h"

#import "ZEDBook.h"

@implementation ZEDCurrentBookshelfRouter

- (void)openAboutBookModuleWithBook:(ZEDBook *)book {
    RamblerViperOpenModulePromise *modulePromise = [self.transitionHandler openModuleUsingSegue:@"AboutBook"];
    [modulePromise thenChainUsingBlock:^id<RamblerViperModuleOutput>(id<ZEDAboutBookModuleInput> moduleInput) {
        [moduleInput configureModuleWithBook:book];
        return self.outputForOtherModule;
    }];
}

@end
