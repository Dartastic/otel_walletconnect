// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_walletconnect/otel_walletconnect.dart';

/// Traces WalletConnect calls with OpenTelemetry.
///
/// `otel_walletconnect` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each WalletConnect call in
/// [tracedWalletConnect]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'walletconnect-example');

  // Wraps a WalletConnect call in a CLIENT span.
  final walletConnectId = await tracedWalletConnect<String>(
    operation: 'create',
    invoke: () async {
      // Make the WalletConnect call here, then report what it returned.
      const id = 'walletconnect_8f3a2c';
      return const WalletConnectCallResult(
          value: id,
          result: WalletConnectResult(
              protocol: 'v2',
              projectId: 'project_8f3a2c',
              relayUrl: 'wss://relay.walletconnect.com',
              topic: 'orders',
              pairingTopic: 'orders',
              peerName: 'example',
              peerUrl: 'https://api.example.com/v1/resource',
              walletId: 'MetaMask',
              chainId: 'eip155:1',
              chainNamespace: 'eip155',
              address: 'example',
              requestedNamespaces: ['example'],
              approvedNamespaces: ['example'],
              method: 'eth_sendTransaction',
              requestedMethods: ['example'],
              expiryUnixSec: 1,
              userRejected: true,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedWalletConnect create returned $walletConnectId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutWalletConnectInstrumentationAsync.
  await runWithoutWalletConnectInstrumentationAsync(
    () => tracedWalletConnect<String>(
      operation: 'create',
      invoke: () async {
        const id = 'walletconnect_8f3a2c';
        return const WalletConnectCallResult(
            value: id,
            result: WalletConnectResult(
                protocol: 'v2',
                projectId: 'project_8f3a2c',
                relayUrl: 'wss://relay.walletconnect.com',
                topic: 'orders',
                pairingTopic: 'orders',
                peerName: 'example',
                peerUrl: 'https://api.example.com/v1/resource',
                walletId: 'MetaMask',
                chainId: 'eip155:1',
                chainNamespace: 'eip155',
                address: 'example',
                requestedNamespaces: ['example'],
                approvedNamespaces: ['example'],
                method: 'eth_sendTransaction',
                requestedMethods: ['example'],
                expiryUnixSec: 1,
                userRejected: true,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
