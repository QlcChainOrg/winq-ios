//
//  MnemonicTipView.h
//  Qlink
//
//  Created by Jelly Foo on 2018/10/23.
//  Copyright © 2018 pan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NeoClaimGasBlock)(void);

@interface NeoClaimGasTipView : UIView

@property (nonatomic, copy) NeoClaimGasBlock claimBlock;
@property (nonatomic, copy) NeoClaimGasBlock closeBlock;

+ (instancetype)getInstance;
- (void)showWithNum:(NSString *)num;

@end

NS_ASSUME_NONNULL_END
