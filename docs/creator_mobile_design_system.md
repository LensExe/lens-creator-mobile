# LENS Creator mobile UI

## Audit

- The home screen placed four metrics ahead of booking requests and upcoming work. The bookings screen repeated four metrics and an attention card before the actual booking list.
- Booking summaries had three implementations with different avatar, status, date, payment, and action treatments.
- Most destination screens used a card around every list item; settings, wallet, and assistant also nested cards around simple rows and fields.
- Screen headings, badges, empty states, inputs, and sheet shapes were styled independently. The tab bar used dashboard-oriented icons.
- Login, profile editing, availability, achievements, chat, storage, and wallet repeated bordered-card groupings or screen-specific shadows even when the content was a simple form or list.
- The app already has usable booking status and payout rules, package data, messages, profile media, and delivery photos. The portal is the reference for status wording and workflow; the mobile models and providers remain unchanged.

## Visual system

- White page canvas, mist for quiet grouping, one-pixel fog separators, no decorative shadow by default. Use a surface only when content needs a distinct boundary or interaction target.
- Inter typography: page title 25/800, section title 20/700, row title 16/700, body 14/400, metadata 12/400. Allow text to wrap before shrinking below readable sizes.
- Space on a 4-point scale; 16-point page gutters, 24 to 32 points between sections, 12 to 16 points within a content group. Radii: 14 for controls, 18 for a distinct surface, 24 for sheets.
- Ember marks the primary action and attention states. Green means complete or successful. Neutral tones describe waiting, archived, and supporting information. Booking labels come from `BookingRules`.
- A booking summary scans in this order: client, session, date and time, location, price, status, then an available action. The complete details and payment breakdown stay on the booking detail screen.
- Main navigation uses five destinations: Home, Bookings, Packages, Messages, More. The More destination retains the existing sheet behavior.

## Shared components

`CreatorPageHeader`, `CreatorSectionHeader`, `CreatorAvatar`, `CreatorMediaSurface`, `CreatorStatusBadge`, `CreatorBookingTile`, `CreatorBookingTimeline`, `CreatorDecisionActions`, `CreatorFilterTabs`, `CreatorListRow`, `CreatorEmptyState`, and `CreatorSummaryStrip` define the common presentation. Buttons, inputs, tabs, sheets, and typography inherit shared Material theme settings. Feature widgets own their data, callbacks, and state; shared widgets do not modify providers or API models.
