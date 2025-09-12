# frozen_string_literal: true

module ProductSortByStocks
  extend ActiveSupport::Concern

  included do
    @on_hand_sql = Arel.sql("(
      SELECT COALESCE(SUM(si.count_on_hand), 0)
      FROM spree_variants v
      JOIN spree_stock_items si ON si.variant_id = v.id
      WHERE v.product_id = spree_products.id
      GROUP BY v.product_id
    )")

    @backorderable_priority_sql = Arel.sql("(
      SELECT CASE WHEN BOOL_OR(si.backorderable) = true THEN 1 ELSE 0 END
      FROM spree_variants v
      JOIN spree_stock_items si ON si.variant_id = v.id
      WHERE v.product_id = spree_products.id
      GROUP BY v.product_id
    )")

    class << self
      attr_reader :on_hand_sql, :backorderable_priority_sql
    end

    # Ransacker for ordering by stock levels
    ransacker :on_hand do
      @on_hand_sql
    end

    # Ransacker for backorderable status (used for complex sorting)
    ransacker :backorderable_priority do
      @backorderable_priority_sql
    end
  end
end
