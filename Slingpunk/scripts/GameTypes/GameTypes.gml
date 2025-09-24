// GameTypes.gml - Core type definitions and enums for Slingpunk

// Enums instead of TypeScript union types
enum ModifierRarity {
    COMMON,
    UNCOMMON,
    RARE
}

enum EnemyKind {
    GLOOB_ZIGZAG,
    SPLITTER_GLOOB,
    SHIELDY_GLOOB,
    SPLITTERLING,
    MAGNETRON,
    SPORE_PUFF,
    BULWARK_GLOOB,
    WARP_STALKER,
    AEGIS_SENTINEL
}

enum RunModifierId {
    BULWARK_CORE,
    CRYO_COATING,
    COMBO_DRIVE,
    REPULSOR_BURST,
    SEEKER_FLETCHING,
    VOLATILE_CORE,
    FRACTAL_SPLINTERS,
    STORM_LATTICE,
    TRI_VOLLEY,
    DAMAGE_BOOST,
    COMBO_HEAT_DAMAGE_BOOST,
    BOUNCE_DAMAGE_BOOST,
    BOSS_DAMAGE_BOOST,
    WALL_HIT_DAMAGE_BOOST,
    RESTORE_HEART,
    SEEKER_HOMING_BOOST
}

enum ParticleKind {
    SPARK,
    EMBER,
    SHARD
}

// Global constants
#macro MAX_LIVES 3
#macro BASE_ENEMY_SPEED 55
#macro BOTTOM_SAFE_ZONE 180
#macro NOVA_CHARGE_MAX 100
#macro NOVA_CHARGE_PER_KILL 7

// Vector2 utility functions - in GML we use simple x,y variables or arrays
function Vector2(_x, _y) {
    return {
        x: _x,
        y: _y
    };
}

// Difficulty definition structure
function DifficultyDefinition(_id, _name, _tagline, _description, _playerDamageMultiplier, _enemyHpMultiplier, _isDefault = false) {
    return {
        id: _id,
        name: _name,
        tagline: _tagline,
        description: _description,
        playerDamageMultiplier: _playerDamageMultiplier,
        enemyHpMultiplier: _enemyHpMultiplier,
        isDefault: _isDefault
    };
}

// Modifier state structure
function ModifierState() {
    return {
        orbSizeMultiplier: 1,
        slowEffect: undefined, // {duration, factor}
        comboDamagePerTier: 0,
        knockbackForce: 0,
        homingStrength: 0,
        explosion: undefined, // {radius, damage}
        splitOnImpact: false,
        chainLightning: undefined, // {range, damage, interval, cooldown}
        tripleLaunch: false,
        damageMultiplier: 1,
        comboHeatDamagePercent: 0,
        bounceDamagePercent: 0,
        bossDamageMultiplier: 1,
        wallHitDamageBonusPercent: 0,
        lastPicked: undefined
    };
}

// HUD data structure
function HudData(_score, _comboHeat, _comboTier, _comboProgress, _focus, _lives, _wave, _lastModifier, _specialCharge, _specialMax, _specialReady, _specialName) {
    return {
        score: _score,
        comboHeat: _comboHeat,
        comboTier: _comboTier,
        comboProgress: _comboProgress,
        focus: _focus,
        lives: _lives,
        wave: _wave,
        lastModifier: _lastModifier,
        specialCharge: _specialCharge,
        specialMax: _specialMax,
        specialReady: _specialReady,
        specialName: _specialName
    };
}

// Enemy wave scaling structure
function EnemyWaveScaling(_level, _hpMultiplier, _hpBonus, _speedMultiplier, _countMultiplier, _cadenceMultiplier) {
    return {
        level: _level,
        hpMultiplier: _hpMultiplier,
        hpBonus: _hpBonus,
        speedMultiplier: _speedMultiplier,
        countMultiplier: _countMultiplier,
        cadenceMultiplier: _cadenceMultiplier
    };
}

// Wave enemy config structure
function WaveEnemyConfig(_type, _hp, _lane, _count, _cadence, _speedScale = 1, _eliteChance = 0, _spawnOffset = 0) {
    return {
        type: _type,
        hp: _hp,
        lane: _lane,
        count: _count,
        cadence: _cadence,
        speedScale: _speedScale,
        eliteChance: _eliteChance,
        spawnOffset: _spawnOffset
    };
}

// Wave blueprint structure
function WaveBlueprint(_waveId, _spawnSeconds, _enemies, _bumpers = []) {
    return {
        waveId: _waveId,
        spawnSeconds: _spawnSeconds,
        enemies: _enemies,
        bumpers: _bumpers
    };
}