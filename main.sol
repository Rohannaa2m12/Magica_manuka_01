// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
    Manuka spectral ledger — "velvet hive / frost comb telemetry"
    --------------------------------------------------------------
    On-chain registry for regional honey quality envelopes with oracle-attested AI
    digest vectors. This module never custodies ERC-20 balances; it only stores
    attestations, curator freezes, and consumer sentiment aggregates. Deploy with
    three cold-role addresses (curator, oracle, liaison) and keep pauses rare.
*/

/// @title RegionalApiaryManukaHoneyTapestry
/// @notice Honey rating surface with AI global inputs mapped onto regional variants.
/// @dev Authority is constructor-injected; immutables replace mutable role wiring.
contract RegionalApiaryManukaHoneyTapestry {
    // =============================================================
    // Custom errors (unique prefix Wnq_)
    // =============================================================
    error Wnq_FloralGate();
    error Wnq_VectorWindow();
    error Wnq_RegionDormant();
    error Wnq_SentimentBounds();
    error Wnq_PausedComb();
    error Wnq_BatchHash();
    error Wnq_MGOOverflow();
    error Wnq_UMFEnvelope();
    error Wnq_AiDigestEmpty();
    error Wnq_ConsentFlag();
    error Wnq_LiaisonOnly();
    error Wnq_OracleOnly();
    error Wnq_CuratorOnly();
    error Wnq_RegionUnknown();
    error Wnq_SignalCooldown();
    error Wnq_ImmutableAnchor();

    // =============================================================
    // Events (unique naming)
    // =============================================================
    event HighlandsBatchCertified(uint16 indexed regionId, bytes32 indexed batchRoot, uint128 mgoPpm);
    event NectarVectorCommitted(uint16 indexed regionId, bytes32 aiModelDigest, uint64 issuedAt);
    event PollenTraceEmitted(address indexed observer, uint16 regionId, uint8 bucket);
    event FrostLoomFrozen(uint16 indexed regionId, bool frozen);
    event KiwianaSignalPulse(uint16 indexed regionId, uint256 rollingMean);

    // =============================================================
    // Types
    // =============================================================
    enum ApiaryTier {
        WildSlope,
        CoastalMist,
        AlpineGlen,
        UrbanRooftop,
        ResearchApiary
    }

    enum SentimentBucket {
        Sharp,
        Round,
        Smoky,
        FloralBurst,
        Medicinal
    }

    struct RegionalHoneyEnvelope {
        uint128 mgoPpm;
        uint8 umfHint;
        uint32 polyphenolFingerprint;
        bytes32 aiModelDigest;
        uint64 lastVectorEpoch;
        bool frozen;
        ApiaryTier tierHint;
    }

    struct ConsumerPulse {
        uint128 rollingSum;
        uint64 count;
        uint64 lastSignalAt;
    }

    // =============================================================
    // Immutables (constructor-set roles + anchors)
    // =============================================================
    address public immutable FLORAL_CURATOR;
    address public immutable AI_VECTOR_ORACLE;
    address public immutable KIWIANA_LIAISON;
    address public immutable TRUST_ANCHOR_A;
    address public immutable TRUST_ANCHOR_B;

    // =============================================================
    // Nonce / pause / constants
    // =============================================================
    bool public paused;
