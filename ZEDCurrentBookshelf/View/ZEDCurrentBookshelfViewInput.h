//
//  ZEDCurrentBookshelfViewInput.h
//  beebooks.ios
//
//  Created by g.belyaev on 02/07/2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZEDCurrentBookshelfViewInput

- (void)setupInitialState;
- (void)setEditing:(BOOL)editing;

- (void)updateCollections;

@end
