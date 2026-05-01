Config = {}

Config.Target = "QB" -- QB / OX

Config.Management = {
    enabled = true,
    command = "jobapps",
    acePermission = "techapplication.manage",
    requireBoss = true,
    jobs = {
        police = true,
        ems = true,
        mechanic = true,
        tow = true,
        tequilala = true,
        realestate = true,
        burgershot = true,
        whitewidow = true,
        catcafe = true,
    },
    identifiers = {
        -- "license:xxxxxxxxxxxxxxxx",
    },
    allowTargetAccess = true,
    managementLabel = "Manage Applications",
}

Config.Notifications = {
    enableLiveNotify = true,
    applicantUpdateText = 'Your %s application was updated: %s',
    interviewUpdateText = 'Your %s interview was updated: %s',
}

Config.Businesses = {
    police = {
        businessType = "police",
        businessName = "Police Department",
        webhook = "",
        jobTitle = "Police Officer",
        theme = {
            icon = 'fa-solid fa-shield-halved',
            badge = 'Recruitment Bureau',
            accent = '#3b82f6',
            accentSoft = 'rgba(59,130,246,0.18)',
            panel = '#0f172a',
            panel2 = '#111827',
            headline = 'Serve the city with discipline, composure, and clean reports.',
            applyLabel = 'Apply to LSPD',
        },
        locations = {
            { name = "mrpd", label = "Police Applications", coords = vector4(-577.67, -408.48, 35.18, 357.0), ped = true, pedModel = "s_m_y_cop_01" }
        }
    },
    ems = {
        businessType = "ems",
        businessName = "Emergency Medical Services",
        webhook = "",
        jobTitle = "Paramedic",
        theme = {
            icon = 'fa-solid fa-truck-medical',
            badge = 'Medical Recruitment',
            accent = '#ef4444',
            accentSoft = 'rgba(239,68,68,0.18)',
            panel = '#111827',
            panel2 = '#1f2937',
            headline = 'Fast hands, cool head, and calm bedside RP.',
            applyLabel = 'Apply to EMS',
        },
        locations = {
            { name = "pillbox_hospital", label = "EMS Applications", coords = vector4(-490.67, -1006.05, 23.59, 92.41), ped = true, pedModel = "s_m_m_scientist_01" }
        }
    },
    rideout = {
        businessType = "mechanic",
        businessName = "Rideout Customs",
        webhook = "",
        jobTitle = "Mechanic",
        theme = {
            icon = 'fa-solid fa-screwdriver-wrench',
            badge = 'Shop Floor Hiring',
            accent = '#f97316',
            accentSoft = 'rgba(249,115,22,0.18)',
            panel = '#111111',
            panel2 = '#1c1917',
            headline = 'Real wrench work, diagnostics, installs, and customer trust.',
            applyLabel = 'Apply to Rideout',
        },
        locations = {
            { name = "ls_customs_wattersons", label = "Rideout Applications", coords = vector4(551.74, -185.11, 54.53, 96.64), ped = true, pedModel = "s_m_m_lathandy_01" }
        }
    },
    watteronstowing = {
        businessType = "tow",
        businessName = "Wattersons Towing",
        webhook = "",
        jobTitle = "Tow Operator",
        theme = {
            icon = 'fa-solid fa-truck-pickup',
            badge = 'Tow Dispatch Hiring',
            accent = '#eab308',
            accentSoft = 'rgba(234,179,8,0.18)',
            panel = '#111827',
            panel2 = '#1f2937',
            headline = 'Heavy recovery, roadside jobs, and a strong radio voice.',
            applyLabel = 'Apply to Towing',
        },
        locations = {
            { name = "ls_tow_wattersons", label = "Towing Applications", coords = vector4(465.21, -1156.72, 29.42, 182.56), ped = true, pedModel = "s_m_m_lathandy_01" }
        }
    },
    harmony = {
        businessType = "mechanic",
        businessName = "Harmony Mechanic",
        webhook = "",
        jobTitle = "Mechanic",
        theme = {
            icon = 'fa-solid fa-gauge-high',
            badge = 'Route 68 Hiring',
            accent = '#22c55e',
            accentSoft = 'rgba(34,197,94,0.18)',
            panel = '#111827',
            panel2 = '#052e16',
            headline = 'Country shop hustle with fast turnarounds and clean installs.',
            applyLabel = 'Apply to Harmony',
        },
        locations = {
            { name = "ls_customs_harmony", label = "Harmony Applications", coords = vector4(1194.64, 2659.14, 38.39, 8.89), ped = true, pedModel = "s_m_m_lathandy_01" }
        }
    },
    tequilala = {
        businessType = "tequilala",
        businessName = "Tequilala",
        webhook = "",
        jobTitle = "Tequilala Employee",
        theme = {
            icon = 'fa-solid fa-martini-glass-citrus',
            badge = 'Venue Hiring',
            accent = '#a855f7',
            accentSoft = 'rgba(168,85,247,0.18)',
            panel = '#1f1335',
            panel2 = '#0f172a',
            headline = 'Hospitality, nightlife energy, and good customer memory.',
            applyLabel = 'Apply to Tequilala',
        },
        locations = {
            { name = "tequilala_frontdesk", label = "Tequilala Applications", coords = vector4(-567.31, 275.23, 83.02, 175.85), ped = true, pedModel = "s_m_m_migrant_01" }
        }
    },
    realestate = {
        businessType = "realestate",
        businessName = "Real Estate",
        webhook = "",
        jobTitle = "Real Estate Employee",
        theme = {
            icon = 'fa-solid fa-building',
            badge = 'Agency Hiring',
            accent = '#f59e0b',
            accentSoft = 'rgba(245,158,11,0.18)',
            panel = '#18181b',
            panel2 = '#111827',
            headline = 'Close deals, host showings, and know the city like a map.',
            applyLabel = 'Apply to Real Estate',
        },
        locations = {
            { name = "realestate_frontdesk", label = "Real Estate Applications", coords = vector4(-696.73, 268.67, 83.11, 24.36), ped = true, pedModel = "s_m_m_migrant_01" }
        }
    },
    burgershot = {
        businessType = "burgershot",
        businessName = "Burger Shot",
        webhook = "",
        jobTitle = "Burger Shot Employee",
        theme = {
            icon = 'fa-solid fa-burger',
            badge = 'Crew Hiring',
            accent = '#fb923c',
            accentSoft = 'rgba(251,146,60,0.18)',
            panel = '#1c1917',
            panel2 = '#111827',
            headline = 'Fast service, kitchen hustle, and clean customer RP.',
            applyLabel = 'Apply to Burger Shot',
        },
        locations = {
            { name = "burger_shot_downtown", label = "Burger Shot Applications", coords = vector4(-1180.72, -885.31, 13.8, 309.62), ped = true, pedModel = "s_m_m_migrant_01" }
        }
    },
    whitewidow = {
        businessType = "whitewidow",
        businessName = "White Widow",
        webhook = "",
        jobTitle = "Budtender",
        theme = {
            icon = 'fa-solid fa-cannabis',
            badge = 'Dispensary Hiring',
            accent = '#10b981',
            accentSoft = 'rgba(16,185,129,0.18)',
            panel = '#052e16',
            panel2 = '#111827',
            headline = 'Know the menu, keep it smooth, and handle customers well.',
            applyLabel = 'Apply to White Widow',
        },
        locations = {
            { name = "whitewidow_frontdesk", label = "White Widow Applications", coords = vector4(203.06, -242.06, 53.96, 303.49), ped = true, pedModel = "s_m_m_lathandy_01" }
        }
    },
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
