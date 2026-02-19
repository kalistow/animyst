# 📋 DEVELOPMENT CHECKLIST

Track your progress in building Animyst Gacha Game!

---

## 🎯 Phase 1: Initial Setup ✅ COMPLETED

- [x] Install Flutter & Dart
- [x] Create Flutter project
- [x] Add Supabase Flutter dependency
- [x] Create folder structure
- [x] Define data models
- [x] Create business logic services
- [x] Setup Supabase project
- [x] Run database schema script
- [x] Configure app with Supabase credentials

---

## 🎯 Phase 2: Backend Setup ⏳ IN PROGRESS

### Supabase Configuration
- [ ] Create Supabase account & project
- [ ] Run `supabase_setup.sql` in SQL Editor
- [ ] Verify tables created (profiles, cards, user_cards)
- [ ] Verify RLS policies are active
- [ ] Test database connection from app

### Sample Data
- [ ] Insert sample cards (at least 10 cards)
- [ ] Distribute cards across all rarity levels:
  - [ ] 3-4 Normal cards
  - [ ] 2-3 Elite cards
  - [ ] 2-3 Rare cards
  - [ ] 1-2 Super Rare cards
  - [ ] 1-2 Ultra Rare cards
- [ ] Upload card images to Supabase Storage (or use placeholder URLs)

### Credentials
- [ ] Copy Supabase URL
- [ ] Copy Supabase Anon Key
- [ ] Update `lib/main.dart` with credentials
- [ ] Update `lib/core/constants/app_constants.dart` (optional)

---

## 🎯 Phase 3: Authentication ⏳ TODO

### Auth Screens
- [ ] Create `lib/features/auth/screens/login_screen.dart`
- [ ] Create `lib/features/auth/screens/register_screen.dart`
- [ ] Create `lib/features/auth/screens/forgot_password_screen.dart`
- [ ] Create `lib/features/auth/widgets/auth_form.dart`

### Auth Logic
- [ ] Implement login with email/password
- [ ] Implement registration with email/password/username
- [ ] Implement logout
- [ ] Implement forgot password
- [ ] Add form validation
- [ ] Add error handling

### Auth State Management
- [ ] Create auth state provider (Provider/Riverpod)
- [ ] Listen to auth state changes
- [ ] Auto-redirect based on auth state
- [ ] Persist auth session

### Testing
- [ ] Test user registration flow
- [ ] Verify profile auto-creation after registration
- [ ] Test login flow
- [ ] Test logout flow
- [ ] Test error states (wrong password, etc)

---

## 🎯 Phase 4: Profile & Dashboard ⏳ TODO

### Profile Screen
- [ ] Create `lib/features/profile/screens/profile_screen.dart`
- [ ] Display username
- [ ] Display gems count
- [ ] Display dust count
- [ ] Display pity counter
- [ ] Display last login
- [ ] Add edit profile button
- [ ] Add logout button

### Edit Profile
- [ ] Create edit profile screen
- [ ] Allow username change
- [ ] Add validation
- [ ] Update profile in database

### Dashboard/Home Screen
- [ ] Create main dashboard/home screen
- [ ] Show quick stats (gems, dust)
- [ ] Navigation to Gacha
- [ ] Navigation to Inventory
- [ ] Navigation to Shop
- [ ] Navigation to Profile

---

## 🎯 Phase 5: Gacha System ⏳ TODO

### Gacha Screen
- [ ] Create `lib/features/gacha/screens/gacha_screen.dart`
- [ ] Display current gems
- [ ] Display pity counter
- [ ] Display pulls until guaranteed Ultra Rare
- [ ] Show pull cost for single pull
- [ ] Show pull cost for ten pull (with discount badge)

### Pull Buttons & Logic
- [ ] Add single pull button
- [ ] Add ten pull button
- [ ] Disable buttons when gems insufficient
- [ ] Show confirmation dialog before pull
- [ ] Integrate with GachaService

### Gacha Animations
- [ ] Create pull animation (spinning/loading)
- [ ] Create card reveal animation (flip/fade)
- [ ] Add particle effects for rare cards
- [ ] Add confetti/celebration for Ultra Rare
- [ ] Add sound effects (optional)

### Result Display
- [ ] Create result screen/dialog
- [ ] Show card image
- [ ] Show card name
- [ ] Show rarity with color coding
- [ ] Show "NEW!" badge for first-time cards
- [ ] Show quantity if duplicate
- [ ] Show pity trigger notification
- [ ] Add "Pull Again" button
- [ ] Add "View Inventory" button

