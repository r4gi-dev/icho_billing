Config = {}

Config.Language = 'ja'
Config.Command = 'billing'
Config.DefaultKey = 'F7'
Config.KeybindDescription = 'Open billing menu'

Config.Menu = {
    -- Set a string here to override locales/<language>.lua menu.title.
    Title = nil,
    Position = 'top-right'
}

Config.Common = {
    MinAmount = 1,
    MaxAmount = 1000000,
    MaxDescriptionLength = 120,
    HistoryLimit = 50,
    AllowSelfBilling = false,
    RequireNearby = true,
    MaxDistance = 5.0,
    Accounts = { 'bank', 'cash' }
}

Config.PersonalBilling = {
    Enabled = true,
    -- Set a string here to override locales/<language>.lua menu.personal_billing.
    Label = nil
}

Config.JobBilling = {
    Enabled = true,
    -- Set a string here to override locales/<language>.lua menu.job_billing.
    Label = nil,
    PoolResource = 'qb-banking',
    PoolReason = 'Job invoice payment',
    DefaultPoolPercent = 100,
    RemainderTarget = 'issuer',
    RequireOnDuty = true,
    Jobs = {
        -- poolAccount は省略可能です。省略時は job 名をそのまま入金先に使います。
        -- police = {
        --     label = '警察',
        --     minGrade = 0,
        --     requireOnDuty = true,
        --     poolPercent = 100,
        -- },
        mechanic = {
            label = 'メカニック',
            minGrade = 0,
            requireOnDuty = true,
            poolPercent = 100,
        },
        irishpub = {
            label = 'Irish Pub',
            minGrade = 0,
            requireOnDuty = true,
            poolPercent = 100,
        },
    }
}

Config.Database = {
    AutoCreateTable = true
}

Config.UI = {
    StatusIcon = {
        unpaid = 'clock',
        paid = 'circle-check',
        cancelled = 'ban'
    },
    StatusIconColor = {
        unpaid = '#f59e0b',
        paid = '#22c55e',
        cancelled = '#ef4444'
    }
}
