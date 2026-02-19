-- ====================================
-- CREATE TEST USER ACCOUNT
-- ====================================
-- Run this in Supabase SQL Editor to create a test account

-- Method 1: Using Supabase Dashboard (RECOMMENDED)
-- Go to: Authentication > Users > Add user
-- Email: test@animyst.com
-- Password: test123456
-- Auto Confirm: Yes

-- Method 2: Using SQL (if you have admin access)
-- Note: This is for testing only. In production, use proper signup flow.

-- The profile will be auto-created by the trigger when user signs up
-- So you just need to create the user in Supabase Dashboard

-- After user is created, verify profile exists:
SELECT * FROM profiles WHERE username LIKE '%test%';

-- If profile doesn't exist, create manually:
-- INSERT INTO profiles (id, username, gems, dust, free_dust, pity_counter)
-- VALUES (
--   'YOUR-USER-ID-FROM-AUTH',
--   'TestUser',
--   100,
--   0,
--   3000,
--   0
-- );
