require_relative '../spec_helper'

feature "User Authentication", js: true do
  scenario "signing up successfully and then logging in" do
    visit "/"
    click_link "Sign Up"
    # ^-- This new link is in app/views/layout.erb
    fill_in "Email", with: "user@example.com"
    fill_in "Password", with: "example.com is a great domain to use for testing"
    fill_in "Confirm Password", with: "example.com is a great domain to use for testing"
    click_button "Sign Up"
    page.should have_content("Thanks for signing up! You may now log in!")
    User.count.should == 1
    # ^-- For your sanity, you may want to add this line to double-check that the user record was
    #     actually created.  Strictly speaking, this doesn't belong in an integration test because
    #     integration tests are written from the perspective of the end-user, and they wouldn't be
    #     able to look into the database.
    fill_in "Email", with: "user@example.com"
    fill_in "Password", with: "example.com is a great domain to use for testing"
    click_button "Log In"
    page.should have_content("You are logged in as user@example.com")
    page.should_not have_content("Sign Up")
  end

  scenario "sign up failure" do
    visit "/"
    click_link "Sign Up"
    # We are entirely skipping filling in the sign up form,
    # and then immediately click to submit the sign up form
    click_button "Sign Up"
    page.should have_content("Email can't be blank")
    fill_in "Email", with: "rosemary@example.com"
    fill_in "Password", with: "example.com is a great domain to use for testing"
    fill_in "Confirm Password", with: "I didn't type the same thing twice in a row"
    click_button "Sign Up"
    page.should have_content("Password confirmation doesn't match Password")
    # Confirm that trying again will succeed, and that
    # the form value for email been retained across pages
    find_field("Email").value.should == "rosemary@example.com"
    fill_in "Password", with: "Password1"
    fill_in "Confirm Password", with: "Password1"
    click_button "Sign Up"
    page.should have_content("Thanks for signing up! You may now log in!")

    fill_in "Email", with: "rosemary@example.com"
    fill_in "Password", with: "Password1"
    click_button "Log In"
    page.should have_content("You are logged in as rosemary@example.com")
    page.should_not have_content("Sign Up")
  end

  scenario "Signing In with Incorrect Credentials" do
    User.create!(email: "jaclyn@example.com", password: "Password!!!!", password_confirmation: "Password!!!!")
    visit "/"
    click_link "Sign In"
    fill_in "Email", with: "jaclyn@example.com"
    fill_in "Password", with: "Not the real password"
    click_button "Log In"
    page.should have_content("Invalid email or password")
    # Confirm that trying again will succeed, and that
    # the form value for email been retained across pages
    find_field("Email").value.should == "jaclyn@example.com"
    fill_in "Password", with: "Password!!!!"
    click_button "Log In"
    page.should have_content("You are logged in as jaclyn@example.com")
    page.should_not have_content("Sign In")
  end

  scenario "Signing Out" do
    password = "Password!!!!"
    user = User.create!(email: "jaclyn@example.com", password: password, password_confirmation: password)
    login_as(user, password)
    page.should_not have_content("Sign In")
    page.should have_button("Sign Out")
    click_button("Sign Out")
    page.should have_content("You have been logged out.")
    page.should have_content("Sign In")
    page.should_not have_content("Sign Out")
  end
end
