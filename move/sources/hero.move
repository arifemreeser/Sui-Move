module challenge::hero;

use std::string::String;

// ========= STRUCTS =========
public struct Hero has key, store {
    id: UID,
    name: String,
    image_url: String,
    power: u64,
}

public struct HeroMetadata has key, store {
    id: UID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

#[allow(lint(self_transfer))]
public entry fun create_hero(name: String, image_url: String, power: u64, ctx: &mut TxContext) {
    let id = object::new(ctx);
    let hero = Hero {
        id,
        name,
        image_url,
        power,
    };
    let sender = tx_context::sender(ctx);
    transfer::transfer(hero, sender);

    let metadata_id = object::new(ctx);
    let metadata = HeroMetadata {
        id: metadata_id,
        timestamp: ctx.epoch_timestamp_ms(),
    };
    transfer::freeze_object(metadata);
}

// ========= GETTER FUNCTIONS =========

public fun hero_power(hero: &Hero): u64 {
    hero.power
}

#[test_only]
public fun hero_name(hero: &Hero): String {
    hero.name
}

#[test_only]
public fun hero_image_url(hero: &Hero): String {
    hero.image_url
}

#[test_only]
public fun hero_id(hero: &Hero): ID {
    object::id(hero)
}
