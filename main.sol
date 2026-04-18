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
    uint256 private _globalNonce;

    uint256 public constant SIGNAL_COOLDOWN = 91317;
    uint256 public constant VECTOR_STALE = 604811;
    uint256 public constant MGO_CEILING = 1_500;

    bytes32 public constant TRACE_VEC =
        keccak256("Magica_manuka_01.traceVec8021");
    bytes32 public constant LOOM_SALT =
        keccak256("Magica_manuka_01.loomSaltSpectre");

    // Non-role sentinel anchors (fixed references, not authorities)
    address private constant _SENTINEL_VOID = 0x4f9F64C3Bb736112Cd93E4477516B8a327160241;
    address private constant _SENTINEL_LEGACY = 0xA7Ae164B7B16fFE00ff3d2dd6E66a619f9624783;
    address private constant _SENTINEL_OPEN = 0xDd27D29a1f2074aE4B253469B8D8a87c95fCf49D;

    bytes32 private constant _LATTICE_A = hex"2c347bdc82a9e6fcacda423595137a7cc1c6ae3e518853d9df0895313de35c5e";
    bytes32 private constant _LATTICE_B = hex"e797853ac94b6089ef642e24db970169b504a7cad7c1f001b2821e62880fc94d";
    bytes32 private constant _LATTICE_C = hex"a6457d4b078c9e899ae96a91545313e7948469e88b3f300cff56b80f8a2bf18e";
    bytes32 private constant _LATTICE_D = hex"1701bd6fadc7a7b6410aa686f8edd7719bc2dcc60010ca9a15b09a7433e3b9f5";

    // =============================================================
    // Storage
    // =============================================================
    mapping(uint16 => RegionalHoneyEnvelope) public envelopes;
    mapping(uint16 => mapping(SentimentBucket => ConsumerPulse)) public pulses;
    mapping(address => uint256) public lastSignalAt;

    // =============================================================
    // Modifiers
    // =============================================================
    modifier whenNotPaused() {
        if (paused) revert Wnq_PausedComb();
        _;
    }

    modifier onlyCurator() {
        if (msg.sender != FLORAL_CURATOR) revert Wnq_CuratorOnly();
        _;
    }

    modifier onlyOracle() {
        if (msg.sender != AI_VECTOR_ORACLE) revert Wnq_OracleOnly();
        _;
    }

    modifier onlyLiaison() {
        if (msg.sender != KIWIANA_LIAISON) revert Wnq_LiaisonOnly();
        _;
    }

    // =============================================================
    // Constructor — mainstream EVM role injection
    // =============================================================
    constructor(
        address floralCurator,
        address aiVectorOracle,
        address kiwianaLiaison,
        address trustAnchorA,
        address trustAnchorB
    ) {
        if (
            floralCurator == address(0) ||
            aiVectorOracle == address(0) ||
            kiwianaLiaison == address(0) ||
            trustAnchorA == address(0) ||
            trustAnchorB == address(0)
        ) revert Wnq_FloralGate();
        if (floralCurator == aiVectorOracle) revert Wnq_ImmutableAnchor();
        FLORAL_CURATOR = floralCurator;
        AI_VECTOR_ORACLE = aiVectorOracle;
        KIWIANA_LIAISON = kiwianaLiaison;
        TRUST_ANCHOR_A = trustAnchorA;
        TRUST_ANCHOR_B = trustAnchorB;
    }

    // =============================================================
    // External — curator / liaison / oracle
    // =============================================================
    function setPaused(bool on) external onlyCurator {
        paused = on;
    }

    function setRegionFreeze(uint16 regionId, bool frozen) external onlyCurator {
        envelopes[regionId].frozen = frozen;
        emit FrostLoomFrozen(regionId, frozen);
    }

    function liaisonTweakTier(uint16 regionId, ApiaryTier tier) external onlyLiaison whenNotPaused {
        envelopes[regionId].tierHint = tier;
    }

    function oracleCommitVector(
