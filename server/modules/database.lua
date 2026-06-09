local Server = IchoBilling.Server
local Utils = IchoBilling.Utils

local CreateTableSql = [[
CREATE TABLE IF NOT EXISTS `icho_billing_invoices` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `invoice_type` ENUM('personal', 'job') NOT NULL DEFAULT 'personal',
    `issuer_citizenid` VARCHAR(50) NOT NULL,
    `issuer_name` VARCHAR(100) NOT NULL,
    `issuer_job_name` VARCHAR(50) DEFAULT NULL,
    `issuer_job_label` VARCHAR(100) DEFAULT NULL,
    `recipient_citizenid` VARCHAR(50) NOT NULL,
    `recipient_name` VARCHAR(100) NOT NULL,
    `amount` INT UNSIGNED NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    `job_pool_account` VARCHAR(50) DEFAULT NULL,
    `job_pool_percent` TINYINT UNSIGNED DEFAULT NULL,
    `job_pool_amount` INT UNSIGNED DEFAULT NULL,
    `job_remainder_amount` INT UNSIGNED DEFAULT NULL,
    `status` ENUM('unpaid', 'paid', 'cancelled') NOT NULL DEFAULT 'unpaid',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `paid_at` TIMESTAMP NULL DEFAULT NULL,
    `paid_by_account` VARCHAR(20) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_recipient_status` (`recipient_citizenid`, `status`),
    KEY `idx_issuer_status` (`issuer_citizenid`, `status`),
    KEY `idx_type_status` (`invoice_type`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
]]

local SelectSql = [[
    SELECT
        id,
        invoice_type,
        issuer_citizenid,
        issuer_name,
        issuer_job_name,
        issuer_job_label,
        recipient_citizenid,
        recipient_name,
        amount,
        description,
        job_pool_account,
        job_pool_percent,
        job_pool_amount,
        job_remainder_amount,
        status,
        DATE_FORMAT(created_at, '%Y-%m-%d %H:%i') AS created_at,
        DATE_FORMAT(paid_at, '%Y-%m-%d %H:%i') AS paid_at,
        paid_by_account
    FROM icho_billing_invoices
]]

function Server.ensureSchema()
    if not Config.Database.AutoCreateTable then
        return
    end

    MySQL.query.await(CreateTableSql)

    local columns = {
        {
            name = 'invoice_type',
            sql = "ALTER TABLE `icho_billing_invoices` ADD COLUMN `invoice_type` ENUM('personal', 'job') NOT NULL DEFAULT 'personal'"
        },
        {
            name = 'job_pool_account',
            sql = 'ALTER TABLE `icho_billing_invoices` ADD COLUMN `job_pool_account` VARCHAR(50) DEFAULT NULL'
        },
        {
            name = 'job_pool_percent',
            sql = 'ALTER TABLE `icho_billing_invoices` ADD COLUMN `job_pool_percent` TINYINT UNSIGNED DEFAULT NULL'
        },
        {
            name = 'job_pool_amount',
            sql = 'ALTER TABLE `icho_billing_invoices` ADD COLUMN `job_pool_amount` INT UNSIGNED DEFAULT NULL'
        },
        {
            name = 'job_remainder_amount',
            sql = 'ALTER TABLE `icho_billing_invoices` ADD COLUMN `job_remainder_amount` INT UNSIGNED DEFAULT NULL'
        }
    }

    for _, column in ipairs(columns) do
        local exists = MySQL.single.await('SHOW COLUMNS FROM `icho_billing_invoices` LIKE ?', { column.name })
        if not exists then
            MySQL.query.await(column.sql)
        end
    end

    print('[icho_billing] Database schema checked.')
end

function Server.getInvoiceById(invoiceId)
    return MySQL.single.await(SelectSql .. ' WHERE id = ? LIMIT 1', { invoiceId })
end

function Server.getInvoicesForPlayer(citizenid, listType, limit)
    limit = Utils.clamp(limit or Config.Common.HistoryLimit or 50, 1, 200)

    if listType == 'received_unpaid' then
        return MySQL.query.await(SelectSql .. ' WHERE recipient_citizenid = ? AND status = ? ORDER BY created_at DESC LIMIT ' .. limit, {
            citizenid,
            'unpaid'
        })
    elseif listType == 'sent_all' then
        return MySQL.query.await(SelectSql .. ' WHERE issuer_citizenid = ? ORDER BY created_at DESC LIMIT ' .. limit, {
            citizenid
        })
    end

    return MySQL.query.await(SelectSql .. ' WHERE recipient_citizenid = ? ORDER BY created_at DESC LIMIT ' .. limit, {
        citizenid
    })
end

function Server.insertInvoice(invoice)
    return MySQL.insert.await([[
        INSERT INTO icho_billing_invoices (
            invoice_type,
            issuer_citizenid,
            issuer_name,
            issuer_job_name,
            issuer_job_label,
            recipient_citizenid,
            recipient_name,
            amount,
            description,
            job_pool_account,
            job_pool_percent,
            job_pool_amount,
            job_remainder_amount
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        invoice.invoiceType,
        invoice.issuerCitizenId,
        invoice.issuerName,
        invoice.issuerJobName,
        invoice.issuerJobLabel,
        invoice.recipientCitizenId,
        invoice.recipientName,
        invoice.amount,
        invoice.description,
        invoice.jobPoolAccount,
        invoice.jobPoolPercent,
        invoice.jobPoolAmount,
        invoice.jobRemainderAmount
    })
end

function Server.setInvoicePaid(invoiceId, recipientCitizenId, paidByAccount)
    return MySQL.update.await([[
        UPDATE icho_billing_invoices
        SET status = 'paid', paid_at = NOW(), paid_by_account = ?
        WHERE id = ? AND recipient_citizenid = ? AND status = 'unpaid'
    ]], { paidByAccount, invoiceId, recipientCitizenId })
end

function Server.revertInvoiceToUnpaid(invoiceId)
    return MySQL.update.await([[
        UPDATE icho_billing_invoices
        SET status = 'unpaid', paid_at = NULL, paid_by_account = NULL
        WHERE id = ?
    ]], { invoiceId })
end

function Server.cancelInvoice(invoiceId, issuerCitizenId)
    return MySQL.update.await([[
        UPDATE icho_billing_invoices
        SET status = 'cancelled'
        WHERE id = ? AND issuer_citizenid = ? AND status = 'unpaid'
    ]], { invoiceId, issuerCitizenId })
end
