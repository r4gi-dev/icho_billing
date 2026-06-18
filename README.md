# icho_billing

QBCore 向けの請求書リソースです。`ox_lib` のメニューを使い、近距離プレイヤーへの個人請求、ジョブ請求、支払い、履歴確認、取消を扱えます。

## 主な機能

- `F7` または `/billing` で請求書メニューを開く
- FiveM のキー設定からキーバインドを変更可能
- 近距離のプレイヤーだけを `ID + 名前` の一覧から選択
- 個人請求とジョブ請求を分離
- ジョブ請求は作成時に `0%` から `100%` までスライダーでジョブプール配分率を選択
- ジョブ請求の入金先を job 名、または設定した `poolAccount` から自動解決
- 受信した請求書、未払い請求書、送信した請求書を一覧表示
- 支払い済み、未払い、取消済み、支払方法、ジョブ配分情報を詳細表示
- 未払いの送信済み請求書を発行者側から取消可能

## 必要リソース

- `qb-core`
- `ox_lib`
- `oxmysql`
- `qb-banking`

`qb-banking` はジョブ請求のプール入金で使用します。個人請求だけで使う場合は `Config.JobBilling.Enabled = false` にしてください。

## 導入

1. `icho_billing` フォルダを FiveM の resources 配下に置きます。
2. `server.cfg` に依存リソースの後で追加します。

```cfg
ensure qb-core
ensure oxmysql
ensure ox_lib
ensure qb-banking
ensure icho_billing
```

3. サーバーを起動、または `restart icho_billing` で反映します。

## データベース

既定では `Config.Database.AutoCreateTable = true` のため、起動時に `icho_billing_invoices` テーブルを自動作成します。

手動で作成したい場合は `Config.Database.AutoCreateTable = false` にしてから、`sql/icho_billing.sql` をデータベースへ実行してください。

## 使い方

1. `F7` または `/billing` でメニューを開きます。
2. `個人請求` または `ジョブ請求` を選びます。
3. 範囲内のプレイヤー一覧から請求先を選びます。
4. 金額、内容を入力します。
5. ジョブ請求の場合は、ジョブプールへ入金する割合をスライダーで選びます。

支払い側は `未払い請求書` から支払いできます。送信側は `送信した請求書一覧` から状態確認と未払い請求の取消ができます。

## 設定

主な設定は `config.lua` に集約しています。

| 設定 | 内容 |
| --- | --- |
| `Config.Language` | 表示言語。既定は `ja` |
| `Config.Command` | メニューを開くコマンド。既定は `billing` |
| `Config.DefaultKey` | 初期キーバインド。既定は `F7` |
| `Config.Menu.Position` | `ox_lib` メニュー位置 |
| `Config.Common.MinAmount` | 請求できる最小金額 |
| `Config.Common.MaxAmount` | 請求できる最大金額 |
| `Config.Common.MaxDescriptionLength` | 請求内容の最大文字数 |
| `Config.Common.HistoryLimit` | 履歴取得件数 |
| `Config.Common.AllowSelfBilling` | 自分宛て請求を許可するか |
| `Config.Common.RequireNearby` | 請求時に距離チェックを行うか |
| `Config.Common.MaxDistance` | 請求先として選べる最大距離 |
| `Config.Common.Accounts` | 支払い時に確認する所持金種別。先頭から優先 |
| `Config.PersonalBilling.Enabled` | 個人請求の有効/無効 |
| `Config.JobBilling.Enabled` | ジョブ請求の有効/無効 |
| `Config.JobBilling.PoolResource` | ジョブプール入金に使うリソース |
| `Config.JobBilling.DefaultPoolPercent` | ジョブ請求のスライダー初期値 |
| `Config.JobBilling.RemainderTarget` | ジョブプール配分後の残額入金先 |
| `Config.JobBilling.RequireOnDuty` | ジョブ請求に勤務中状態を必須にするか |
| `Config.JobBilling.AllowUnconfiguredJobs` | `Jobs` 未登録ジョブも job 名口座で許可するか |
| `Config.JobBilling.DeniedJobs` | ジョブ請求を禁止するジョブ |
| `Config.JobBilling.Jobs` | ジョブごとの許可設定 |

## ジョブ請求

ジョブ請求では、請求者が作成時にジョブプール配分率を `0%` から `100%` で選びます。

- `100%`: 全額がジョブプールへ入金
- `0%`: 全額が発行者の bank へ入金
- `50%`: 半額がジョブプール、残りが発行者の bank へ入金

`Config.JobBilling.RemainderTarget = 'none'` にすると、ジョブプール配分後の残額は発行者へ入金されません。

### ジョブ追加例

`poolAccount` を省略した場合、`qb-banking` の入金先には job 名がそのまま使われます。

```lua
Config.JobBilling.Jobs = {
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
```

job 名と銀行口座名が違う場合は `poolAccount` を追加してください。

```lua
mechanic = {
    label = 'メカニック',
    minGrade = 0,
    requireOnDuty = true,
    poolPercent = 100,
    poolAccount = 'mechanic_boss',
}
```

既定では `Config.JobBilling.AllowUnconfiguredJobs = false` のため、`Config.JobBilling.Jobs` に登録したジョブだけがジョブ請求を作成できます。すべてのジョブを自動許可したい場合は `true` に変更し、使わせたくないジョブを `DeniedJobs` に追加してください。

## 言語変更

表示文言は `locales` に分離しています。

- `locales/ja.lua`: 日本語
- `locales/en.lua`: 英語

言語を切り替える場合は `Config.Language` を変更します。

```lua
Config.Language = 'en'
```

新しい言語を追加する場合は、既存の locale ファイルを複製して `IchoBilling.Locales.<code>` を変更します。追加した locale ファイルは `fxmanifest.lua` の `shared_scripts` にも追加してください。

## ファイル構成

```text
icho_billing/
├── client.lua
├── server.lua
├── config.lua
├── fxmanifest.lua
├── locales/
│   ├── en.lua
│   └── ja.lua
├── shared/
│   ├── init.lua
│   ├── locale.lua
│   └── utils.lua
├── client/modules/
│   ├── core.lua
│   ├── create.lua
│   └── history.lua
├── server/modules/
│   ├── core.lua
│   ├── database.lua
│   ├── events.lua
│   └── payments.lua
└── sql/
    └── icho_billing.sql
```

## 改造ポイント

- 文言を変える: `locales/*.lua`
- 設定を変える: `config.lua`
- 請求作成画面を変える: `client/modules/create.lua`
- 履歴や詳細表示を変える: `client/modules/history.lua`
- 支払い、返金、ジョブプール入金を変える: `server/modules/payments.lua`
- DB項目や取得条件を変える: `server/modules/database.lua`
- client/server 共通の表示や判定を変える: `shared/utils.lua`

## 注意点

- 請求作成時の距離チェックはクライアント表示だけでなくサーバー側でも確認します。
- 発行者がオフラインでも、個人請求やジョブ請求の残額は通常 bank に入金されます。
- `qb-banking` が起動していない場合、ジョブ請求は利用できません。
- `Config.Common.Accounts = { 'bank', 'cash' }` の場合、支払い時は bank を優先し、足りなければ cash を確認します。複数口座を合算して支払う処理ではありません。
