//
//  ZEDCurrentZEDBookshelfAssembly.m
//  beebooks.ios
//
//  Created by g.belyaev on 02/07/2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import "ZEDCurrentBookshelfAssembly.h"

#import "ZEDCurrentBookshelfViewController.h"
#import "ZEDCurrentBookshelfInteractor.h"
#import "ZEDCurrentBookshelfPresenter.h"
#import "ZEDCurrentBookshelfRouter.h"

@implementation ZEDCurrentBookshelfAssembly

- (ZEDCurrentBookshelfViewController *)viewCurrentBookshelf {
    return [TyphoonDefinition withClass:[ZEDCurrentBookshelfViewController class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition injectProperty:@selector(output)
                                                    with:[self presenterCurrentBookshelf]];
                              [definition injectProperty:@selector(moduleInput)
                                                    with:[self presenterCurrentBookshelf]];
                          }];
}

- (ZEDCurrentBookshelfInteractor *)interactorCurrentBookshelf {
    return [TyphoonDefinition withClass:[ZEDCurrentBookshelfInteractor class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition injectProperty:@selector(output)
                                                    with:[self presenterCurrentBookshelf]];
                          }];
}

- (ZEDCurrentBookshelfPresenter *)presenterCurrentBookshelf {
    return [TyphoonDefinition withClass:[ZEDCurrentBookshelfPresenter class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition injectProperty:@selector(view)
                                                    with:[self viewCurrentBookshelf]];
                              [definition injectProperty:@selector(interactor)
                                                    with:[self interactorCurrentBookshelf]];
                              [definition injectProperty:@selector(router)
                                                    with:[self routerCurrentBookshelf]];
                          }];
}

- (ZEDCurrentBookshelfRouter *)routerCurrentBookshelf {
    return [TyphoonDefinition withClass:[ZEDCurrentBookshelfRouter class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition injectProperty:@selector(transitionHandler)
                                                    with:[self viewCurrentBookshelf]];
                              [definition injectProperty:@selector(outputForOtherModule)
                                                    with:[self presenterCurrentBookshelf]];
                          }];
}

@end
