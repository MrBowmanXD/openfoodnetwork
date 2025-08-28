# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::EnterprisesHelper do
  let(:user) { build(:user) }

  before do
    # Enable helper to use `#can?` method.
    # We could extract this when other helper specs need it.
    allow_any_instance_of(CanCan::ControllerAdditions).to receive(:current_ability) do
      Spree::Ability.new(user)
    end
    allow(helper).to receive(:spree_current_user) { user }
  end

  describe "#enterprise_side_menu_items" do
    let(:enterprise) { build(:enterprise) }
    let(:menu_items) { helper.enterprise_side_menu_items(enterprise) }
    let(:visible_items) { menu_items.select { |i| i[:show] } }

    it "lists default items" do
      expect(visible_items.pluck(:name)).to eq %w[
        primary_details address contact social about business_details images
        vouchers enterprise_permissions tag_rules shop_preferences white_label users
      ]
    end

    it "lists enabled features when allowed", feature: :connected_apps do
      allow(Spree::Config).to receive(:connected_apps_enabled).and_return "discover_regen"

      user.enterprises << enterprise
      expect(visible_items.pluck(:name)).to include "connected_apps"
    end

    context "with inventory enabled", feature: :inventory do
      it "lists inventory_settings" do
        expect(visible_items.pluck(:name)).to include "inventory_settings"
      end
    end

    it "hides Connected Apps by default" do
      user.enterprises << enterprise
      expect(visible_items.pluck(:name)).not_to include "connected_apps"
    end

    it "shows Connected Apps for specific user" do
      user.enterprises << enterprise
      Flipper.enable("cqcm-dev", user)
      expect(visible_items.pluck(:name)).to include "connected_apps"
    end
  end

  describe '#enterprise_sells_options' do
    it 'returns sells options with translations' do
      expect(helper.enterprise_sells_options.map(&:first)).to eq %w[unspecified none own any]
    end
  end
end
