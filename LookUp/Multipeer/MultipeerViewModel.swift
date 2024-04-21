//
//  MultipeerViewModel.swift
//  LookUp
//  
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import MultipeerConnectivity
import NearbyInteraction
import SwiftUI

class MultipeerViewModel: NSObject, ObservableObject, NISessionDelegate {
    // MARK: - Distance and direction state.
    
    // A threshold, in meters, the app uses to update its display.
    let nearbyDistanceThreshold: Float = 0.3
    
    enum DistanceDirectionState {
        case closeUpInFOV, notCloseUpInFOV, outOfFOV, unknown
    }
    
    // MARK: - Class variables

    var session: NISession?
    var peerDiscoveryToken: NIDiscoveryToken?
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    var currentDistanceDirectionState: DistanceDirectionState = .unknown
    var mpc: MPCSession?
    var connectedPeer: MCPeerID?
    var sharedTokenWithPeer = false
    var peerDisplayName: String?
    
    var phoneNumber: String?
    
    // nil when no peer
    @Published var distanceToPeer: Float?
    
    @Published var connectedPeerPhoneNumber: String?
    
    func stop() {
        mpc?.invalidate()
        mpc = nil
    }
    
    func startup(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        
        // Create the NISession.
        session = NISession()
        
        // Set the delegate.
        session?.delegate = self
        
        // Because the session is new, reset the token-shared flag.
        sharedTokenWithPeer = false
        
        // If `connectedPeer` exists, share the discovery token, if needed.
        if connectedPeer != nil && mpc != nil {
            if let myToken = session?.discoveryToken {
                if !sharedTokenWithPeer {
                    shareMyDiscoveryToken(token: myToken)
                }
                guard let peerToken = peerDiscoveryToken else {
                    return
                }
                let config = NINearbyPeerConfiguration(peerToken: peerToken)
                session?.run(config)
            } else {
                fatalError("Unable to get self discovery token, is this session invalidated?")
            }
        } else {
            print("Discovering...")
            startupMPC(phoneNumber: phoneNumber)
            
            // Set the display state.
            currentDistanceDirectionState = .unknown
        }
    }
    
    // MARK: - `NISessionDelegate`.
    
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let peerToken = peerDiscoveryToken else {
            fatalError("don't have peer token")
        }
        
        // Find the right peer.
        let peerObj = nearbyObjects.first { obj -> Bool in
            obj.discoveryToken == peerToken
        }
        
        guard let nearbyObjectUpdate = peerObj else {
            return
        }
        