### Rate Display
- [ ] Create rates info screen/dialog
- [ ] Display probability for each rarity
- [ ] Show current pity counter
- [ ] Explain pity system

---

## 🎯 Phase 6: Inventory System ⏳ TODO

### Inventory Screen
- [ ] Create `lib/features/inventory/screens/inventory_screen.dart`
- [ ] Display cards in grid view
- [ ] Show card image/placeholder
- [ ] Show card name
- [ ] Show rarity with color
- [ ] Show quantity badge
- [ ] Add filter by rarity
- [ ] Add sort options (name, rarity, quantity, date obtained)
- [ ] Show total unique cards count
- [ ] Show total cards count

### Card Detail
- [ ] Create card detail screen/modal
- [ ] Show full card image
- [ ] Show card name & rarity
- [ ] Show recycle dust value
- [ ] Show quantity owned
- [ ] Show obtained date
- [ ] Add recycle button

### Recycle System
- [ ] Create recycle confirmation dialog
- [ ] Show dust value to be gained
- [ ] Implement recycle logic
- [ ] Update dust count
- [ ] Update card quantity
- [ ] Remove card from inventory if quantity = 0
- [ ] Show success feedback
- [ ] Add undo option (advanced)

---

## 🎯 Phase 7: Shop System ⏳ TODO

### Shop Screen
- [ ] Create `lib/features/shop/screens/shop_screen.dart`
- [ ] Display current gems & dust
- [ ] Create gem packages UI
- [ ] Show package prices

### Gem Packages
- [ ] Define gem packages (e.g., 100, 500, 1000, 5000 gems)
- [ ] Add pricing for each package
- [ ] Create package cards with visuals
- [ ] Highlight best value package

### Purchase Flow
- [ ] Add purchase confirmation dialog
- [ ] Implement mock purchase (for testing)
- [ ] Update gems after purchase
- [ ] Show purchase success feedback
- [ ] (Advanced) Integrate real in-app purchase

### Daily Login Rewards (Optional)
- [ ] Create daily login bonus system
- [ ] Check last login date
- [ ] Award daily gems/dust
- [ ] Show claim reward dialog
- [ ] Prevent multiple claims per day

---

## 🎯 Phase 8: State Management ⏳ TODO

Choose one: Provider or Riverpod

### Using Provider
- [ ] Add `provider` dependency
- [ ] Create `ProfileProvider`
- [ ] Create `InventoryProvider`
- [ ] Create `AuthProvider`
- [ ] Setup MultiProvider in main.dart
- [ ] Replace StatefulWidget logic with Providers

### Using Riverpod (Alternative)
- [ ] Add `flutter_riverpod` dependency
- [ ] Create providers for Profile, Inventory, Auth
- [ ] Wrap app with ProviderScope
- [ ] Use ConsumerWidget/Consumer
- [ ] Replace StatefulWidget logic with Riverpod

---

## 🎯 Phase 9: Polish & UX ⏳ TODO

### UI/UX Enhancements
- [ ] Implement dark mode support
- [ ] Add custom app theme
- [ ] Use consistent color scheme based on rarity
- [ ] Add loading indicators
- [ ] Add error states
- [ ] Add empty states
- [ ] Add pull-to-refresh
- [ ] Improve button styles
- [ ] Add icons & illustrations

### Animations & Transitions
- [ ] Add page transitions
- [ ] Add micro-animations (buttons, cards)
- [ ] Smooth scroll animations
- [ ] Hero animations for card images

### Feedback & Validation
- [ ] Add form validation messages
- [ ] Add success snackbars
- [ ] Add error snackbars
- [ ] Add haptic feedback (mobile)
- [ ] Add confirmation dialogs for destructive actions

### Responsive Design
- [ ] Test on different screen sizes
- [ ] Optimize for tablets
- [ ] Optimize for desktop (if supporting web/desktop)
- [ ] Handle landscape mode

---

## 🎯 Phase 10: Real-time Features (Advanced) ⏳ TODO

### Real-time Updates
- [ ] Setup real-time listener for profile changes
- [ ] Update UI when gems/dust changes
- [ ] Setup real-time listener for inventory
- [ ] Update inventory when new cards added
- [ ] Show notifications for real-time events

---

