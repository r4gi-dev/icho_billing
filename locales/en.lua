IchoBilling.Locales.en = {
    notify_title = 'Invoices',

    invoice_type = {
        personal = 'Personal invoice',
        job = 'Job invoice',
        unknown = 'Unknown'
    },

    status = {
        unpaid = 'Unpaid',
        paid = 'Paid',
        cancelled = 'Cancelled',
        unknown = 'Unknown'
    },

    menu = {
        title = 'Invoices',
        personal_billing = 'Personal invoice',
        personal_description = 'Send a personal invoice to a nearby player',
        job_billing = 'Job invoice',
        job_description = 'Choose the split while creating the invoice. Default is {percent}% / {job}',
        job_unavailable = 'Unavailable for your current job',
        unpaid = 'Unpaid invoices',
        unpaid_description = 'Pay invoices addressed to you',
        received = 'Received invoices',
        received_description = 'View paid, unpaid, and cancelled invoices',
        sent = 'Sent invoices',
        sent_description = 'View invoices issued by you'
    },

    create = {
        title = 'Create {type}',
        amount = 'Amount',
        description = 'Description',
        description_help = 'Maximum {max} characters',
        pool_percent = 'Job pool split (%)',
        pool_percent_help = '0% sends everything to the issuer, 100% sends everything to the job pool',
        nearby_title = 'Select recipient ({type})',
        nearby_empty = 'No nearby players',
        nearby_empty_help = 'Player must be within {distance}m',
        nearby_distance = 'Distance: {distance}m'
    },

    history = {
        received_unpaid = 'Unpaid invoices',
        received_all = 'Received invoices',
        sent_all = 'Sent invoices',
        empty = 'No matching invoices',
        row_title = '#{id} [{type}] {amount} {status}',
        row_description = 'Counterparty: {counterparty}\nDescription: {description}'
    },

    detail = {
        title = 'Invoice #{id}',
        content = 'Description',
        amount = 'Amount',
        invoice_type = 'Invoice type',
        status = 'Status',
        job_info = 'Job info',
        job_pool_split = 'Job pool split',
        remainder = 'Remainder',
        pay = 'Pay',
        pay_description = 'Pay {amount}',
        pay_confirm_title = 'Pay this invoice?',
        pay_confirm_content = 'Invoice #{id}\n\nAmount: {amount}\nDescription: {description}',
        cancel_invoice = 'Cancel invoice',
        cancel_description = 'Mark this unpaid invoice as cancelled',
        cancel_confirm_title = 'Cancel this invoice?',
        cancel_confirm_content = 'Invoice #{id} will be cancelled.',
        confirm_pay = 'Pay',
        confirm_cancel = 'Cancel invoice',
        back = 'Back',
        metadata_type = 'Invoice type',
        metadata_counterparty = 'Counterparty',
        metadata_amount = 'Amount',
        metadata_status = 'Status',
        metadata_created = 'Created',
        metadata_paid_at = 'Paid at',
        metadata_paid_by = 'Paid by',
        metadata_description = 'Description',
        metadata_job = 'Job',
        metadata_pool_account = 'Pool account',
        metadata_pool_percent = 'Pool percent',
        metadata_pool_amount = 'Pool amount',
        metadata_remainder = 'Remainder'
    },

    notify = {
        job_create_unavailable = 'Your current job cannot create job invoices.',
        invalid_type = 'Invalid invoice type.',
        invalid_target = 'Invalid recipient ID.',
        target_not_found = 'Recipient player was not found.',
        self_billing = 'You cannot invoice yourself.',
        target_too_far = 'Recipient is too far away. Use this within {distance}m.',
        invalid_amount = 'Enter an amount between {min} and {max}.',
        empty_description = 'Enter an invoice description.',
        description_too_long = 'Description must be {max} characters or fewer.',
        job_config_unavailable = 'Your current job or job pool settings cannot create job invoices.',
        create_failed = 'Failed to create invoice.',
        invoice_created = 'Created {type} #{id}.',
        invoice_received = 'Received an invoice for {amount} from {issuer}.',
        invoice_not_found = 'Invoice was not found.',
        invoice_already_processed = 'This invoice has already been processed.',
        insufficient_funds = 'Insufficient funds.',
        payment_state_failed = 'Payment stopped because invoice state could not be updated.',
        issuer_credit_failed = 'Payment was reverted because issuer credit failed.',
        issuer_split_failed = 'Payment was reverted because issuer split failed.',
        job_pool_credit_failed = 'Payment was reverted because job pool credit failed.',
        invoice_paid = 'Paid invoice #{id}.',
        invoice_paid_to_issuer = 'Invoice #{id} was paid.',
        cancel_only_unpaid = 'Only unpaid invoices can be cancelled.',
        cancel_failed = 'Failed to cancel invoice.',
        invoice_cancelled = 'Cancelled invoice #{id}.',
        invoice_cancelled_to_recipient = 'Invoice #{id} was cancelled.'
    }
}
