# Tech Application - Job Application System / Updated by Astro RP

##  Support

### Getting Help

* [Discord](https://discord.gg/DWdM4h7xbj)
* [Tebex Store](https://tshentro.tebex.io/package/7069099)
* [ Youtube](https://www.youtube.com/watch?v=M_XJmeTAxr8)

### Astro Scripts 
Discord : https://discord.gg/PDZ9cYkAXk
Tebex :  https://astro-scripts-webstore.tebex.io/category/3287949
Youtube : https://www.youtube.com/@astrocodeslua


## Overview

Tech Application is a comprehensive job application system for FiveM servers that allows players to apply for various jobs through an interactive, multi-language web interface with Discord webhook integration. This has been completed upgraded by Opie Winters & Astro Roleplay. 

---

## Features

### Core Functionality
- **Interactive Job Applications**: Beautiful, responsive web interface for job applications
- **Multiple Business Support**: Configure unlimited businesses with different application locations
- **Discord Webhook Integration**: Automatic submission of applications to Discord channels with professional formatting
- **Real-time Form Validation**: Client-side and server-side validation with error messages
- **Character Counter**: Live character counting for text areas
- **Digital Signature**: Animated signing process for form submission

### Multi-language Support
- **4 Languages**: English, French, Spanish, Arabic
- **Dynamic Language Switching**: Players can change language during application
- **Comprehensive Translations**: All UI elements, labels, and messages translated

### User Experience
- **Modern UI Design**: Clean, professional interface with handwriting-style inputs
- **Responsive Design**: Works on all screen sizes
- **Smooth Animations**: Form transitions, signing animations, and success messages
- **Keyboard Navigation**: ESC key to close, tab navigation support
- **Paper-like Appearance**: Realistic form styling with subtle textures

### Technical Features
- **Target System Support**: Compatible with both QB-Target and OX-Target
- **NPC Integration**: Optional NPCs at application locations
- **Player Identification**: Automatic collection of player identifiers
- **Error Handling**: Comprehensive error handling and logging
- **Performance Optimized**: Efficient resource usage
- **Security**: Server-side validation and input sanitization

---

### Screenshot Requirements:
1. **Main Preview Image**: Form interface showing the application form
2. **Multi-language Support**: Show language selector in action
3. **Discord Integration**: Show Discord webhook embed example
4. **In-game Usage**: Show NPC interaction or target system
5. **Form Validation**: Show validation errors/messages

---

## Installation

### Prerequisites
- FiveM Server
- QBCore Framework (or compatible framework)
- Target System (QB-Target or OX-Target)
- ox_lib (for shared scripts)

### Installation Steps

2. **Add to server.cfg**
   ```cfg
   ensure tech_application
   ```

3. **Install Dependencies**
   - Ensure you have `ox_lib` installed
```
4. Config Options 

    catcafe = {
        businessType = "catcafe",
        businessName = "Cat Cafe",
        webhook = "",
        jobTitle = "Cook",
        theme = {
            icon = 'fa-solid fa-cat',
            badge = 'Cafe Hiring',
            accent = '#ec4899',
            accentSoft = 'rgba(236,72,153,0.18)',
            panel = '#3f1d2e',
            panel2 = '#111827',
            headline = 'Soft vibe, steady service, and clean food roleplay.',
            applyLabel = 'Apply to Cat Cafe',
        },
        locations = {
            { name = "catcafe_frontdesk", label = "Cat Cafe Applications", coords = vector4(-582.54, -1070.55, 22.33, 187.68), ped = true, pedModel = "s_m_m_lathandy_01" }
        }
    },
}
---

## Multi-language Support

### Supported Languages

- **English (en)**: Default language
- **French (fr)**: FranÃ§ais
- **Spanish (es)**: EspaÃ±ol
- **Arabic (ar)**: Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©

Players can switch languages dynamically using the language selector in the form header.

---

## Performance

### Resource Usage
- **Client-side**: Minimal impact, only active when form is open
- **Server-side**: Efficient event handling, minimal processing overhead
- **Network**: Only sends data when form is submitted

### Optimization Tips
- Limit the number of NPCs spawned
- Use appropriate target zone sizes
- Configure only necessary businesses

---


## API Reference

---

## Acknowledgments
- **TshentroTech**: Original author
