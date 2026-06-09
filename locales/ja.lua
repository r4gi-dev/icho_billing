IchoBilling.Locales.ja = {
    notify_title = '請求書',

    invoice_type = {
        personal = '個人請求',
        job = 'ジョブ請求',
        unknown = '不明'
    },

    status = {
        unpaid = '未払い',
        paid = '支払い済み',
        cancelled = '取消済み',
        unknown = '不明'
    },

    menu = {
        title = '請求書',
        personal_billing = '個人請求',
        personal_description = '近距離のプレイヤーを選んで個人請求を送ります',
        job_billing = 'ジョブ請求',
        job_description = '請求時に配分率を選択します。初期値は {percent}% / {job} です',
        job_unavailable = '現在のジョブでは利用できません',
        unpaid = '未払い請求書',
        unpaid_description = '自分宛ての未払い請求書を支払います',
        received = '受信した請求書一覧',
        received_description = '支払い済み、未払い、取消済みを確認します',
        sent = '送信した請求書一覧',
        sent_description = '自分が発行した請求書を確認します'
    },

    create = {
        title = '{type}を作成',
        amount = '金額',
        description = '内容',
        description_help = '最大{max}文字',
        pool_percent = 'ジョブプール配分率(%)',
        pool_percent_help = '0%で全額が請求者、100%で全額がジョブプールに入ります',
        nearby_title = '請求先を選択 ({type})',
        nearby_empty = '近くにプレイヤーがいません',
        nearby_empty_help = '{distance}m以内にいる必要があります',
        nearby_distance = '距離: {distance}m'
    },

    history = {
        received_unpaid = '未払い請求書',
        received_all = '受信した請求書',
        sent_all = '送信した請求書',
        empty = '該当する請求書はありません',
        row_title = '#{id} [{type}] {amount} {status}',
        row_description = '相手: {counterparty}\n内容: {description}'
    },

    detail = {
        title = '請求書 #{id}',
        content = '内容',
        amount = '金額',
        invoice_type = '請求種別',
        status = 'ステータス',
        job_info = 'ジョブ情報',
        job_pool_split = 'ジョブプール配分',
        remainder = '残額',
        pay = '支払う',
        pay_description = '{amount}を支払います',
        pay_confirm_title = '請求書を支払いますか？',
        pay_confirm_content = '請求書 #{id}\n\n金額: {amount}\n内容: {description}',
        cancel_invoice = '請求を取り消す',
        cancel_description = '未払いの請求書を取消済みにします',
        cancel_confirm_title = '請求書を取り消しますか？',
        cancel_confirm_content = '請求書 #{id} を取り消します。',
        confirm_pay = '支払う',
        confirm_cancel = '取り消す',
        back = '戻る',
        metadata_type = '請求種別',
        metadata_counterparty = '相手',
        metadata_amount = '金額',
        metadata_status = 'ステータス',
        metadata_created = '作成日時',
        metadata_paid_at = '支払日時',
        metadata_paid_by = '支払方法',
        metadata_description = '内容',
        metadata_job = 'ジョブ名',
        metadata_pool_account = 'プール先',
        metadata_pool_percent = 'プール率',
        metadata_pool_amount = 'プール額',
        metadata_remainder = '残額'
    },

    notify = {
        job_create_unavailable = '現在のジョブではジョブ請求を作成できません。',
        invalid_type = '請求種別が正しくありません。',
        invalid_target = '請求先IDが正しくありません。',
        target_not_found = '請求先のプレイヤーが見つかりません。',
        self_billing = '自分自身には請求できません。',
        target_too_far = '請求先が遠すぎます。{distance}m以内で実行してください。',
        invalid_amount = '金額は{min}から{max}の範囲で入力してください。',
        empty_description = '請求内容を入力してください。',
        description_too_long = '請求内容は{max}文字以内で入力してください。',
        job_config_unavailable = '現在のジョブ、またはジョブプール設定ではジョブ請求を作成できません。',
        create_failed = '請求書の作成に失敗しました。',
        invoice_created = '{type} #{id} を作成しました。',
        invoice_received = '{issuer} から {amount} の請求書を受け取りました。',
        invoice_not_found = '請求書が見つかりません。',
        invoice_already_processed = 'この請求書は既に処理されています。',
        insufficient_funds = '支払いに必要な残高がありません。',
        payment_state_failed = '請求書の状態が更新できなかったため、支払いを中止しました。',
        issuer_credit_failed = '発行者への入金に失敗したため、支払いを取り消しました。',
        issuer_split_failed = '発行者への配分に失敗したため、支払いを取り消しました。',
        job_pool_credit_failed = 'ジョブプールへの入金に失敗したため、支払いを取り消しました。',
        invoice_paid = '請求書 #{id} を支払いました。',
        invoice_paid_to_issuer = '請求書 #{id} が支払われました。',
        cancel_only_unpaid = '未払いの請求書のみ取り消せます。',
        cancel_failed = '請求書の取消に失敗しました。',
        invoice_cancelled = '請求書 #{id} を取り消しました。',
        invoice_cancelled_to_recipient = '請求書 #{id} が取り消されました。'
    }
}
