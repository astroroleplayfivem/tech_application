# Tech Application - Job Application System

##  Support

### Getting Help

* [Discord](https://discord.gg/DWdM4h7xbj)
* [Tebex Store](https://tshentro.tebex.io/package/7069099)
* [ Youtube](https://www.youtube.com/watch?v=M_XJmeTAxr8)


## Overview

Tech Application is a comprehensive job application system for FiveM servers that allows players to apply for various jobs through an interactive, multi-language web interface with Discord webhook integration.

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

## Screenshots

![{252DF59A-E0E4-48D6-9968-477EC020347F}|690x356](upload://edX5IgN8SNFXNGVxHwjPdhmksE.jpeg)
![{A74A843F-2119-4343-916D-F2C77D8FF12E}|690x347](upload://muCsbOG4fWnuuWsuf5wA04d6b5J.jpeg)
![{9CC0CF8B-B4A8-4326-8FB3-79BC95C0347A}|114x110](upload://9fOvld42USPPXtIYnYUC5SJTg77.png)
![{C410525F-2B2F-4AF0-825A-73EC563E1EC8}|387x500](upload://hXXd0TJAjvokFsbzvKTVQhL1OLd.png)


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

1. **Download the Resource**
   - Download from GitHub
   - Download from [Tebex](https://tshentro.tebex.io/package/7069099)
   - Place the `tech_application` folder in your resources directory
   - Recommended path: `resources/[voice]/tech_application/`

2. **Add to server.cfg**
   ```cfg
   ensure tech_application
   ```

3. **Install Dependencies**
   - Ensure you have `ox_lib` installed
   - Ensure you have either `qb-target` or `ox_target` installed

4. **Configure Discord Webhooks**
   - Set up Discord webhooks for each business in `config.lua`
   - See Configuration section for details

---
## Configuration

### Basic Configuration

Edit `config.lua` to configure your businesses:

```lua
Config = {}

-- Target system (QB or OX)
Config.Target = "OX" -- Change to "QB" for QB-Target

-- Business configuration
Config.Businesses = {
    police = {
        businessType = "police",
        businessName = "Police Department",
        webhook = "YOUR_DISCORD_WEBHOOK_URL",
        jobTitle = "Police Officer",
        locations = {
            {
                name = "mrpd",
                label = "Police Application",
                coords = vector4(425.04, -983.34, 30.71, 86.66),
                ped = true,
                pedModel = "s_m_y_cop_01",
            }
        }
    }
}
```

### Configuration Options

| Option | Type | Description |
|--------|------|-------------|
| `businessType` | string | Unique identifier for the business |
| `businessName` | string | Display name for Discord embeds |
| `webhook` | string | Discord webhook URL |
| `jobTitle` | string | Job title shown in application form |
| `locations` | table | Array of application locations |

### Location Configuration

Each location supports the following options:

| Option | Type | Description |
|--------|------|-------------|
| `name` | string | Internal name for the location |
| `label` | string | Text shown on target interaction |
| `coords` | vector4 | X, Y, Z coordinates and heading |
| `ped` | boolean | Whether to spawn an NPC |
| `pedModel` | string | NPC model hash (if ped = true) |

---

## Usage

### For Players

1. **Find Application Location**: Look for NPCs or interaction zones at business locations
2. **Interact**: Use your target system to interact with the application point
3. **Fill Form**: Complete the application form with your information
4. **Submit**: Click "Sign & Submit" to submit your application
5. **Confirmation**: You'll see a success message confirming submission

### For Administrators

1. **Monitor Applications**: Check your Discord channels for new applications
2. **Review Information**: Each application includes player identifiers and form data
3. **Process Applications**: Contact players or update their job status accordingly

---

## Discord Integration

### Setting Up Webhooks

1. **Create Discord Webhook**
   - Go to your Discord server settings
   - Navigate to Integrations â†’ Webhooks
   - Create a new webhook
   - Copy the webhook URL

2. **Configure Webhook**
   ```lua
   webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
   ```

### Discord Embed Features

- **Professional Formatting**: Clean, organized sections with visual separators
- **Custom Colors**: Each business type has a unique color scheme
- **Thumbnails**: Business-specific icons/logos
- **Player Information**: Essential identifiers (License & Discord ID)
- **Timestamp**: Application submission time
- **Code Blocks**: Motivation and references in formatted code blocks
- **Branded Footer**: Attribution to tchentro.tech

---

## Multi-language Support

### Supported Languages

- **English (en)**: Default language
- **French (fr)**: FranÃ§ais
- **Spanish (es)**: EspaÃ±ol
- **Arabic (ar)**: Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©

Players can switch languages dynamically using the language selector in the form header.

---

## Security Features

- **Server-side Validation**: All inputs are validated on the server
- **Input Sanitization**: User inputs are sanitized to prevent XSS attacks
- **Length Limits**: Input length restrictions to prevent abuse
- **Type Validation**: Strict type checking for all fields
- **Business Type Verification**: Server verifies business type exists before processing

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

## Troubleshooting

### Common Issues

#### Form Not Opening
- **Check Target System**: Ensure QB-Target or OX-Target is installed
- **Verify Coordinates**: Check if coordinates are correct
- **Check Console**: Look for JavaScript errors in browser console (F12)

#### Discord Webhooks Not Working
- **Verify URL**: Ensure webhook URL is correct and active
- **Check Permissions**: Discord bot needs permission to send messages
- **Test Webhook**: Use a webhook tester to verify functionality
- **Check Server Console**: Look for error messages

#### NPCs Not Spawning
- **Check Model**: Verify ped model exists in game
- **Check Coordinates**: Ensure coordinates are valid
- **Check Console**: Look for model loading errors

#### Translation Issues
- **Check Language Code**: Ensure language code matches translation keys
- **Verify Translations**: Check if all required translations exist
- **Clear Cache**: Clear browser cache and restart resource

---

## API Reference

### Client Events

| Event | Parameters | Description |
|-------|------------|-------------|
| `tech_application:openApply` | businessType | Opens application form for specified business |

### Server Events

| Event | Parameters | Description |
|-------|------------|-------------|
| `tech_application:sendApply` | formData, businessType | Processes and sends application to Discord |

### NUI Callbacks

| Callback | Parameters | Description |
|----------|------------|-------------|
| `submitApplication` | data | Handles form submission |
| `cancelApplication` | data | Handles form cancellation |

---


### Contact Information

- **Author**: TshentroTech
- **Version**: 2.0.0
- **Framework**: QBCore Compatible
- **Languages**: 4 Languages Supported

---

## Acknowledgments

- **TshentroTech**: Original author
- **FiveM Community**: For support and feedback
- **Discord**: For webhook integration
- **Contributors**: All those who have contributed to this project

---


### Code Release Information

|                             |                 |
|-----------------------------|-----------------|
| Code is accessible          | Yes             |
| Subscription-based          | No              |
| Lines (approximately)       | ~250            |
| Requirements & dependencies | ox_lib, QB-Target or OX-Target |
| Support                     | Yes             |

---

**Made with for the FiveM Community**
