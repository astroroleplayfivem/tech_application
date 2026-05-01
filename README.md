# Tech Application - Astro Upgraded Job Application System

A modern FiveM job application system that allows players to apply for businesses, departments, and city jobs through an in-game application portal.

This version has been edited, upgraded, and expanded by **Opie Winters / Astro Scripts** with a redesigned workflow, application tracking, management tools, themed businesses, applicant history, interview updates, and improved roleplay usability.

---

## Credits

**Original Author:** TshentroTech  
**Original Resource:** Tech Application  

**Edited / Upgraded By:** Opie Winters  
**Brand:** Astro Scripts / Astro Roleplay  

Please respect the original creator while recognizing this version as the upgraded Astro edit.

---

## Astro Scripts Links

**Discord:**  
https://discord.gg/PDZ9cYkAXk

**Tebex:**  
https://astro-scripts-webstore.tebex.io/category/3287949

**YouTube:**  
https://www.youtube.com/@astrocodeslua

---

## Overview

Tech Application is a FiveM job application system built for roleplay servers that want a clean and organized way for players to apply for jobs.

Players can walk up to configured application locations, interact with a PED or target zone, open a themed application portal, fill out their information, and submit an application directly in-game.

Managers and bosses can review submitted applications through a management panel, update application statuses, schedule interviews, leave notes for applicants, and track previous applications from the same player.

This makes hiring more organized, immersive, and useful for businesses, whitelisted jobs, departments, and server staff teams.

---

## Main Features

- In-game job application portal
- Multiple configurable businesses
- Business-specific application locations
- Optional PED interaction at each location
- Target zone support
- Themed UI per business
- Application tracking for players
- Previous application history
- Player “My Applications” tab
- Management panel for bosses/staff
- Review submitted applications
- Search applications by applicant details
- Filter applications by status
- Update application status
- Schedule interview date/time
- Add interview location
- Add interview instructions
- Add manager-only notes
- Add visible applicant update notes
- Live applicant notifications when an application is updated
- Discord webhook support
- JSON-based application storage
- No SQL database required
- Server-side validation
- Input sanitization
- Character counters
- ESC close support
- Clean NUI interface
- Supports `qb-target`
- Supports `ox_target`

---

## Player Features

Players can:

- Apply for configured city jobs
- Submit their full name, age, phone number, Discord, experience, availability, motivation, and references
- Track applications they already submitted
- View application status
- View interview details when a manager updates the application
- See notes sent by management
- Review previous applications for the same business
- Receive live notifications when their application is updated

---

## Management Features

Authorized managers can:

- Open the application management panel
- View all applications for their business
- Review applicant information
- See repeat applicant history
- Search applications
- Filter by status
- Accept applications
- Deny applications
- Mark applications for interview
- Set interview time
- Set interview location
- Add interview instructions
- Leave internal manager notes
- Send visible update notes to the applicant
- Trigger Discord webhook updates

---

## Application Statuses

The script supports application status tracking such as:

- Pending
- Interview
- Accepted
- Denied

Managers can update an application and the applicant can view the latest status from the same application location.

---

## Framework

This resource is built for:

- QBCore

---

## Dependencies

Required:

- `qb-core`
- `ox_lib`

Optional target systems:

- `qb-target`
- `ox_target`

---

## Storage

Applications are saved using a JSON file:

```lua
data/applications.json



<img width="1395" height="1004" alt="main jobapp" src="https://github.com/user-attachments/assets/8ca3429d-adfa-4e0d-8972-e7f4e96f5a84" />
<img width="1248" height="846" alt="burrgershotapp" src="https://github.com/user-attachments/assets/a2e6ce6e-8a2a-45dc-ad50-a4d18c2e9fa0" />
<img width="1418" height="991" alt="myapplications" src="https://github.com/user-attachments/assets/2445907d-1d63-499e-93b2-b28790b6c0c1" />
