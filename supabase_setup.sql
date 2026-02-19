-- ====================================
-- ANIMYST GACHA GAME - DATABASE SCHEMA
-- ====================================
-- Script SQL ini dapat dijalankan di Supabase SQL Editor
-- untuk membuat semua tabel yang dibutuhkan

-- Enable UUID extension (jika belum aktif)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ====================================
-- TABLE: profiles
-- ====================================
-- Menyimpan profil user dengan gems, dust, dan pity counter
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT NOT NULL UNIQUE,
  gems INTEGER DEFAULT 0 CHECK (gems >= 0),
  dust INTEGER DEFAULT 0 CHECK (dust >= 0),
  pity_counter INTEGER DEFAULT 0 CHECK (pity_counter >= 0),
  last_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index untuk performa query
CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_last_login ON profiles(last_login);

-- ====================================
-- TABLE: cards
-- ====================================
-- Menyimpan data kartu yang bisa didapat dari gacha
CREATE TABLE IF NOT EXISTS cards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  image_url TEXT NOT NULL,
  rarity TEXT NOT NULL CHECK (rarity IN ('normal', 'elite', 'rare', 'superRare', 'ultraRare')),
  recycle_dust_value INTEGER DEFAULT 0 CHECK (recycle_dust_value >= 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index untuk performa query
CREATE INDEX IF NOT EXISTS idx_cards_rarity ON cards(rarity);
CREATE INDEX IF NOT EXISTS idx_cards_name ON cards(name);

-- ====================================
-- TABLE: user_cards
-- ====================================
-- Menyimpan inventory kartu yang dimiliki oleh user
CREATE TABLE IF NOT EXISTS user_cards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  card_id UUID NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
  quantity INTEGER DEFAULT 1 CHECK (quantity > 0),
  obtained_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, card_id)
);

-- Index untuk performa query
CREATE INDEX IF NOT EXISTS idx_user_cards_user_id ON user_cards(user_id);
CREATE INDEX IF NOT EXISTS idx_user_cards_card_id ON user_cards(card_id);

-- ====================================
-- ROW LEVEL SECURITY (RLS)
-- ====================================

-- Enable RLS untuk semua tabel
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_cards ENABLE ROW LEVEL SECURITY;

-- Policy untuk profiles: User hanya bisa melihat dan update profil sendiri
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Policy untuk cards: Semua user bisa melihat kartu (public read)
CREATE POLICY "Anyone can view cards"
  ON cards FOR SELECT
  TO authenticated
  USING (true);

-- Policy untuk user_cards: User hanya bisa melihat dan update inventory sendiri
CREATE POLICY "Users can view own cards"
  ON user_cards FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cards"
  ON user_cards FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cards"
  ON user_cards FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cards"
  ON user_cards FOR DELETE
  USING (auth.uid() = user_id);

-- ====================================
-- FUNCTIONS & TRIGGERS
-- ====================================

-- Function untuk auto-update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger untuk auto-update timestamp di profiles
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function untuk auto-create profile saat user baru register
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, gems, dust, pity_counter)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'Player_' || SUBSTR(NEW.id::TEXT, 1, 8)),
    100,  -- Starting gems
    0,    -- Starting dust
    0     -- Starting pity counter
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger untuk auto-create profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ====================================
-- SAMPLE DATA (Opsional)
-- ====================================
-- Uncomment section ini jika ingin insert sample data

/*
-- Insert sample cards
INSERT INTO cards (name, image_url, rarity, recycle_dust_value) VALUES
  ('Common Sword', 'https://placeholder.com/sword1.png', 'normal', 5),
  ('Steel Shield', 'https://placeholder.com/shield1.png', 'normal', 5),
  ('Magic Bow', 'https://placeholder.com/bow1.png', 'elite', 15),
  ('Dragon Blade', 'https://placeholder.com/blade1.png', 'rare', 30),
  ('Phoenix Staff', 'https://placeholder.com/staff1.png', 'rare', 30),
  ('Legendary Armor', 'https://placeholder.com/armor1.png', 'superRare', 60),
  ('Mystic Crown', 'https://placeholder.com/crown1.png', 'superRare', 60),
  ('Godly Sword', 'https://placeholder.com/sword2.png', 'ultraRare', 150),
  ('Divine Shield', 'https://placeholder.com/shield2.png', 'ultraRare', 150);
*/

-- ====================================
-- VERIFICATION QUERIES
-- ====================================
-- Query untuk verifikasi setup:

-- Check tables
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Check RLS enabled
-- SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';

-- Check policies
-- SELECT schemaname, tablename, policyname FROM pg_policies WHERE schemaname = 'public';
