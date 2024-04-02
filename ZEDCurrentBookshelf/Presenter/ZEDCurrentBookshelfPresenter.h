//
//  ZEDCurrentZEDBookshelfPresenter.h
//  beebooks.ios
//
//  Created by g.belyaev on 02/07/2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import "ZEDCurrentBookshelfViewOutput.h"
#import "ZEDCurrentBookshelfInteractorOutput.h"
#import "ZEDCurrentBookshelfModuleInput.h"
#import "ZEDCurrentBookshelfModuleOutput.h"

@protocol ZEDCurrentBookshelfViewInput;
@protocol ZEDCurrentBookshelfInteractorInput;
@protocol ZEDCurrentBookshelfRouterInput;

@interface ZEDCurrentBookshelfPresenter : NSObject <ZEDCurrentBookshelfModuleInput, ZEDCurrentBookshelfViewOutput, ZEDCurrentBookshelfInteractorOutput>

@property (nonatomic, weak) id<ZEDCurrentBookshelfViewInput> view;
@property (nonatomic, strong) id<ZEDCurrentBookshelfInteractorInput> interactor;
@property (nonatomic, strong) id<ZEDCurrentBookshelfRouterInput> router;
@property (nonatomic, weak) id<ZEDCurrentBookshelfModuleOutput> moduleOutput;

@end
