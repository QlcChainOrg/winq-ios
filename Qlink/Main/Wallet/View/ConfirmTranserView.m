//
//  ConfirmTranserView.m
//  Qlink
//
//  Created by 旷自辉 on 2020/10/28.
//  Copyright © 2020 pan. All rights reserved.
//

#import "ConfirmTranserView.h"
#import "GlobalConstants.h"
#import "UIView+PopAnimate.h"
#import "WalletCommonModel.h"
#import "ContractETHRequest.h"
#import "RLArithmetic.h"
#import "TokenPriceModel.h"
#import "TokenListHelper.h"
#import "ETHAddressInfoModel.h"

@interface ConfirmTranserView()

@property (weak, nonatomic) IBOutlet UIView *tipView;

@property (weak, nonatomic) IBOutlet UILabel *fromWalletAddressLab;
@property (weak, nonatomic) IBOutlet UILabel *toWalletAddressLab;
@property (weak, nonatomic) IBOutlet UILabel *lblGasLimit;


@property (weak, nonatomic) IBOutlet UIView *slowBack;
@property (weak, nonatomic) IBOutlet UILabel *lblSlowEth;
@property (weak, nonatomic) IBOutlet UILabel *lblSlowPrice;
@property (weak, nonatomic) IBOutlet UIButton *slowBtn;

@property (weak, nonatomic) IBOutlet UIView *averageBack;
@property (weak, nonatomic) IBOutlet UILabel *lblAverageEth;
@property (weak, nonatomic) IBOutlet UILabel *lblAveratePrice;
@property (weak, nonatomic) IBOutlet UIButton *averageBtn;

@property (weak, nonatomic) IBOutlet UIView *fastBack;
@property (weak, nonatomic) IBOutlet UILabel *lblFastEth;
@property (weak, nonatomic) IBOutlet UILabel *lblFastPrice;
@property (weak, nonatomic) IBOutlet UIButton *fastBtn;

@property (nonatomic, assign) NSInteger selectTag;

@property (nonatomic, strong) NSString *slowGasPrice;
@property (nonatomic, strong) NSString *averagegasPrice;
@property (nonatomic, strong) NSString *fastGasPrice;

@property (nonatomic, strong) NSString *slowETHPrice;
@property (nonatomic, strong) NSString *averageETHPrice;
@property (nonatomic, strong) NSString *fastETHPrice;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *acrivityView;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;


@property (nonatomic, strong) NSArray *ethSource;
//@property (nonatomic, strong) NSString *ethAssetNum;
@property (nonatomic, strong) NSString *ethAddress;
@property (nonatomic, strong) NSMutableArray *tokenPriceArr;

@end

@implementation ConfirmTranserView

+ (instancetype)getInstance {
    ConfirmTranserView *view = [[[NSBundle mainBundle] loadNibNamed:@"ConfirmTranserView" owner:self options:nil] lastObject];
    [view.tipView cornerRadius:8];
    
    [view.slowBack cornerRadius:5];
    [view.averageBack cornerRadius:5];
    [view.fastBack cornerRadius:5];
    
    view.slowBack.layer.borderWidth = 1;
    view.slowBack.layer.borderColor = UIColor_RGB(235, 235, 235).CGColor;
    
    view.averageBack.layer.borderWidth = 1;
    view.averageBack.layer.borderColor = UIColor_RGB(235, 235, 235).CGColor;
    
    view.fastBack.layer.borderWidth = 1;
    view.fastBack.layer.borderColor = UIColor_RGB(235, 235, 235).CGColor;
    
    view.selectTag = 2;
    view.averageBack.backgroundColor = UIColor_RGB(235, 235, 235);
    
   
    return view;
}

