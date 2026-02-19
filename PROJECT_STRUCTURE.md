# 📂 PROJECT STRUCTURE

```
d:\animyst\
│
├── 📄 pubspec.yaml                    # Dependencies (supabase_flutter added)
├── 📄 README.md                       # Project overview
├── 📄 SETUP_GUIDE.md                  # Detailed setup instructions
├── 📄 SETUP_SUMMARY.md                # What's been completed
├── 📄 QUICK_REFERENCE.md              # Code snippets & patterns
├── 📄 supabase_setup.sql              # Database schema & setup
│
├── 📁 lib\
│   │
│   ├── 📄 main.dart                   # ⭐ Entry point with Supabase config
│   │
│   ├── 📁 core\                       # ⭐ Core business logic
│   │   │
│   │   ├── 📁 constants\
│   │   │   └── app_constants.dart     # Game config, rates, costs
│   │   │
│   │   ├── 📁 enums\
│   │   │   ├── rarity.dart            # Rarity enum (Normal → Ultra Rare)
│   │   │   └── enums.dart             # Barrel export
│   │   │
│   │   ├── 📁 models\                 # ⭐ Data models
│   │   │   ├── profile.dart           # User profile (gems, dust, pity)
│   │   │   ├── card.dart              # Card (name, rarity, image)
│   │   │   ├── user_card.dart         # Inventory (user+card+quantity)
│   │   │   └── models.dart            # Barrel export
│   │   │
│   │   └── 📁 services\               # ⭐ Business logic services
│   │       ├── profile_service.dart   # Profile CRUD operations
│   │       ├── card_service.dart      # Card queries
│   │       ├── inventory_service.dart # Inventory management
│   │       ├── gacha_service.dart     # Gacha pull logic with pity
│   │       └── services.dart          # Barrel export
│   │
│   └── 📁 features\                   # ⭐ Feature modules (ready for development)
│       │
│       ├── 📁 auth\                   # Authentication feature
│       │   └── .gitkeep               # (TODO: Login, Register screens)
│       │
│       ├── 📁 gacha\                  # Gacha feature
│       │   └── .gitkeep               # (TODO: Pull screen, animations)
│       │
│       ├── 📁 shop\                   # Shop feature
│       │   └── .gitkeep               # (TODO: Gem purchase)
│       │
│       └── 📁 inventory\              # Inventory feature
│           └── .gitkeep               # (TODO: Card grid, recycle)
│
├── 📁 android\                        # Android platform files
├── 📁 ios\                            # iOS platform files
├── 📁 web\                            # Web platform files
├── 📁 windows\                        # Windows platform files
├── 📁 linux\                          # Linux platform files
└── 📁 macos\                          # macOS platform files
```

---

## 🗂️ File Organization by Purpose

### 🎯 Configuration Files
- `pubspec.yaml` - Dependencies & assets
- `main.dart` - App initialization & Supabase config

### 📊 Data Layer
- `lib/core/models/` - Data models (Profile, Card, UserCard)
- `lib/core/enums/` - Enumerations (Rarity)

### 🔧 Business Logic Layer
- `lib/core/services/` - Service classes (Profile, Card, Inventory, Gacha)
- `lib/core/constants/` - App-wide constants

### 🎨 Presentation Layer (Ready for Development)
- `lib/features/auth/` - Authentication UI
- `lib/features/gacha/` - Gacha UI
- `lib/features/shop/` - Shop UI
- `lib/features/inventory/` - Inventory UI

### 📚 Documentation
- `README.md` - Overview
- `SETUP_GUIDE.md` - Step-by-step setup
- `SETUP_SUMMARY.md` - Completion checklist
- `QUICK_REFERENCE.md` - Code snippets
- `supabase_setup.sql` - Database schema

---

## 🔄 Data Flow

```
┌─────────────────────────────────────────────────────┐
│                    USER INTERFACE                   │
│              (features/auth, gacha, etc)            │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│                  SERVICES LAYER                     │
│  (ProfileService, GachaService, InventoryService)   │
│              - Business Logic                       │
│              - Data Validation                      │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│                   MODELS LAYER                      │
│             (Profile, Card, UserCard)               │
│         - fromJson() / toJson()                     │
│         - Data transformation                       │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│            SUPABASE CLIENT (main.dart)              │
│              - API calls                            │
│              - Authentication                       │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│                 SUPABASE BACKEND                    │
│       - PostgreSQL Database                         │
│       - Row Level Security                          │
│       - Real-time subscriptions                     │
└─────────────────────────────────────────────────────┘
```

---

## 🎮 Gacha Flow Example

