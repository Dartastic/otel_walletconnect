// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_walletconnect_suppression.dart';

const _tracerName = 'dartastic_otel_libs_walletconnect';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class WalletConnectResult {
  /// Creates a result.
  const WalletConnectResult({
    this.protocol,
    this.projectId,
    this.relayUrl,
    this.topic,
    this.pairingTopic,
    this.peerName,
    this.peerUrl,
    this.walletId,
    this.chainId,
    this.chainNamespace,
    this.address,
    this.requestedNamespaces,
    this.approvedNamespaces,
    this.method,
    this.requestedMethods,
    this.expiryUnixSec,
    this.userRejected,
    this.errorCode,
    this.errorMessage,
  });

  /// `v2` (current) — Sign / Auth / Notify / Push.
  final String? protocol;

  /// Cloud project id.
  final String? projectId;

  /// Relay server URL (`wss://relay.walletconnect.com`).
  final String? relayUrl;

  /// Session topic (post-approval).
  final String? topic;

  /// Pairing topic (pre-approval handshake).
  final String? pairingTopic;

  /// Peer wallet metadata.name.
  final String? peerName;
  final String? peerUrl;

  /// `MetaMask`, `Trust`, `Rainbow`, `Zerion`, `Phantom`,
  /// `Coinbase Wallet`, etc.
  final String? walletId;

  /// CAIP-2 chain id (e.g. `eip155:1`, `eip155:137`, `solana:101`).
  final String? chainId;

  /// `eip155` (EVM), `solana`, `cosmos`, `polkadot`, `near`, `bip122`.
  final String? chainNamespace;

  /// CAIP-10 account or wallet address.
  final String? address;

  /// Required + optional namespaces requested on session proposal.
  final List<String>? requestedNamespaces;

  /// Approved namespaces returned by the wallet.
  final List<String>? approvedNamespaces;

  /// RPC method invoked (`eth_sendTransaction`, `personal_sign`,
  /// `eth_signTypedData_v4`, `wallet_switchEthereumChain`,
  /// `wallet_addEthereumChain`, `solana_signTransaction`,
  /// `cosmos_signAmino`, etc.).
  final String? method;

  /// Methods listed on a session proposal.
  final List<String>? requestedMethods;

  /// Session expiry unix seconds.
  final int? expiryUnixSec;

  /// User rejected the request in their wallet.
  final bool? userRejected;

  /// WC SDK error code / message.
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class WalletConnectCallResult<T> {
  /// Creates a call result.
  const WalletConnectCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final WalletConnectResult? result;
}

/// Wraps a WalletConnect call in a CLIENT span. [operation] is one of
/// `init`, `pair`, `connect`, `approveSession`, `rejectSession`,
/// `updateSession`, `extendSession`, `disconnectSession`,
/// `request`, `respond`, `ping`, `emit`, `getSessions`, `getPairings`,
/// `cleanupPairings`, `decryptMessage`, `authClient.request`,
/// `notifyClient.subscribe`, `notifyClient.unsubscribe`,
/// `notifyClient.getNotifications`.
Future<T> tracedWalletConnect<T>({
  required String operation,
  required Future<WalletConnectCallResult<T>> Function() invoke,
}) async {
  if (walletConnectInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'walletconnect',
    'rpc.method': operation,
    'walletconnect.operation': operation,
  };

  final span = _tracer().startSpan(
    'walletconnect $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.protocol != null) {
        extras.add(OTelAPI.attributeString(
          'walletconnect.protocol',
          res.protocol!,
        ));
      }
      if (res.projectId != null) {
        extras.add(OTelAPI.attributeString(
          'walletconnect.project.id',
          res.projectId!,
        ));
      }
      if (res.relayUrl != null) {
        extras.add(OTelAPI.attributeString(
          'walletconnect.relay.url',
          res.relayUrl!,
        ));
      }
      if (res.topic != null) {
        extras.add(OTelAPI.attributeString(
          'walletconnect.session.topic',
          res.topic!,
        ));
      }
      if (res.pairingTopic != null) {
        extras.add(OTelAPI.attributeString(
          'walletconnect.pairing.topic',
          res.pairingTopic!,
        ));
      }
      if (res.peerName != null) {
        extras.add(OTelAPI.attributeString(
          'walletconnect.peer.name',
          res.peerName!,
        ));
      }
      if (res.peerUrl != null) {
        extras.add(OTelAPI.attributeString(
          'walletconnect.peer.url',
          res.peerUrl!,
        ));
      }
      if (res.walletId != null) {
        extras.add(OTelAPI.attributeString(
          'walletconnect.wallet.id',
          res.walletId!,
        ));
      }
      if (res.chainId != null) {
        extras.add(OTelAPI.attributeString(
          'walletconnect.chain.id',
          res.chainId!,
        ));
      }
      if (res.chainNamespace != null) {
        extras.add(OTelAPI.attributeString(
          'walletconnect.chain.namespace',
          res.chainNamespace!,
        ));
      }
      if (res.address != null) {
        extras.add(OTelAPI.attributeString(
          'walletconnect.account.address',
          res.address!,
        ));
      }
      if (res.requestedNamespaces != null) {
        extras.add(OTelAPI.attributeStringList(
          'walletconnect.namespaces.requested',
          res.requestedNamespaces!,
        ));
      }
      if (res.approvedNamespaces != null) {
        extras.add(OTelAPI.attributeStringList(
          'walletconnect.namespaces.approved',
          res.approvedNamespaces!,
        ));
      }
      if (res.method != null) {
        extras.add(OTelAPI.attributeString(
          'walletconnect.rpc.method',
          res.method!,
        ));
      }
      if (res.requestedMethods != null) {
        extras.add(OTelAPI.attributeStringList(
          'walletconnect.rpc.methods_requested',
          res.requestedMethods!,
        ));
      }
      if (res.expiryUnixSec != null) {
        extras.add(OTelAPI.attributeInt(
          'walletconnect.session.expiry_unix_sec',
          res.expiryUnixSec!,
        ));
      }
      if (res.userRejected != null) {
        extras.add(OTelAPI.attributeBool(
          'walletconnect.user_rejected',
          res.userRejected!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTelAPI.attributeString(
          'walletconnect.error.code',
          res.errorCode!,
        ));
        span.setStatus(
          SpanStatusCode.Error,
          'WalletConnect ${res.errorCode}',
        );
      }
      if (res.errorMessage != null) {
        extras.add(OTelAPI.attributeString(
          'walletconnect.error.message',
          res.errorMessage!,
        ));
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
