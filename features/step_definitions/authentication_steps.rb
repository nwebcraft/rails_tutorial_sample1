Given /^サインインページを表示する$/ do
  visit signin_path
end

Given /^あるユーザーアカウントが存在する$/ do
  @user = User.create(name: "サンプル太郎", email: "sample@test.com", password: "password", password_confirmation: "password")
end

When /^不正な情報でサインインする$/ do
  click_button "サインイン"
end

When /^正しい情報でサインインする$/ do
  fill_in "Eメール",   with: @user.email
  fill_in "パスワード", with: @user.password
  click_button "サインイン"
end

Then /^エラーメッセージが表示される$/ do
  expect(page).to have_selector('div.alert-error')
end

Then /^プロフィールページが表示される$/ do
  expect(page).to have_title(@user.name)
end

Then /^サインアウトのリンクが表示される$/ do
  expect(page).to have_link("Sign out", href: signout_path)
end