- (void)configWithFromAddress:(NSString *)fromAddress toAddress:(NSString *)toAddress gasLimit:(NSString *)gasLimit
{
    _toWalletAddressLab.text = toAddress;
    _fromWalletAddressLab.text = fromAddress;
    _lblGasLimit.text = [NSString stringWithFormat:@"%ld",[self numberWithHexString:gasLimit]];

  
  // self.ethAssetNum = @"";
  // [self getEthBlaneOf:fromAddress];
   self.confirmBtn.enabled = NO;
   self.tokenPriceArr = [NSMutableArray array];
   [self getGasPrice];
   [self requestTokenPrice];
}

- (void) refreshGasCost
{
    
    [self.acrivityView stopAnimating];
    self.acrivityView.hidden = YES;
    _confirmBtn.enabled = YES;
    
    __block NSString *ethPrice = @"";
    [_tokenPriceArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TokenPriceModel *model = obj;
        if ([model.symbol isEqualToString:@"ETH"]) {
            ethPrice = model.price;
            *stop = YES;
        }
    }];
    // model.price
   
    NSString *decimals = ETH_Decimals;
    NSNumber *decimalsNum = @([[NSString stringWithFormat:@"%@",decimals] doubleValue]);
    _averageETHPrice = @([self.averagegasPrice integerValue]).mul(@"100000").mul(decimalsNum);

    _lblAverageEth.text = [_averageETHPrice stringByAppendingString:@"ETH"];
    _lblAveratePrice.text = [NSString stringWithFormat:@"%@%@",[ConfigUtil getLocalUsingCurrencySymbol],[NSString stringWithFormat:@"%.2f",[_averageETHPrice.mul(ethPrice) floatValue]]];
    
    
    _slowETHPrice = @([self.slowGasPrice integerValue]).mul(@"100000").mul(decimalsNum);
    _lblSlowEth.text = [_slowETHPrice stringByAppendingString:@"ETH"];
    _lblSlowPrice.text = [NSString stringWithFormat:@"%@%@",[ConfigUtil getLocalUsingCurrencySymbol],[NSString stringWithFormat:@"%.2f",[_slowETHPrice.mul(ethPrice) floatValue]]];

    _fastETHPrice = @([self.fastGasPrice integerValue]).mul(@"100000").mul(decimalsNum);
    _lblFastEth.text = [_fastETHPrice stringByAppendingString:@"ETH"];
    _lblFastPrice.text = [NSString stringWithFormat:@"%@%@",[ConfigUtil getLocalUsingCurrencySymbol],[NSString stringWithFormat:@"%.2f",[_fastETHPrice.mul(ethPrice) floatValue]]];


}

- (void) getGasPrice
{
    kWeakSelf(self)
    [_acrivityView startAnimating];
    [RequestService requestWithUrl10:ethEth_gasPrice_Url params:@{} httpMethod:HttpMethodPost serverType:RequestServerTypeNormal successBlock:^(NSURLSessionDataTask *dataTask, id responseObject) {
       
         if ([[responseObject objectForKey:Server_Code] integerValue] == 0) {
             NSString *jsonString = [responseObject objectForKey:@"gasPrice"];
             NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
             NSError *err;
             NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&err];
             if (!err) {
                 NSDictionary *resultDic = dic[@"result"]?:@{};
                 weakself.averagegasPrice = [resultDic objectForKey:@"ProposeGasPrice"];
                 weakself.slowGasPrice = [resultDic objectForKey:@"SafeGasPrice"];
                 weakself.fastGasPrice = [resultDic objectForKey:@"FastGasPrice"];
                 
                 if (weakself.tokenPriceArr.count > 0) {
                     [weakself refreshGasCost];
                 }
             }
         } else {
             [weakself.acrivityView stopAnimating];
             weakself.acrivityView.hidden = YES;
         }
    } failedBlock:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [weakself.acrivityView stopAnimating];
        weakself.acrivityView.hidden = YES;
    }];
}

