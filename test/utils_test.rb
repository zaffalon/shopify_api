# typed: false
# frozen_string_literal: true

require_relative "./test_helper"

module ShopifyAPITest
  class UtilsTest < Test::Unit::TestCase
    extend T::Sig

    def setup
      super

      test_session = ShopifyAPI::Auth::Session.new(
        id: "id",
        shop: "test-shop.myshopify.io",
        access_token: "this_is_a_test_token"
      )
      ShopifyAPI::Context.activate_session(test_session)
      modify_context(api_version: "2022-04")
    end

    def teardown
      super

      ShopifyAPI::Context.deactivate_session
    end

    sig { void }
    def test_current_shop
      stub_request(:get, "https://test-shop.myshopify.io/admin/api/2022-04/shop.json")
        .with(
          headers: { "X-Shopify-Access-Token" => "this_is_a_test_token", "Accept" => "application/json" },
          body: {}
        )
        .to_return(status: 200, body: load_fixture("shop"), headers: {})

      current_shop = ShopifyAPI::Utils.current_shop()

      assert_requested(:get, "https://test-shop.myshopify.io/admin/api/2022-04/shop.json")
      assert_equal(548380009, current_shop.id)
      assert_equal("John Smith Test Store", current_shop.name)
      assert_equal("j.smith@example.com", current_shop.email)
      assert_equal("shop.apple.com", current_shop.domain)
      assert_equal("1 Infinite Loop", current_shop.address1)
      assert_equal("Suite 100", current_shop.address2)
      assert_equal("Cupertino", current_shop.city)
      assert_equal("California", current_shop.province)
      assert_equal("US", current_shop.country)
      assert_equal("95014", current_shop.zip)
    end

    sig { void }
    def test_current_shop_with_fields
      fields = "address1,address2,city,province,country"
      test_shop = JSON.parse(load_fixture("shop"))
      shop_with_fields_only = {
        "shop" => test_shop["shop"].select { |k, _v| fields.split(",").include?(k) },
      }

      stub_request(:get, "https://test-shop.myshopify.io/admin/api/2022-04/shop.json?fields=address1%2Caddress2%2Ccity%2Cprovince%2Ccountry")
        .with(
          headers: { "X-Shopify-Access-Token" => "this_is_a_test_token", "Accept" => "application/json" },
          body: {}
        )
        .to_return(status: 200, body: JSON.generate(shop_with_fields_only), headers: {})

      # current_shop = ShopifyAPI::Utils.current_shop(fields: fields)
      current_shop = ShopifyAPI::Shop.all(fields: fields).first

      assert_requested(:get, "https://test-shop.myshopify.io/admin/api/2022-04/shop.json?fields=address1%2Caddress2%2Ccity%2Cprovince%2Ccountry")
      assert_equal("1 Infinite Loop", current_shop.address1)
      assert_equal("Suite 100", current_shop.address2)
      assert_equal("Cupertino", current_shop.city)
      assert_equal("California", current_shop.province)
      assert_equal("US", current_shop.country)
    end

    sig { void }
    def test_current_recurring_application_charge
      stub_request(:get, "https://test-shop.myshopify.io/admin/api/2022-04/recurring_application_charges.json")
        .with(
          headers: { "X-Shopify-Access-Token" => "this_is_a_test_token", "Accept" => "application/json" },
          body: {}
        )
        .to_return(status: 200, body: load_fixture("recurring_application_charges"), headers: {})

      current_recurring_application_charge = ShopifyAPI::Utils.current_recurring_application_charge()

      assert_requested(:get, "https://test-shop.myshopify.io/admin/api/2022-04/recurring_application_charges.json")
      assert_equal(455696194, current_recurring_application_charge.id)
    end

    sig { void }
    def test_current_recurring_application_charge_no_active
      recurring_application_charges = JSON.parse(load_fixture("recurring_application_charges"))

      no_active_recurring_application_charges = {
        "recurring_application_charges" =>
          recurring_application_charges["recurring_application_charges"].select { |c| c["status"] != "active" },
      }

      stub_request(:get, "https://test-shop.myshopify.io/admin/api/2022-04/recurring_application_charges.json")
        .with(
          headers: { "X-Shopify-Access-Token" => "this_is_a_test_token", "Accept" => "application/json" },
          body: {}
        )
        .to_return(status: 200, body: JSON.generate(no_active_recurring_application_charges), headers: {})

      # current_recurring_application_charge = ShopifyAPI::Utils.current_recurring_application_charge()
      current_recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.all.find do |c|
        c.status == "active"
      end

      assert_requested(:get, "https://test-shop.myshopify.io/admin/api/2022-04/recurring_application_charges.json")
      assert_nil(current_recurring_application_charge)
    end
  end
end
