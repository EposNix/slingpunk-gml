// ModifierSystem.gml - Roguelite power-up system

// Helper functions for modifier stacking
function ensure_slow_effect(_state, _duration, _factor) {
    var existing = _state.slowEffect;
    if (is_undefined(existing)) {
        _state.slowEffect = {
            duration: _duration,
            factor: _factor
        };
        return;
    }
    _state.slowEffect = {
        duration: max(existing.duration, _duration),
        factor: min(existing.factor, _factor)
    };
}

function ensure_explosion_effect(_state, _radius, _damage) {
    var existing = _state.explosion;
    if (is_undefined(existing)) {
        _state.explosion = {
            radius: _radius,
            damage: _damage
        };
        return;
    }
    _state.explosion = {
        radius: max(existing.radius, _radius),
        damage: max(existing.damage, _damage)
    };
}

function ensure_chain_lightning(_state, _range, _damage, _interval) {
    var existing = _state.chainLightning;
    if (is_undefined(existing)) {
        _state.chainLightning = {
            range: _range,
            damage: _damage,
            interval: _interval,
            cooldown: 0
        };
        return;
    }
    _state.chainLightning = {
        range: max(existing.range, _range),
        damage: existing.damage + _damage,
        interval: min(existing.interval, _interval),
        cooldown: existing.cooldown
    };
}

// Major modifier definitions
function get_major_modifiers() {
    var modifiers = [];

    // Bulwark Core
    array_push(modifiers, {
        id: RunModifierId.BULWARK_CORE,
        name: "Bulwark Core",
        description: "Orbs are larger and freeze enemies on impact for 2.5 seconds",
        rarity: ModifierRarity.COMMON,
        apply: function(_state) {
            _state.orbSizeMultiplier *= 1.4;
            ensure_slow_effect(_state, 2.5, 0.08);
        }
    });

    // Cryo Coating
    array_push(modifiers, {
        id: RunModifierId.CRYO_COATING,
        name: "Cryo Coating",
        description: "Orbs slow enemies on impact and deal +15% damage per combo tier",
        rarity: ModifierRarity.COMMON,
        apply: function(_state) {
            ensure_slow_effect(_state, 1.8, 0.35);
            _state.comboDamagePerTier += 15;
        }
    });

    // Combo Drive
    array_push(modifiers, {
        id: RunModifierId.COMBO_DRIVE,
        name: "Combo Drive",
        description: "Orbs deal +8% damage per combo heat point",
        rarity: ModifierRarity.COMMON,
        apply: function(_state) {
            _state.comboHeatDamagePercent += 0.08;
        }
    });

    // Repulsor Burst
    array_push(modifiers, {
        id: RunModifierId.REPULSOR_BURST,
        name: "Repulsor Burst",
        description: "Orbs knock back enemies and deal +35% damage to bosses",
        rarity: ModifierRarity.UNCOMMON,
        apply: function(_state) {
            _state.knockbackForce += 180;
            _state.bossDamageMultiplier *= 1.35;
        }
    });

    // Seeker Fletching
    array_push(modifiers, {
        id: RunModifierId.SEEKER_FLETCHING,
        name: "Seeker Fletching",
        description: "Orbs home in on enemies and deal +12% damage per bounce",
        rarity: ModifierRarity.UNCOMMON,
        apply: function(_state) {
            _state.homingStrength += 480;
            _state.bounceDamagePercent += 0.12;
        }
    });

    // Volatile Core
    array_push(modifiers, {
        id: RunModifierId.VOLATILE_CORE,
        name: "Volatile Core",
        description: "Orbs explode on impact, dealing area damage",
        rarity: ModifierRarity.UNCOMMON,
        apply: function(_state) {
            ensure_explosion_effect(_state, 120, 85);
        }
    });

    // Fractal Splinters
    array_push(modifiers, {
        id: RunModifierId.FRACTAL_SPLINTERS,
        name: "Fractal Splinters",
        description: "Orbs split into two on first enemy hit",
        rarity: ModifierRarity.RARE,
        apply: function(_state) {
            _state.splitOnImpact = true;
        }
    });

    // Storm Lattice
    array_push(modifiers, {
        id: RunModifierId.STORM_LATTICE,
        name: "Storm Lattice",
        description: "Multiple orbs create chain lightning between them",
        rarity: ModifierRarity.RARE,
        apply: function(_state) {
            ensure_chain_lightning(_state, 90, 45, 0.8);
        }
    });

    // Tri-Volley
    array_push(modifiers, {
        id: RunModifierId.TRI_VOLLEY,
        name: "Tri-Volley",
        description: "Launch three orbs in a spread pattern",
        rarity: ModifierRarity.RARE,
        apply: function(_state) {
            _state.tripleLaunch = true;
        }
    });

    return modifiers;
}

