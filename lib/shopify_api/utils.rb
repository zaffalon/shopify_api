# typed: strict
# frozen_string_literal: true

module ShopifyAPI
  module Utils
    extend T::Sig

    sig do
      params(
        session: Auth::Session,
        fields: T.untyped
      ).returns(Shop)
    end
    def self.current_shop(session: Context.active_session, fields: nil)
      T.cast(ShopifyAPI::Shop.all(session: session, fields: fields).first, Shop)
    end

    sig { returns(T.nilable(RecurringApplicationCharge)) }
    def self.current_recurring_application_charge
      T.cast(ShopifyAPI::RecurringApplicationCharge.all.find { |c| c.status == "active" }, T.nilable(RecurringApplicationCharge))
    end
  end
end
