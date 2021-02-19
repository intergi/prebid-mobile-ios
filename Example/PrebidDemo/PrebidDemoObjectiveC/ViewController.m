/*   Copyright 2018-2019 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

@import GoogleMobileAds;
@import PrebidMobile;

#import "ViewController.h"
#import "MoPub.h"

@interface ViewController () <GADBannerViewDelegate, MPAdViewDelegate, MPInterstitialAdControllerDelegate>
    @property (weak, nonatomic) IBOutlet UIView *bannerView;
    @property (nonatomic, strong) GAMBannerView *dfpView;
    @property (nonatomic, strong) GAMRequest *request;
    @property (nonatomic, strong) MPAdView *mopubAdView;
    @property (nonatomic, strong) MPInterstitialAdController *mopubInterstitial;
    @property (nonatomic, strong) BannerAdUnit *bannerUnit;
    @property (nonatomic, strong) InterstitialAdUnit *interstitialUnit;
    
    @end

@implementation ViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    Prebid.shared.prebidServerAccountId = @"bfa84af2-bd16-4d35-96ad-31c6bb888df0";
    Prebid.shared.prebidServerHost = PrebidHostAppnexus;
    Prebid.shared.shareGeoLocation = true;
    // NSError* err=nil;
    // [[Prebid shared] setCustomPrebidServerWithUrl:@"" error:&err];
    // if(err == nil)
    
    self.bannerUnit = [[BannerAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45" size:CGSizeMake(300, 250)];
    self.interstitialUnit = [[InterstitialAdUnit alloc] initWithConfigId:@"625c6125-f19e-4d5b-95c5-55501526b2a4"];
    
//    Advanced interstitial support
//    self.interstitialUnit = [[InterstitialAdUnit alloc] initWithConfigId:@"625c6125-f19e-4d5b-95c5-55501526b2a4" minWidthPerc:50 minHeightPerc:70];
    
//    [self enableCOPPA];
//    [self addFirstPartyData:self.bannerUnit];
//    [self setStoredResponse];
//    [self setRequestTimeoutMillis];
    
    if([self.adUnit isEqualToString:@"Banner"]) {
        
        if ([self.adServer isEqualToString:@"DFP"]) {
            [self loadDFPBanner];
        } else if ([self.adServer isEqualToString:@"MoPub"]) {
            [self loadMoPubBanner];
        }
    } else if ([self.adUnit isEqualToString:@"Interstitial"]) {
        
        if ([self.adServer isEqualToString:@"DFP"]) {
            [self loadDFPInterstitial];
        } else if ([self.adServer isEqualToString:@"MoPub"]) {
            [self loadMoPubInterstitial];
        }
    }
    // Do any additional setup after loading the view, typically from a nib.
}
    
-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.bannerUnit stopAutoRefresh];
}
    
    
    
-(void) loadDFPBanner {
    
    [self.bannerUnit setAutoRefreshMillisWithTime:35000];
    self.dfpView = [[GAMBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
    self.dfpView.rootViewController = self;
    self.dfpView.adUnitID = @"/19968336/PrebidMobileValidator_Banner_All_Sizes";
    self.dfpView.delegate = self;
    [self.bannerView addSubview:self.dfpView];
    self.dfpView.backgroundColor = [UIColor redColor];
    self.request = [[GAMRequest alloc] init];

    [self.bannerUnit fetchDemandWithAdObject:self.request completion:^(enum ResultCode result) {
        NSLog(@"Prebid demand result %ld", (long)result);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dfpView loadRequest:self.request];
        });
    }];
}
    
-(void) loadDFPInterstitial {
    
    self.request = [[GAMRequest alloc] init];
    [self.interstitialUnit fetchDemandWithAdObject:self.request completion:^(enum ResultCode result) {
        NSLog(@"Prebid demand result %ld", (long)result);

        [GAMInterstitialAd loadWithAdManagerAdUnitID:@"/19968336/PrebidMobileValidator_Interstitial" request:self.request completionHandler:^(GAMInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
                return;
            }
            [interstitialAd presentFromRootViewController:self];
        }];

    }];
}
    
-(void) loadMoPubBanner {
    
    MPMoPubConfiguration *configuration = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"a935eac11acd416f92640411234fbba6"];
    
    [[MoPub sharedInstance] initializeSdkWithConfiguration:configuration completion:^{
        
    }];
    self.mopubAdView = [[MPAdView alloc] initWithAdUnitId:@"a935eac11acd416f92640411234fbba6" size:CGSizeMake(300, 250)];
    self.mopubAdView.delegate = self;
    
    [self.bannerView addSubview:self.mopubAdView];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self.bannerUnit fetchDemandWithAdObject:self.mopubAdView completion:^(enum ResultCode result) {         
        NSLog(@"Prebid demand result %ld", (long)result);
        [self.mopubAdView loadAd];
    }];
}
    
-(void) loadMoPubInterstitial {
    
    MPMoPubConfiguration *configuration = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"2829868d308643edbec0795977f17437"];
    [[MoPub sharedInstance] initializeSdkWithConfiguration:configuration completion:nil];
    self.mopubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"2829868d308643edbec0795977f17437"];
    self.mopubInterstitial.delegate = self;
    [self.interstitialUnit fetchDemandWithAdObject:self.mopubInterstitial completion:^(enum ResultCode result) {
        NSLog(@"Prebid demand result %ld", (long)result);
        [self.mopubInterstitial loadAd];
    }];
    
    
}

-(void) enableCOPPA {
    Targeting.shared.subjectToCOPPA = true;
}

-(void) addFirstPartyData:(AdUnit *)adUnit {
    //Access Control List
    [Targeting.shared addBidderToAccessControlList: Prebid.bidderNameAppNexus];

    //global user data
    [Targeting.shared addUserDataWithKey:@"globalUserDataKey1" value:@"globalUserDataValue1"];

    //global context data
    [Targeting.shared addContextDataWithKey:@"globalContextDataKey1" value:@"globalContextDataValue1"];

    //adunit context data
    [adUnit addContextDataWithKey:@"adunitContextDataKey1" value:@"adunitContextDataValue1"];

    //global context keywords
    [Targeting.shared addContextKeyword:@"globalContextKeywordValue1"];
    [Targeting.shared addContextKeyword:@"globalContextKeywordValue2"];

    //global user keywords
    [Targeting.shared addUserKeyword:@"globalUserKeywordValue1"];
    [Targeting.shared addUserKeyword:@"globalUserKeywordValue2"];

    //adunit context keywords
    [adUnit addContextKeyword:@"adunitContextKeywordValue1"];
    [adUnit addContextKeyword:@"adunitContextKeywordValue2"];
}

-(void) setStoredResponse {
    Prebid.shared.storedAuctionResponse = @"111122223333";
}

-(void) setRequestTimeoutMillis {
    Prebid.shared.timeoutMillis = 5000;
}

#pragma mark :- DFP banner delegates

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"Ad received");
    
    [AdViewUtils findPrebidCreativeSize:bannerView
                                   success:^(CGSize size) {
                                       if ([bannerView isKindOfClass:[GAMBannerView class]]) {
                                           GAMBannerView *dfpBannerView = (GAMBannerView *)bannerView;
                                           
                                           [dfpBannerView resize:GADAdSizeFromCGSize(size)];
                                       }
                                   } failure:^(NSError * _Nonnull error) {
                                       NSLog(@"error: %@", error);
                                   }];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", error.localizedDescription);
}
    


#pragma mark :- Mopub delegates
-(void) adViewDidLoadAd:(MPAdView *)view {
    NSLog(@"Ad received");
}

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    NSLog(@"Ad ready");
    if (self.mopubInterstitial.ready) {
        [self.mopubInterstitial showFromViewController:self];
    }
}
- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    NSLog(@"Ad not ready");
}


@end
