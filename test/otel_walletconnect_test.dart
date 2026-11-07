// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_walletconnect/otel_walletconnect.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_walletconnect-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('approveSession records chain + wallet + namespaces', () async {
    await tracedWalletConnect<String>(
      operation: 'approveSession',
      invoke: () async => const WalletConnectCallResult(
        value: 'ok',
        result: WalletConnectResult(
          protocol: 'v2',
          projectId: 'proj_1',
          topic: 'topic_xyz',
          peerName: 'MetaMask',
          walletId: 'MetaMask',
          chainId: 'eip155:1',
          chainNamespace: 'eip155',
          address: '0xabc',
          approvedNamespaces: ['eip155:1', 'eip155:137'],
          expiryUnixSec: 1731700000,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('walletconnect approveSession')!);
    expect(a['walletconnect.chain.id'], 'eip155:1');
    expect(a['walletconnect.chain.namespace'], 'eip155');
    expect(a['walletconnect.wallet.id'], 'MetaMask');
  });

  test('request records method + user rejection without span error', () async {
    await tracedWalletConnect<String>(
      operation: 'request',
      invoke: () async => const WalletConnectCallResult(
        value: 'ok',
        result: WalletConnectResult(
          method: 'personal_sign',
          userRejected: true,
        ),
      ),
    );
    final s = spans.findSpanByName('walletconnect request')!;
    expect(s.status, isNot(SpanStatusCode.Error));
    expect(attrsOf(s)['walletconnect.user_rejected'], true);
  });

  test('error code sets span error', () async {
    await tracedWalletConnect<String>(
      operation: 'request',
      invoke: () async => const WalletConnectCallResult(
        value: 'ok',
        result: WalletConnectResult(
          method: 'eth_sendTransaction',
          errorCode: 'SESSION_EXPIRED',
          errorMessage: 'Session has expired',
        ),
      ),
    );
    expect(
      spans.findSpanByName('walletconnect request')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutWalletConnectInstrumentationAsync(() async {
      await tracedWalletConnect<String>(
        operation: 'ping',
        invoke: () async => const WalletConnectCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('walletconnect '), isEmpty);
  });
}
