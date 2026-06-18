# icho_billing

QBCore + ox_lib + oxmysql 用の請求書リソースです。

## 機能

- F7 または `/billing` でメニューを開く
- FiveM のキー設定からキーバインド変更が可能
- 近距離のプレイヤー一覧を `ID + 名前` で表示して選択
- 個人請求とジョブ請求を分離
- 個人請求は誰でも作成可能
- ジョブ請求は作成時に `0%` から `100%` までスライダーでジョブプール配分率を選択
- ジョブ請求の入金先はジョブ名を基準に自動解決
- 支払い済み、未払い、取消済み、請求種別、配分情報を一覧と詳細で確認
- 未払いの送信済み請求書は発行者側から取消可能

## 導入

1. `C:\fivem\icho_billing` を resources に配置します。
2. `server.cfg` に依存リソースの後で追加します。

```cfg
ensure qb-core
ensure oxmysql
ensure ox_lib
ensure qb-banking
ensure icho_billing
```

`qb-banking` はジョブ請求のプール入金で使います。

## データベース

`Config.Database.AutoCreateTable = true` の場合、起動時にテーブルを自動作成します。
手動で入れる場合は `sql/icho_billing.sql` を実行してください。

## 設定

`config.lua` で主に次を調整できます。

- `Config.Language`: 使用する言語。既定は `ja`
- `Config.Command`: メニューを開くコマンド
- `Config.DefaultKey`: 初期キーバインド。既定は `F7`
- `Config.Common.MaxDistance`: 請求先として選べる距離
- `Config.Common.MaxAmount`: 1件あたりの上限金額
- `Config.Common.AllowSelfBilling`: 自分宛て請求の可否
- `Config.PersonalBilling.Enabled`: 個人請求の有効/無効
- `Config.JobBilling.Enabled`: ジョブ請求の有効/無効
- `Config.JobBilling.AllowUnconfiguredJobs`: `Jobs` に未登録のジョブも job 名のプール口座へ入金できるようにするか。既定は `false`
- `Config.JobBilling.DeniedJobs`: ジョブ請求を出させないジョブ。既定では `unemployed`
- `Config.JobBilling.Jobs`: ジョブごとの表示名、必要グレード、勤務中必須、初期配分率、口座名上書き
- `Config.JobBilling.DefaultPoolPercent`: ジョブ請求のスライダー初期値
- `Config.JobBilling.RemainderTarget`: `issuer` で残額を発行者へ、`none` で残額を誰にも入れない

### ジョブ設定例

`poolAccount` を省略した場合は job 名がそのまま `qb-banking` の口座名になります。

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

`irishpub` は既存の `bd-irishpubjob` 側でも `qb-banking` の `irishpub` 口座を使っているため、そのまま整合します。
`mechanic` はサーバー側の QBCore ジョブ名と `qb-banking` 口座名が `mechanic` の場合にそのまま動作します。違う口座名を使う場合は `poolAccount = '口座名'` を追加してください。

## 言語変更

表示文言は `locales` に分離しています。

- 日本語: `locales/ja.lua`
- 英語: `locales/en.lua`

言語を変える場合は `Config.Language = 'en'` のように変更してください。
新しい言語を追加する場合は `locales/ja.lua` を複製し、`IchoBilling.Locales.<code>` の `<code>` を任意の言語コードに変えます。

## 構成

- `shared/init.lua`: 共通名前空間
- `shared/locale.lua`: 翻訳処理
- `shared/utils.lua`: 金額整形、ステータス表示、ジョブ請求プロファイル解決
- `client/modules/core.lua`: クライアント側のQBCore取得、通知、近距離プレイヤー取得
- `client/modules/create.lua`: 請求作成メニュー
- `client/modules/history.lua`: 履歴と請求詳細メニュー
- `server/modules/core.lua`: サーバー側のQBCore取得、通知、距離確認
- `server/modules/database.lua`: DB作成、取得、更新
- `server/modules/payments.lua`: 支払い、返金、ジョブプール入金
- `server/modules/events.lua`: コールバックとNetEvent

改造時は、表示文言だけなら `locales`、設定だけなら `config.lua`、支払い処理なら `server/modules/payments.lua` を見ると追いやすい構成です。

## 使い方

1. `F7` か `/billing` でメニューを開く
2. `個人請求` または `ジョブ請求` を選ぶ
3. 近距離プレイヤー一覧から相手を選ぶ
4. 金額、ジョブプール配分率、内容を入力する

## 補足

- 支払い時は請求者がオンラインでなくても、通常は bank へ入金できます。
- `Config.JobBilling.RemainderTarget = 'none'` にした場合、ジョブプール配分後の残額は入金されません。
- `Config.JobBilling.AllowUnconfiguredJobs = true` の場合でも、`Config.JobBilling.DeniedJobs` に入れたジョブはジョブ請求を作成できません。
