module challenge::marketplace;

use challenge::hero::Hero;
use sui::coin::{Self, Coin};
use sui::event;
use sui::sui::SUI;

// ========= ERRORS =========

const EInvalidPayment: u64 = 1;

// ========= STRUCTS =========

public struct ListHero has key, store {
    id: UID,
    nft: Hero,
    price: u64,
    seller: address,
}

// ========= CAPABILITIES =========

public struct AdminCap has key, store {
    id: UID,
}

// ========= EVENTS =========

public struct HeroListed has copy, drop {
    list_hero_id: ID,
    price: u64,
    seller: address,
    timestamp: u64,
}

public struct HeroBought has copy, drop {
    list_hero_id: ID,
    price: u64,
    buyer: address,
    seller: address,
    timestamp: u64,
}

// ========= FUNCTIONS =========

fun init(ctx: &mut TxContext) {
    // AdminCap oluştur
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };

    // AdminCap'i modül yayıncısına transfer et
    transfer::public_transfer(admin_cap, tx_context::sender(ctx));
}

public fun list_hero(nft: Hero, price: u64, ctx: &mut TxContext) {
    // 1. ID oluştur
    let id = object::new(ctx);

    // 2. ListHero objesi oluştur
    let list_hero = ListHero {
        id,
        nft,
        price,
        seller: tx_context::sender(ctx),
    };

    // 3. Event emit et
    event::emit(
        HeroListed {
            list_hero_id: object::id(&list_hero),
            price,
            seller: tx_context::sender(ctx),
            timestamp: ctx.epoch_timestamp_ms(),
        }
    );

    // 4. Objeyi trade edilebilir yap
    transfer::share_object(list_hero);
}

#[allow(lint(self_transfer))]
public fun buy_hero(list_hero: ListHero, coin: Coin<SUI>, ctx: &mut TxContext) {
    // 1. Destructure işlemi
    let ListHero { id, nft, price, seller } = list_hero;

    // 2. Ödeme kontrolü
    assert!(coin::value(&coin) == price, EInvalidPayment);

    // 3. Coin'i satıcıya gönder
    transfer::public_transfer(coin, seller);

    // 4. NFT'yi alıcıya gönder
    transfer::public_transfer(nft, tx_context::sender(ctx));

    // 5. Event emit et
    event::emit(
        HeroBought {
            list_hero_id: object::uid_to_inner(&id),
            price,
            buyer: tx_context::sender(ctx),
            seller,
            timestamp: ctx.epoch_timestamp_ms(),
        }
    );

    // 6. Listing ID'yi sil
    object::delete(id);
}

// ========= GETTER FUNCTIONS =========

#[test_only]
public fun listing_price(list_hero: &ListHero): u64 {
    list_hero.price
}

// ========= TEST ONLY FUNCTIONS =========

#[test_only]
public fun test_init(ctx: &mut TxContext) {
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    transfer::transfer(admin_cap, ctx.sender());
}

