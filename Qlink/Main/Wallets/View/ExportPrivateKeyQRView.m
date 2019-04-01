//
//  MnemonicTipView.m
//  Qlink
//
//  Created by Jelly Foo on 2018/10/23.
//  Copyright © 2018 pan. All rights reserved.
//

#import "ExportPrivateKeyQRView.h"
#import "UIView+Visuals.h"
#import "HMScanner.h"

@interface ExportPrivateKeyQRView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIView *tipBack;
@property (weak, nonatomic) IBOutlet UIImageView *qrImage;

@property (nonatomic, strong) NSString *privateKey;

@end

@implementation ExportPrivateKeyQRView

+ (instancetype)getInstance {
    ExportPrivateKeyQRView *view = [[[NSBundle mainBundle] loadNibNamed:@"ExportPrivateKeyQRView" owner:self options:nil] lastObject];
    [view.tipBack cornerRadius:8];
    UIColor *borderColor = UIColorFromRGB(0xE8EAEC);
//    [view.textBack cornerRadius:6 strokeSize:1 color:borderColor];
    return view;
}

- (void)showWithPrivateKey:(NSString *)privateKey title:(NSString *)title {
    _titleLab.text = title;
    _privateKey = privateKey;
//    _textV.text = _privateKey;
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [kAppD.window addSubview:self];
    
    kWeakSelf(self);
    [HMScanner qrImageWithString:_privateKey?:@"" avatar:nil completion:^(UIImage *image) {
        weakself.qrImage.image = image;
    }];
}

- (void)hide {
    [self removeFromSuperview];
}

- (IBAction)copyAction:(id)sender {
//    if (_copyBlock) {
//        _copyBlock();
//    }
    if (_qrImage.image == nil) {
        return;
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//    pasteboard.string = _privateKey;
    pasteboard.image = _qrImage.image;
    [kAppD.window makeToastDisappearWithText:@"Copied"];
    [self hide];
}

- (IBAction)QRCode:(id)sender {
    [self hide];
}

- (IBAction)closeAction:(id)sender {
    [self hide];
}


@end
