# Lens Creator migration map

Source of truth: `../Lens-web/apps/portal/src/App.tsx` and its dashboard, settings, messaging, booking, storage, and wallet modules. Target: this Flutter app. The customer app is untouched.

| Web route / flow | Web components and rules | Flutter route / owner | State and model |
| --- | --- | --- | --- |
| `/login`, `/signup` | `LoginForm`, `SignupForm`, role guard; email and password validation | `/login` · `features/auth` | Mock auth repository, `authUserProvider` |
| `/dashboard` | `GreetingBanner`, `RequestCard`, earnings, agenda, shortcuts | `/photographer_home` · `features/photographer` | Incoming bookings, photographer profile |
| `/dashboard/bookings` | Four lifecycle groups, search, date scope, pending decisions | `/photographer_home/bookings` · `features/photographer/bookings` | `Booking`, `BookingRules`, booking repository |
| `/dashboard/bookings/:id` | Deposit, price, timeline, accept/decline, delivery gate, collaborator share | `/photographer_home/booking/:id` | Same booking repository; only pending → confirmed/cancelled is a photographer action |
| `/dashboard/bookings/:id/gallery` | Delivered photos and required-count progress | `/photographer_home/booking/:id/gallery` | Booking snapshot + mock delivery photos |
| `/dashboard/portfolio` | Profile fields, styles, portfolio grid and validation | `/photographer_home/portfolio` | `Photographer`, `photographersProvider` |
| `/dashboard/packages` | Package terms, validation, add/edit/remove, minimum one | `/photographer_home/packages` and `/edit/:id` | `PhotographerPackage`, profile state |
| `/dashboard/availability` | Weekly 30-minute slots, date exceptions, booked cells, explicit save | `/photographer_home/availability` | `WorkSchedule`, `scheduleProvider` |
| `/messages` | Inbox, unread filter, thread, AI toggle, contact booking links | `/photographer_home/messages` and `/:id` | `StudioConversation`, `conversationsProvider` |
| `/dashboard/assistant` | Enabled state, services, style, area, tone, FAQ, canned reply/handoff rules | `/photographer_home/assistant` | `AssistantConfig`, `assistantProvider`, `AssistantRules` |
| `/wallet` | Balance, pending payout, transactions, withdrawal | `/photographer_home/wallet` | Local wallet ledger and incoming bookings |
| `/dashboard/storage` | Plans, usage, expiry, locked galleries, quota | `/photographer_home/storage` | Storage tier and derived gallery metadata |
| `/dashboard/achievements` | Rank thresholds, progress, badges | `/photographer_home/achievements` | Historical demo seed + released bookings |
| `/settings/{profile,account,notifications}` | Personal form, account and notification preferences | `/photographer_home/settings` (tabs) | `User`, notification settings provider |
| `/photographers/:id` | Public creator preview | `/photographer_home/public_profile` · `PublicProfileScreen` | Live creator profile and packages |
| Collaboration invitations | Lead invites and allocates shares; invitee accepts/declines | Home, bookings, booking detail · `CollaborationInvites`, `CollaboratorsPanel` | Booking collaborator state and rounded accepted-share payout |

## Mobile decisions

- Five primary destinations stay in bottom navigation; the other Studio tools live in the More sheet. Bookings, gallery, and editor remain nested screens.
- Web package terms are snapshotted on bookings. Editing a package cannot silently alter a prior booking's promised photo count or delivery time.
- `awaitingDeposit` is hidden from the creator; only a deposited pending request can be accepted or declined. The creator cannot release escrow. The client confirmation remains a customer-side action.
- Mock galleries supply stock images, matching the portal's mock upload phase. Mobile does not yet upload a device photo to remote storage.
- The web's mock API uses in-memory and local stores. The current Flutter mock providers are in-memory and form an adapter boundary for later mobile APIs.

## Remaining parity work

- Actual device photo picking/uploading and backend-reported file sizes/quotas. The in-memory storage mock models the portal's expiry and locking states.
- Persistent local session and mock edits after process restart, real authentication and server synchronization.
- Full wallet/Lens Xu ledger and client-triggered escrow release; the creator app only shows local creator money transactions.
- A real cross-app incoming-message transport. The mock conversation state implements the portal's canned reply/handoff rule, but no connected client can yet send live messages to this app.
- Real notification delivery, account password changes, and complete review/achievement datasets from the backend.

## Verification

Verified with `flutter analyze --no-pub`, `flutter test --no-pub` (11 passing tests), and `flutter build ios --simulator --no-codesign --no-pub` (build succeeded). `test/creator_flow_test.dart` covers the request lifecycle, financial and collaboration rounding, demo booking scope, schedule booking cells, storage upgrade/unlock, assistant handoff, a pending card at 320px, and demo login → dashboard → packages → public profile navigation.