## 🎯 Phase 11: Testing ⏳ TODO

### Unit Tests
- [ ] Test Profile model serialization
- [ ] Test Card model serialization
- [ ] Test UserCard model serialization
- [ ] Test GachaService probability logic
- [ ] Test pity counter logic

### Widget Tests
- [ ] Test login screen
- [ ] Test gacha screen
- [ ] Test inventory screen
- [ ] Test profile screen

### Integration Tests
- [ ] Test full gacha pull flow
- [ ] Test authentication flow
- [ ] Test recycle flow

---

## 🎯 Phase 12: Performance & Optimization ⏳ TODO

### Performance
- [ ] Optimize image loading (caching)
- [ ] Lazy load inventory items
- [ ] Optimize database queries
- [ ] Add pagination for large inventories
- [ ] Profile database operations

### Code Quality
- [ ] Run `flutter analyze` and fix issues
- [ ] Remove debug print statements
- [ ] Add code documentation
- [ ] Refactor duplicated code
- [ ] Follow Dart/Flutter best practices

---

## 🎯 Phase 13: Deployment Preparation ⏳ TODO

### App Configuration
- [ ] Update app name in pubspec.yaml
- [ ] Update app description
- [ ] Update version number
- [ ] Add app icon
- [ ] Add splash screen

### Platform-Specific
#### Android
- [ ] Configure package name
- [ ] Update app permissions
- [ ] Configure signing (for release)
- [ ] Test on Android device

#### iOS (if applicable)
- [ ] Configure bundle ID
- [ ] Update app permissions
- [ ] Configure signing
- [ ] Test on iOS device

#### Web (if applicable)
- [ ] Configure PWA settings
- [ ] Test on different browsers
- [ ] Optimize for web performance

### Security
- [ ] Ensure no sensitive keys in code
- [ ] Use environment variables for secrets
- [ ] Review RLS policies
- [ ] Test security rules

---

## 🎯 Phase 14: Advanced Features (Optional) ⏳ TODO

### Social Features
- [ ] Leaderboards (most cards, rarest collection)
- [ ] Friend system
- [ ] Gift/trade system
- [ ] Achievement system

### Additional Game Mechanics
- [ ] Card evolution system
- [ ] Card fusion system
- [ ] Daily quests for gems
- [ ] Event banners (limited cards)
- [ ] Banner pity system

### Analytics
- [ ] Integrate analytics (Firebase Analytics)
- [ ] Track user engagement
- [ ] Track pull statistics
- [ ] Track conversion (if monetized)

---

## 🎯 Phase 15: Launch! 🚀 TODO

### Pre-Launch
- [ ] Final testing on all platforms
- [ ] Prepare marketing materials (screenshots, description)
- [ ] Create privacy policy
- [ ] Create terms of service

### Launch
- [ ] Submit to Play Store (Android)
- [ ] Submit to App Store (iOS)
- [ ] Deploy web version (if applicable)

### Post-Launch
- [ ] Monitor crash reports
- [ ] Monitor user feedback
- [ ] Plan updates & new features
- [ ] Fix bugs as reported

---

## 📊 Progress Summary

Track your overall progress:

- [x] Phase 1: Initial Setup (100%)
- [ ] Phase 2: Backend Setup (0%)
- [ ] Phase 3: Authentication (0%)
- [ ] Phase 4: Profile & Dashboard (0%)
- [ ] Phase 5: Gacha System (0%)
- [ ] Phase 6: Inventory System (0%)
- [ ] Phase 7: Shop System (0%)
- [ ] Phase 8: State Management (0%)
- [ ] Phase 9: Polish & UX (0%)
- [ ] Phase 10: Real-time Features (0%)
- [ ] Phase 11: Testing (0%)
- [ ] Phase 12: Performance (0%)
- [ ] Phase 13: Deployment Prep (0%)
- [ ] Phase 14: Advanced Features (0%)
- [ ] Phase 15: Launch (0%)

**Overall Progress:** 6.67% (1/15 phases)

---

## 🎯 Immediate Next Steps

**Start here:**

1. [ ] Setup Supabase project
2. [ ] Run database schema
3. [ ] Insert sample card data
4. [ ] Configure credentials in app
5. [ ] Test database connection
6. [ ] Build authentication screens
7. [ ] Build simple gacha screen (use `example_screens.dart` as reference)

---

**💪 You got this! Check off items as you complete them!**