```
User taps "Single Pull" button
         │
         ▼
UI calls GachaService.performSinglePull(userId)
         │
         ├─> Check gems via ProfileService
         ├─> Determine rarity based on pity counter
         ├─> Get random card via CardService
         ├─> Deduct gems via ProfileService
         ├─> Update pity counter via ProfileService
         ├─> Add card to inventory via InventoryService
         │
         ▼
Return GachaResult(card, isPityTriggered)
         │
         ▼
UI shows animation & card result
```

---

## 📦 Import Hierarchy

```
main.dart
  │
  ├─> constants/app_constants.dart
  │
  ├─> enums/enums.dart
  │     └─> rarity.dart
  │
  ├─> models/models.dart
  │     ├─> profile.dart
  │     ├─> card.dart (imports rarity.dart)
  │     └─> user_card.dart
  │
  └─> services/services.dart
        ├─> profile_service.dart (imports models, constants)
        ├─> card_service.dart (imports models, enums, constants)
        ├─> inventory_service.dart (imports models, constants)
        └─> gacha_service.dart (imports all services, models, enums)
```

---

## 🔑 Key Files Explained

### `main.dart`
- Initializes Supabase with URL & Anon Key
- Exports global `supabase` client
- Runs the app

### `core/models/`
**Purpose:** Define data structures that match database tables
- `Profile` → `profiles` table
- `Card` → `cards` table  
- `UserCard` → `user_cards` table

Each model has:
- Constructor with named parameters
- `fromJson()` factory for parsing Supabase response
- `toJson()` method for sending data to Supabase
- `copyWith()` for immutable updates
- `toString()`, `==`, `hashCode` overrides

### `core/services/`
**Purpose:** Encapsulate all database operations

#### ProfileService
Manages user profile data (gems, dust, pity counter)

#### CardService  
Queries available cards from database

#### InventoryService
Manages user's card collection

#### GachaService
**The brain of the gacha system:**
- Calculates drop rates
- Manages pity counter
- Orchestrates pull operations
- Coordinates ProfileService, CardService, and InventoryService

### `core/constants/app_constants.dart`
**Central configuration:**
- Drop rates (50%, 30%, 15%, 4%, 1%)
- Pull costs (100 gems, 900 gems)
- Pity threshold (90 pulls)
- Dust values per rarity
- Table names

---

## 🎨 Suggested Feature Structure (for development)

When building features, recommended structure:

```
features/gacha/
├── screens/
│   ├── gacha_screen.dart          # Main gacha screen
│   └── result_screen.dart         # Pull result screen
├── widgets/
│   ├── pull_button.dart           # Single/Ten pull buttons
│   ├── gacha_animation.dart       # Pull animation
│   ├── card_reveal.dart           # Card flip/reveal animation
│   └── pity_indicator.dart        # Shows pulls until pity
└── gacha_controller.dart          # State management (Provider/Riverpod)
```

Similar structure for `auth/`, `shop/`, `inventory/`

---

## 🗄️ Database ER Diagram

```
┌─────────────────────┐
│      auth.users     │  (Supabase Auth)
│   (built-in table) │
└──────────┬──────────┘
           │
           │ 1:1
           │
           ▼
┌─────────────────────┐
│      profiles       │
│─────────────────────│
│ • id (PK, FK)       │◄──┐
│ • username          │   │
│ • gems              │   │
│ • dust              │   │
│ • pity_counter      │   │
│ • last_login        │   │
└─────────────────────┘   │
                          │
                          │ 1:N
                          │
                  ┌───────┴────────┐
                  │   user_cards   │
                  │────────────────│
                  │ • id (PK)      │
                  │ • user_id (FK) │
                  │ • card_id (FK) │──┐
                  │ • quantity      │  │
                  └────────────────┘  │
                                      │
                                      │ N:1
                                      │
                                      ▼
                             ┌────────────────┐
                             │     cards      │
                             │────────────────│
                             │ • id (PK)      │
                             │ • name         │
                             │ • image_url    │
                             │ • rarity       │
                             │ • recycle_dust │
                             └────────────────┘
```

**Relationships:**
- `auth.users` ←→ `profiles` (1:1)
- `profiles` ←→ `user_cards` (1:N)
- `cards` ←→ `user_cards` (1:N)

---

## ✅ Completed vs TODO

### ✅ Completed
- [x] Project structure
- [x] Data models with serialization
- [x] Business logic services
- [x] Gacha algorithm with pity system
- [x] Database schema
- [x] Supabase configuration
- [x] Documentation

### ⏳ TODO (Your next steps)
- [ ] Authentication screens (login, register)
- [ ] Gacha UI with animations
- [ ] Inventory grid view
- [ ] Shop UI
- [ ] Profile management screen
- [ ] State management (Provider/Riverpod)
- [ ] Error handling & loading states
- [ ] Testing

---

**📖 Use this as a map while developing!**
