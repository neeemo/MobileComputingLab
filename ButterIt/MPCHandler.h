//
//  MPCHandler.h
//  MPCDemo
//
//  Created by Steven Teng on 01/12/14.
//  Copyright (c) 2014 Steven Teng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MPCHandler : NSObject <MCSessionDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) MCNearbyServiceBrowser *nearbyBrowser;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;

+ (MPCHandler *)sharedInstance;

- (void)setupPeerWithDisplayName:(NSString *)displayName;
- (void)setupSession;
- (void)setupBrowser;
- (void)advertiseSelf:(BOOL)advertise;


- (MCPeerID *)getConnectedPeer:(NSInteger)index;
- (NSArray *)getConnectedPeers;
- (void)requireDeviceConnected:(UIViewController*)vc;
- (void)disconnect;


@end