// Upgrade modifier definitions
function get_upgrade_modifiers() {
    var modifiers = [];

    // Basic damage boost
    array_push(modifiers, {
        id: RunModifierId.DAMAGE_BOOST,
        name: "Damage Boost",
        description: "+15% orb damage",
        rarity: ModifierRarity.COMMON,
        apply: function(_state) {
            _state.damageMultiplier *= 1.15;
        }
    });

    // Combo heat damage boost
    array_push(modifiers, {
        id: RunModifierId.COMBO_HEAT_DAMAGE_BOOST,
        name: "Combo Amplifier",
        description: "+3% damage per combo heat point",
        rarity: ModifierRarity.COMMON,
        apply: function(_state) {
            _state.comboHeatDamagePercent += 0.03;
        }
    });

    // Bounce damage boost
    array_push(modifiers, {
        id: RunModifierId.BOUNCE_DAMAGE_BOOST,
        name: "Ricochet Power",
        description: "+8% damage per wall bounce",
        rarity: ModifierRarity.COMMON,
        apply: function(_state) {
            _state.bounceDamagePercent += 0.08;
        }
    });

    // Boss damage boost
    array_push(modifiers, {
        id: RunModifierId.BOSS_DAMAGE_BOOST,
        name: "Giant Slayer",
        description: "+25% damage to bosses and elites",
        rarity: ModifierRarity.UNCOMMON,
        apply: function(_state) {
            _state.bossDamageMultiplier *= 1.25;
        }
    });

    // Wall hit damage boost
    array_push(modifiers, {
        id: RunModifierId.WALL_HIT_DAMAGE_BOOST,
        name: "Wall Piercer",
        description: "+20% damage bonus after hitting walls",
        rarity: ModifierRarity.UNCOMMON,
        apply: function(_state) {
            _state.wallHitDamageBonusPercent += 0.20;
        }
    });

    // Heart restore (special case)
    array_push(modifiers, {
        id: RunModifierId.RESTORE_HEART,
        name: "Heart Capsule",
        description: "Restore one heart",
        rarity: ModifierRarity.COMMON,
        available: function(_state, _context) {
            return _context.lives < _context.maxLives;
        },
        apply: function(_state) {
            // Special handling in game logic
        }
    });

    // Seeker homing boost
    array_push(modifiers, {
        id: RunModifierId.SEEKER_HOMING_BOOST,
        name: "Enhanced Targeting",
        description: "Stronger homing for orbs",
        rarity: ModifierRarity.UNCOMMON,
        apply: function(_state) {
            _state.homingStrength += 240;
        }
    });

    return modifiers;
}

// Apply a modifier to the state
function apply_modifier(_state, _modifier_id) {
    var major_modifiers = get_major_modifiers();
    var upgrade_modifiers = get_upgrade_modifiers();

    var all_modifiers = [];
    array_copy(all_modifiers, 0, major_modifiers, 0, array_length(major_modifiers));
    array_copy(all_modifiers, array_length(major_modifiers), upgrade_modifiers, 0, array_length(upgrade_modifiers));

    for (var i = 0; i < array_length(all_modifiers); i++) {
        var modifier = all_modifiers[i];
        if (modifier.id == _modifier_id) {
            modifier.apply(_state);
            _state.lastPicked = _modifier_id;
            return;
        }
    }

    show_debug_message("Warning: Modifier not found: " + string(_modifier_id));
}

// Get available upgrade options
function get_upgrade_options(_state, _context, _count = 3) {
    var upgrade_modifiers = get_upgrade_modifiers();
    var available = [];

    for (var i = 0; i < array_length(upgrade_modifiers); i++) {
        var modifier = upgrade_modifiers[i];
        var is_available = true;

        if (struct_exists(modifier, "available")) {
            is_available = modifier.available(_state, _context);
        }

        if (is_available) {
            array_push(available, modifier);
        }
    }

    // Shuffle and return up to _count options
    array_shuffle_ext(available);
    var result = [];
    var max_count = min(_count, array_length(available));

    for (var i = 0; i < max_count; i++) {
        array_push(result, available[i]);
    }

    return result;
}

