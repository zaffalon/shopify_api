# typed: strict
# frozen_string_literal: true

module ShopifyAPI
  module Utils
    extend T::Sig

    sig do
      params(
        fields: T.untyped
      ).returns(T.nilable(ShopifyAPI::Shop))
    end
    def self.current_shop(fields: nil)
      ShopifyAPI::Shop.all(fields: fields).first
    end

    sig { returns(T.nilable(ShopifyAPI::RecurringApplicationCharge)) }
    def self.current_recurring_application_charge
      ShopifyAPI::RecurringApplicationCharge.all.find { |c| c.status == "active" }
    end
  end
end
