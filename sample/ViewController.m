//
//  ViewController.m
//  sample
//
//  Created by Arie on 10/13/16.
//  Copyright © 2016 Arie. All rights reserved.
//

#import "ViewController.h"
#import <MidtransKit/MidtransKit.h>
#import <MidtransCoreKit/MidtransCoreKit.h>
static NSString * const kClientKey = @"client_key";
static NSString * const kMerchantURL = @"merchant_url";
static NSString * const kEnvironment = @"environment";
static NSString * const kTimeoutInterval = @"timeout_interval";
@interface ViewController () <MidtransPaymentWebControllerDelegate,MidtransUIPaymentViewControllerDelegate>
@property (nonatomic) NSArray <MidtransItemDetail*>* itemDetails;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemDetails = [self generateItemDetails];
    [MidtransConfig setClientKey:@"VT-client-6_dY49SlR_Ph32_1" serverEnvironment:0 merchantURL:@"http://mobile-snap-sandbox.herokuapp.com"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)checkoutButtonDidTapped:(id)sender {
    MidtransAddress *shipAddr = [MidtransAddress new];
    MidtransAddress *billAddr = [MidtransAddress new];
    MidtransCustomerDetails *customerDetails = [[MidtransCustomerDetails alloc] initWithFirstName:@"FirstName" lastName:@"LastName" email:@"mail@mailinator.com" phone:@"0814444478738"shippingAddress:shipAddr billingAddress:billAddr];

    MidtransTransactionDetails *transactionDetails = [[MidtransTransactionDetails alloc] initWithOrderID:[NSString randomWithLength:20] andGrossAmount:[self grossAmountOfItemDetails:self.itemDetails]];
    [[MidtransMerchantClient sharedClient] requestTransactionTokenWithTransactionDetails:transactionDetails itemDetails:self.itemDetails customerDetails:customerDetails completion:^(MidtransTransactionTokenResponse * _Nullable token, NSError * _Nullable error)
     {
         NSLog(@"token-->%@",token);
         if (!error) {
             MidtransUIPaymentViewController *paymentVC = [[MidtransUIPaymentViewController alloc] initWithToken:token andUsingScanCardMethod:YES];
             paymentVC.delegate = self;

             [self presentViewController:paymentVC animated:YES completion:nil];
         }
         else {
             NSLog(@"error connection");
         }
     }];
}

#pragma mark - Helper

- (NSNumber *)grossAmountOfItemDetails:(NSArray<MidtransItemDetail*>*)itemDetails {
    double totalPrice = 0;
    for (MidtransItemDetail *itemDetail in itemDetails) {
        totalPrice += (itemDetail.price.doubleValue * itemDetail.quantity.integerValue);
    }
    return @(totalPrice);
}
- (UIColor *)myThemeColor {
    NSData *themeColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"theme_color"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:themeColorData];
}

- (MidtransUIFontSource *)myFontSource {
    NSString *fontNameBold;
    NSString *fontNameRegular;
    NSString *fontNameLight;
    NSArray *fontNames = [[NSUserDefaults standardUserDefaults] objectForKey:@"custom_font"];
    for (NSString *fontName in fontNames) {
        if ([fontName rangeOfString:@"-bold" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            fontNameBold = fontName;
        } else if ([fontName rangeOfString:@"-regular" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            fontNameRegular = fontName;
        } else if ([fontName rangeOfString:@"-light" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            fontNameLight = fontName;
        }
    }
    return [[MidtransUIFontSource alloc] initWithFontNameBold:fontNameBold fontNameRegular:fontNameRegular fontNameLight:fontNameLight];
}
- (NSArray *)generateItemDetails {
    NSMutableArray *result = [NSMutableArray new];
    for (int i=0; i<6; i++) {
        MidtransItemDetail *itemDetail = [[MidtransItemDetail alloc] initWithItemID:[NSString randomWithLength:20] name:[NSString stringWithFormat:@"Item %i", i] price:@1000 quantity:@3];
        itemDetail.imageURL = [NSURL URLWithString:@"http://ecx.images-amazon.com/images/I/41blp4ePe8L._AC_UL246_SR190,246_.jpg"];
        [result addObject:itemDetail];
    }
    return result;
}

@end