// Get available major modifier options
function get_major_options(_available_major_modifiers, _count = 3) {
    if (array_length(_available_major_modifiers) <= _count) {
        return _available_major_modifiers;
    }

    array_shuffle_ext(_available_major_modifiers);
    var result = [];

    for (var i = 0; i < _count; i++) {
        array_push(result, _available_major_modifiers[i]);
    }

    return result;
}

function select_modifier_from_buckets(_buckets, _weights) {
    var available = [];
    var total_weight = 0;

    for (var rarity = 0; rarity < array_length(_buckets); rarity++) {
        var bucket = _buckets[rarity];
        if (array_length(bucket) <= 0) {
            continue;
        }

        var weight = _weights[rarity];
        if (weight <= 0) {
            weight = 1;
        }

        array_push(available, { rarity: rarity, weight: weight });
        total_weight += weight;
    }

    if (total_weight <= 0) {
        for (var fallback = 0; fallback < array_length(_buckets); fallback++) {
            var fallback_bucket = _buckets[fallback];
            if (array_length(fallback_bucket) > 0) {
                var index = irandom(array_length(fallback_bucket) - 1);
                var modifier = fallback_bucket[index];
                fallback_bucket = array_delete(fallback_bucket, index, 1);
                _buckets[fallback] = fallback_bucket;
                return modifier;
            }
        }
        return undefined;
    }

    var roll = random(total_weight);
    var accumulator = 0;

    for (var i = 0; i < array_length(available); i++) {
        var entry = available[i];
        accumulator += entry.weight;
        if (roll < accumulator) {
            var rarity_index = entry.rarity;
            var selected_bucket = _buckets[rarity_index];
            var choice_index = irandom(array_length(selected_bucket) - 1);
            var chosen = selected_bucket[choice_index];
            selected_bucket = array_delete(selected_bucket, choice_index, 1);
            _buckets[rarity_index] = selected_bucket;
            return chosen;
        }
    }

    return undefined;
}

function generate_modifier_draft(_state, _context, _available_major_modifiers, _picked_modifiers, _count = 3) {
    if (is_undefined(_picked_modifiers)) {
        _picked_modifiers = [];
    }

    if (is_undefined(_context)) {
        _context = {};
    }

    var rarity_buckets = [];
    var rarity_count = 3;
    for (var r = 0; r < rarity_count; r++) {
        array_push(rarity_buckets, []);
    }

    var upgrade_modifiers = get_upgrade_modifiers();

    for (var i = 0; i < array_length(upgrade_modifiers); i++) {
        var modifier = upgrade_modifiers[i];

        if (struct_exists(modifier, "available") && !modifier.available(_state, _context)) {
            continue;
        }

        if (modifier.rarity != ModifierRarity.COMMON && array_contains(_picked_modifiers, modifier.id)) {
            continue;
        }

        var rarity_index = modifier.rarity;
        array_push(rarity_buckets[rarity_index], modifier);
    }

    if (!is_undefined(_available_major_modifiers)) {
        for (var j = 0; j < array_length(_available_major_modifiers); j++) {
            var major_modifier = _available_major_modifiers[j];

            if (struct_exists(major_modifier, "available") && !major_modifier.available(_state, _context)) {
                continue;
            }

            if (array_contains(_picked_modifiers, major_modifier.id)) {
                continue;
            }

            var major_rarity = major_modifier.rarity;
            array_push(rarity_buckets[major_rarity], major_modifier);
        }
    }

    var rarity_weights = [];
    rarity_weights[ModifierRarity.COMMON] = 60;
    rarity_weights[ModifierRarity.UNCOMMON] = 30;
    rarity_weights[ModifierRarity.RARE] = 10;

    var draft = [];

    for (var pick = 0; pick < _count; pick++) {
        var selection = select_modifier_from_buckets(rarity_buckets, rarity_weights);
        if (is_undefined(selection)) {
            break;
        }

        array_push(draft, selection);
    }

    return draft;
}