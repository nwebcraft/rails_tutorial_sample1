include StaticPagesHelper

def valid_signin(user)
  fill_in "Eメール",   with: user.email
  fill_in "パスワード", with: user.password
  click_button('サインイン')
end

def valid_user
  fill_in "名前",           with: "サンプル 太郎"
  fill_in "Eメール",         with: "user@example.com"
  fill_in "パスワード",      with: "password"
  fill_in "パスワード(確認)", with: "password"
end

RSpec::Matchers.define :have_error_message do |msg|
  match do |page|
    expect(page).to have_selector('div.alert-error', text: msg)
  end
end

RSpec::Matchers.define :have_success_message do |msg|
  match do |page|
    expect(page).to have_selector('div.alert-success', text: msg)
  end
end