        // Update the the state and visualizations.
        let nextState = getDistanceDirectionState(from: nearbyObjectUpdate)
        animate(from: currentDistanceDirectionState, to: nextState, with: nearbyObjectUpdate)
        currentDistanceDirectionState = nextState
    }
    
    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        guard let peerToken = peerDiscoveryToken else {
            fatalError("don't have peer token")
        }
        // Find the right peer.
        let peerObj = nearbyObjects.first { obj -> Bool in
            obj.discoveryToken == peerToken
        }
        
        if peerObj == nil {
            return
        }
        
        currentDistanceDirectionState = .unknown
        
        switch reason {
        case .peerEnded:
            // The peer token is no longer valid.
            peerDiscoveryToken = nil
            
            // The peer stopped communicating, so invalidate the session because
            // it's finished.
            session.invalidate()
            
            // Restart the sequence to see if the peer comes back.
            if let phoneNumber {
                startup(phoneNumber: phoneNumber)
            }
            
            // Update the app's display.
            print("Peer Ended")
        case .timeout:
            
            // The peer timed out, but the session is valid.
            // If the configuration is valid, run the session again.
            if let config = session.configuration {
                session.run(config)
            }
            print("Peer Timeout")
        default:
            fatalError("Unknown and unhandled NINearbyObject.RemovalReason")
        }
    }
    
    func sessionWasSuspended(_ session: NISession) {
        currentDistanceDirectionState = .unknown
        print("Session Suspended")
    }
    
    func sessionSuspensionEnded(_ session: NISession) {
        // Session suspension ended. The session can now be run again.
        if let config = self.session?.configuration {
            session.run(config)
        } else {
            // Create a valid configuration.
            if let phoneNumber {
                startup(phoneNumber: phoneNumber)
            }
        }
    }
    
    func session(_ session: NISession, didInvalidateWith error: Error) {
        currentDistanceDirectionState = .unknown
        
        // If the app lacks user approval for Nearby Interaction, present
        // an option to go to Settings where the user can update the access.
        if case NIError.userDidNotAllow = error {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
            return
        }
        
        // Recreate a valid session.
        if let phoneNumber {
            startup(phoneNumber: phoneNumber)
        }
    }
    
    // MARK: - Discovery token sharing and receiving using MPC.
    
    func startupMPC(phoneNumber: String) {
        if mpc == nil {
// Prevent Simulator from finding devices.
#if targetEnvironment(simulator)
            mpc = MPCSession(phoneNumber: phoneNumber, service: "nisample", identity: "com.example.apple-samplecode.simulator.peekaboo-nearbyinteraction", maxPeers: 1)
#else
            mpc = MPCSession(phoneNumber: phoneNumber, service: "nisample", identity: "com.example.apple-samplecode.peekaboo-nearbyinteraction", maxPeers: 1)
#endif
            mpc?.peerConnectedHandler = connectedToPeer
            mpc?.peerDataHandler = dataReceivedHandler
            mpc?.peerDisconnectedHandler = disconnectedFromPeer
        }
        mpc?.invalidate()
        mpc?.start()
    }
    
    func connectedToPeer(peer: MCPeerID) {
        guard let myToken = session?.discoveryToken else {
            fatalError("Unexpectedly failed to initialize nearby interaction session.")
        }
        
        if connectedPeer != nil {
            fatalError("Already connected to a peer.")
        }
        
        if !sharedTokenWithPeer {
            shareMyDiscoveryToken(token: myToken)
        }
        
        connectedPeer = peer
        peerDisplayName = peer.displayName
        connectedPeerPhoneNumber = peer.displayName
        
        print("CONNECTED peerDisplayName: \(peerDisplayName)")
    }
    
    func disconnectedFromPeer(peer: MCPeerID) {
        distanceToPeer = nil
        connectedPeerPhoneNumber = nil
        if connectedPeer == peer {
            connectedPeer = nil
            sharedTokenWithPeer = false
        }
    }
    
    func dataReceivedHandler(data: Data, peer: MCPeerID) {
        guard let discoveryToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) else {
            fatalError("Unexpectedly failed to decode discovery token.")
        }
        peerDidShareDiscoveryToken(peer: peer, token: discoveryToken)
    }
    
    func shareMyDiscoveryToken(token: NIDiscoveryToken) {
        guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) else {
            fatalError("Unexpectedly failed to encode discovery token.")
        }
        mpc?.sendDataToAllPeers(data: encodedData)
        sharedTokenWithPeer = true
    }
    
    func peerDidShareDiscoveryToken(peer: MCPeerID, token: NIDiscoveryToken) {
        if connectedPeer != peer {
            fatalError("Received token from unexpected peer.")
        }
        // Create a configuration.
        peerDiscoveryToken = token
        
        let config = NINearbyPeerConfiguration(peerToken: token)
        
        // Run the session.
        session?.run(config)
    }
    
    // MARK: - Visualizations

    func isNearby(_ distance: Float) -> Bool {
        return distance < nearbyDistanceThreshold
    }
    
    func isPointingAt(_ angleRad: Float) -> Bool {
        // Consider the range -15 to +15 to be "pointing at".
        return abs(angleRad * 180 / .pi) <= 15
    }
    
    func getDistanceDirectionState(from nearbyObject: NINearbyObject) -> DistanceDirectionState {
        if nearbyObject.distance == nil && nearbyObject.direction == nil {
            return .unknown
        }
        
        let isNearby = nearbyObject.distance.map(isNearby(_:)) ?? false
        let directionAvailable = nearbyObject.direction != nil
        
        if isNearby && directionAvailable {
            return .closeUpInFOV
        }
        
        if !isNearby && directionAvailable {
            return .notCloseUpInFOV
        }
        
        return .outOfFOV
    }
    
    private func animate(from currentState: DistanceDirectionState, to nextState: DistanceDirectionState, with peer: NINearbyObject) {
        // If the app transitions from unavailable, present the app's display
        // and hide the user instructions.
        if currentState == .unknown && nextState != .unknown {}
        
        if let distance = peer.distance {
//            print(String(format: "%0.2f m", distance))
            distanceToPeer = distance
        }
        // Don't update visuals if the peer device is unavailable or out of the
        // U1 chip's field of view.
        if nextState == .outOfFOV || nextState == .unknown {
            return
        }
    }
}

