-- Add column to track if user has claimed the Ultra Rare collection reward
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS ur_collection_reward_claimed BOOLEAN DEFAULT FALSE;
