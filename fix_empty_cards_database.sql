-- Quick Check: Apakah ada cards di database?
SELECT rarity, COUNT(*) as jumlah
FROM cards
GROUP BY rarity
ORDER BY 
  CASE rarity
    WHEN 'Ultra Rare' THEN 1
    WHEN 'Super Rare' THEN 2
    WHEN 'Rare' THEN 3
    WHEN 'Elite' THEN 4
    WHEN 'Normal' THEN 5
  END;

-- Jika hasil kosong, jalankan insert berikut:
-- CATATAN: ID akan di-generate otomatis oleh database (bigint auto-increment)

-- INSERT 5 Ultra Rare cards (untuk test collection complete)
INSERT INTO cards (name, rarity, image_url, recycle_dust_value) VALUES
  ('Legendary Dragon', 'Ultra Rare', 'dragon.png', 150),
  ('Phoenix Rising', 'Ultra Rare', 'phoenix.png', 150),
  ('Mystic Unicorn', 'Ultra Rare', 'unicorn.png', 150),
  ('Ancient Griffin', 'Ultra Rare', 'griffin.png', 150),
  ('Deep Sea Kraken', 'Ultra Rare', 'kraken.png', 150);

-- INSERT 5 Super Rare cards
INSERT INTO cards (name, rarity, image_url, recycle_dust_value) VALUES
  ('Golden Lion', 'Super Rare', 'lion.png', 60),
  ('Royal Tiger', 'Super Rare', 'tiger.png', 60),
  ('Sky Eagle', 'Super Rare', 'eagle.png', 60),
  ('Alpha Wolf', 'Super Rare', 'wolf.png', 60),
  ('Night Bear', 'Super Rare', 'bear.png', 60);

-- INSERT 10 Rare cards
INSERT INTO cards (name, rarity, image_url, recycle_dust_value) VALUES
  ('Swift Hawk', 'Rare', 'hawk.png', 30),
  ('Cunning Fox', 'Rare', 'fox.png', 30),
  ('Noble Deer', 'Rare', 'deer.png', 30),
  ('Shadow Panther', 'Rare', 'panther.png', 30),
  ('Venom Cobra', 'Rare', 'cobra.png', 30),
  ('Wind Falcon', 'Rare', 'falcon.png', 30),
  ('Spotted Leopard', 'Rare', 'leopard.png', 30),
  ('Speed Cheetah', 'Rare', 'cheetah.png', 30),
  ('Forest Jaguar', 'Rare', 'jaguar.png', 30),
  ('Wild Lynx', 'Rare', 'lynx.png', 30);

-- INSERT 15 Elite cards
INSERT INTO cards (name, rarity, image_url, recycle_dust_value) VALUES
  ('Swift Rabbit', 'Elite', 'rabbit.png', 15),
  ('Tree Squirrel', 'Elite', 'squirrel.png', 15),
  ('Clever Raccoon', 'Elite', 'raccoon.png', 15),
  ('Brave Badger', 'Elite', 'badger.png', 15),
  ('River Otter', 'Elite', 'otter.png', 15),
  ('Builder Beaver', 'Elite', 'beaver.png', 15),
  ('Digging Mole', 'Elite', 'mole.png', 15),
  ('Spiky Hedgehog', 'Elite', 'hedgehog.png', 15),
  ('Stinky Skunk', 'Elite', 'skunk.png', 15),
  ('Sneaky Weasel', 'Elite', 'weasel.png', 15),
  ('Playful Ferret', 'Elite', 'ferret.png', 15),
  ('Cute Chipmunk', 'Elite', 'chipmunk.png', 15),
  ('Spiny Porcupine', 'Elite', 'porcupine.png', 15),
  ('Night Opossum', 'Elite', 'opossum.png', 15),
  ('Alert Meerkat', 'Elite', 'meerkat.png', 15);

-- INSERT 20 Normal cards
INSERT INTO cards (name, rarity, image_url, recycle_dust_value) VALUES
  ('Field Mouse', 'Normal', 'mouse.png', 5),
  ('City Rat', 'Normal', 'rat.png', 5),
  ('Cute Hamster', 'Normal', 'hamster.png', 5),
  ('Desert Gerbil', 'Normal', 'gerbil.png', 5),
  ('Guinea Pig', 'Normal', 'guinea.png', 5),
  ('Night Bat', 'Normal', 'bat.png', 5),
  ('Tiny Shrew', 'Normal', 'shrew.png', 5),
  ('Meadow Vole', 'Normal', 'vole.png', 5),
  ('Arctic Lemming', 'Normal', 'lemming.png', 5),
  ('Sleepy Dormouse', 'Normal', 'dormouse.png', 5),
  ('City Pigeon', 'Normal', 'pigeon.png', 5),
  ('Common Sparrow', 'Normal', 'sparrow.png', 5),
  ('Black Crow', 'Normal', 'crow.png', 5),
  ('Dark Raven', 'Normal', 'raven.png', 5),
  ('Shiny Magpie', 'Normal', 'magpie.png', 5),
  ('Blue Jay', 'Normal', 'jay.png', 5),
  ('Red Robin', 'Normal', 'robin.png', 5),
  ('Yellow Finch', 'Normal', 'finch.png', 5),
  ('Singing Canary', 'Normal', 'canary.png', 5),
  ('Green Budgie', 'Normal', 'budgie.png', 5);

-- VERIFY: Check total cards
SELECT 
  rarity,
  COUNT(*) as total,
  STRING_AGG(name, ', ') as sample_names
FROM cards
GROUP BY rarity
ORDER BY 
  CASE rarity
    WHEN 'Ultra Rare' THEN 1
    WHEN 'Super Rare' THEN 2
    WHEN 'Rare' THEN 3
    WHEN 'Elite' THEN 4
    WHEN 'Normal' THEN 5
  END;

-- Expected hasil:
-- Ultra Rare: 5 cards
-- Super Rare: 5 cards  
-- Rare: 10 cards
-- Elite: 15 cards
-- Normal: 20 cards
-- TOTAL: 55 cards
