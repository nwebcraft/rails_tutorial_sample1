Feature: サインイン機能

  Scenario: サインイン失敗
  Given サインインページを表示する
    When 不正な情報でサインインする
    Then エラーメッセージが表示される

  Scenario: サインイン成功
  Given サインインページを表示する
      And あるユーザーアカウントが存在する
    When 正しい情報でサインインする
    Then プロフィールページが表示される
      And サインアウトのリンクが表示される