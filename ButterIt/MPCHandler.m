//
//  MPCHandler.m
//  MPCDemo
//
//  Created by Steven Teng on 01/12/14.
//  Copyright (c) 2014 Steven Teng. All rights reserved.
//

#import "MPCHandler.h"

@implementation MPCHandler

#pragma mark -
#pragma mark Public Methods
- (void)setupPeerWithDisplayName:(NSString *)displayName {
    self.peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
}

- (void)setupSession {
    self.session = [[MCSession alloc] initWithPeer:self.peerID];
    self.session.delegate = self;
}

- (void)setupBrowser {
    self.browser = [[MCBrowserViewController alloc] initWithServiceType:@"my-game" session:_session];
    self.nearbyBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:@"my-game"];
}

- (void)advertiseSelf:(BOOL)advertise {
    if (advertise) {
        self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"my-game" discoveryInfo:nil session:self.session];
        [self.advertiser start];
        
    } else {
        [self.advertiser stop];
        self.advertiser = nil;
    }
}

#pragma mark -
#pragma mark Session Delegate Methods
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    NSDictionary *userInfo = @{ @"peerID": peerID,
                                @"state" : @(state) };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ButterIt_DidChangeStateNotification"
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary *userInfo = @{ @"data": data,
                                @"peerID": peerID };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ButterIt_DidReceiveDataNotification"
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

- (MCPeerID *)getConnectedPeer:(NSInteger)index{
    return [self.session.connectedPeers objectAtIndex:index];
}

- (NSArray *)getConnectedPeers{
    return self.session.connectedPeers;
}

- (void)requireDeviceConnected:(UIViewController*)vc{
    //if(self.session.connectedPeers.count == 0) {
        [self setupBrowser];
        [vc presentViewController:self.browser animated:YES completion:nil];
    //}
}

- (void)disconnect{
    [self.session disconnect];
    [self advertiseSelf:NO];
}

@end