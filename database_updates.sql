-- ====================================
-- DATABASE UPDATE: Add free_dust field
-- ====================================
-- Run this in Supabase SQL Editor to add free_dust field to profiles table

-- Add free_dust column to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS free_dust INTEGER DEFAULT 3000 CHECK (free_dust >= 0);

-- Add comment for documentation
COMMENT ON COLUMN profiles.free_dust IS 'Free dust that resets daily to 3000';

-- Update existing profiles to have 3000 free_dust
UPDATE profiles SET free_dust = 3000 WHERE free_dust IS NULL;