- (void) getEthBlaneOf:(NSString *) address
{
    kWeakSelf(self)
    [TokenListHelper requestETHAssetWithAddress:address?:@"" tokenName:@"ETH" completeBlock:^(ETHAddressInfoModel *infoM, Token * _Nonnull tokenM, Token * _Nonnull ethTokenM, BOOL success) {
        weakself.ethSource = infoM.tokens?:@[];
              // weakself.selectToken = tokenM;
               //weakself.ethToken = ethTokenM;
               if (!tokenM) {
                   [kAppD.window makeToastDisappearWithText:[NSString stringWithFormat:@"%@ %@",kLang(@"current_eth_wallet_have_not"),@"ETH"]];
                   return;
               } else {
                   [_ethSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                          Token *model = obj;
                          if ([model.tokenInfo.symbol isEqualToString:@"ETH"]) {
                              //weakself.ethAssetNum = [model getTokenNum];
                              *stop = YES;
                          }
                      }];
               }
    }];
}

- (void)requestTokenPrice {
    kWeakSelf(self);
    NSString *coin = [ConfigUtil getLocalUsingCurrency];
    NSDictionary *params = @{@"symbols":@[@"ETH"],@"coin":coin};
    [RequestService requestWithUrl10:tokenPrice_Url params:params httpMethod:HttpMethodPost serverType:RequestServerTypeNormal successBlock:^(NSURLSessionDataTask *dataTask, id responseObject) {
        if ([[responseObject objectForKey:Server_Code] integerValue] == 0) {
            [weakself.tokenPriceArr removeAllObjects];
            NSArray *arr = [responseObject objectForKey:Server_Data];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TokenPriceModel *model = [TokenPriceModel getObjectWithKeyValues:obj];
                model.coin = coin;
                [weakself.tokenPriceArr addObject:model];
            }];
            if (weakself.slowGasPrice && weakself.slowGasPrice.length > 0) {
               [weakself refreshGasCost];
           }
        } else {
            [weakself.acrivityView stopAnimating];
            weakself.acrivityView.hidden = YES;
        }
    } failedBlock:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [weakself.acrivityView stopAnimating];
        weakself.acrivityView.hidden = YES;
    }];
}

#pragma mark --Option
- (void)show {
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [kAppD.window addSubview:self];
    [self.tipView showPopAnimate];
}
- (void)hide {
    [self removeFromSuperview];
}



- (IBAction)clickConfirmAction:(id)sender {
    
    NSString *gasPrice = @"";
    NSString *ethPrice = @"";
    if (_selectTag == 1) {
        gasPrice = _slowGasPrice;
        ethPrice = _slowETHPrice;
    } else if (_selectTag == 2) {
        gasPrice = _averagegasPrice;
        ethPrice = _averageETHPrice;
    } else {
        gasPrice = _fastGasPrice;
        ethPrice = _fastETHPrice;
    }
    
    if (_confirmBlock) {
        _confirmBlock(YES,gasPrice);
    }
    [self hide];
}
- (IBAction)cliceCloseAction:(id)sender {
    if (_confirmBlock) {
        _confirmBlock(NO,@"");
    }
    [self hide];
}

- (IBAction)clcikGasFeeAction:(UIButton *)sender {
    
    if (sender.tag == _selectTag) {
        
    } else {
        if (_selectTag == 1) {
            _slowBack.backgroundColor = [UIColor whiteColor];
        } else if (_selectTag == 2) {
            _averageBack.backgroundColor = [UIColor whiteColor];
        } else {
            _fastBack.backgroundColor = [UIColor whiteColor];
        }
        _selectTag = sender.tag;
        
        if (_selectTag == 1) {
            _slowBack.backgroundColor = UIColor_RGB(235, 235, 235);
        } else if (_selectTag == 2) {
            _averageBack.backgroundColor = UIColor_RGB(235, 235, 235);
        } else {
            _fastBack.backgroundColor = UIColor_RGB(235, 235, 235);
        }
    }
}

- (NSInteger)numberWithHexString:(NSString *)hexString{

    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    
    int hexNumber;
    
    sscanf(hexChar, "%x", &hexNumber);
    
    NSLog(@"%ld", (NSInteger)hexNumber);
    
    return (NSInteger)hexNumber;
}
@end