enum MPCSessionConstants {
    static let kKeyIdentity: String = "identity"
}

class MPCSession: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    var peerDataHandler: ((Data, MCPeerID) -> Void)?
    var peerConnectedHandler: ((MCPeerID) -> Void)?
    var peerDisconnectedHandler: ((MCPeerID) -> Void)?
    
    private let localPeerID: MCPeerID
    private let serviceString: String
    private let mcSession: MCSession
    private let mcAdvertiser: MCNearbyServiceAdvertiser
    private let mcBrowser: MCNearbyServiceBrowser
    private let identityString: String
    private let maxNumPeers: Int

    init(phoneNumber: String, service: String, identity: String, maxPeers: Int) {
        localPeerID = MCPeerID(displayName: phoneNumber)
        serviceString = service
        identityString = identity
        mcSession = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: .required)
        mcAdvertiser = MCNearbyServiceAdvertiser(peer: localPeerID,
                                                 discoveryInfo: [MPCSessionConstants.kKeyIdentity: identityString],
                                                 serviceType: serviceString)
        mcBrowser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: serviceString)
        maxNumPeers = maxPeers

        super.init()
        mcSession.delegate = self
        mcAdvertiser.delegate = self
        mcBrowser.delegate = self
    }

    // MARK: - `MPCSession` public methods.

    func start() {
        mcAdvertiser.startAdvertisingPeer()
        mcBrowser.startBrowsingForPeers()
    }

    func suspend() {
        mcAdvertiser.stopAdvertisingPeer()
        mcBrowser.stopBrowsingForPeers()
    }

    func invalidate() {
        suspend()
        mcSession.disconnect()
    }

    func sendDataToAllPeers(data: Data) {
        sendData(data: data, peers: mcSession.connectedPeers, mode: .reliable)
    }

    func sendData(data: Data, peers: [MCPeerID], mode: MCSessionSendDataMode) {
        do {
            try mcSession.send(data, toPeers: peers, with: mode)
        } catch {
            NSLog("Error sending data: \(error)")
        }
    }

    // MARK: - `MPCSession` private methods.

    private func peerConnected(peerID: MCPeerID) {
        if let handler = peerConnectedHandler {
            DispatchQueue.main.async {
                handler(peerID)
            }
        }
        if mcSession.connectedPeers.count == maxNumPeers {
            suspend()
        }
    }

    private func peerDisconnected(peerID: MCPeerID) {
        if let handler = peerDisconnectedHandler {
            DispatchQueue.main.async {
                handler(peerID)
            }
        }

        if mcSession.connectedPeers.count < maxNumPeers {
            start()
        }
    }

    // MARK: - `MCSessionDelegate`.

    internal func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            peerConnected(peerID: peerID)
        case .notConnected:
            peerDisconnected(peerID: peerID)
        case .connecting:
            break
        @unknown default:
            fatalError("Unhandled MCSessionState")
        }
    }

    internal func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let handler = peerDataHandler {
            DispatchQueue.main.async {
                handler(data, peerID)
            }
        }
    }

    internal func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // The sample app intentional omits this implementation.
    }

    internal func session(_ session: MCSession,
                          didStartReceivingResourceWithName resourceName: String,
                          fromPeer peerID: MCPeerID,
                          with progress: Progress)
    {
        // The sample app intentional omits this implementation.
    }

    internal func session(_ session: MCSession,
                          didFinishReceivingResourceWithName resourceName: String,
                          fromPeer peerID: MCPeerID,
                          at localURL: URL?,
                          withError error: Error?)
    {
        // The sample app intentional omits this implementation.
    }

    // MARK: - `MCNearbyServiceBrowserDelegate`.

    internal func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        guard let identityValue = info?[MPCSessionConstants.kKeyIdentity] else {
            return
        }
        if identityValue == identityString && mcSession.connectedPeers.count < maxNumPeers {
            browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 10)
        }
    }

    internal func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // The sample app intentional omits this implementation.
    }

    // MARK: - `MCNearbyServiceAdvertiserDelegate`.

    internal func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                             didReceiveInvitationFromPeer peerID: MCPeerID,
                             withContext context: Data?,
                             invitationHandler: @escaping (Bool, MCSession?) -> Void)
    {
        // Accept the invitation only if the number of peers is less than the maximum.
        if mcSession.connectedPeers.count < maxNumPeers {
            invitationHandler(true, mcSession)
        }
    }
}
