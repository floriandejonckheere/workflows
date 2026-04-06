# frozen_string_literal: true

##
# Complex workflow with fan-out and fan-in dependencies
#
# check_warehouse_inventory
# └── pick_items_from_shelves
#     └── pack_box
#         └── generate_shipping_label
#             ├── notify_courier
#             └── update_tracking
#                 └── send_customer_notification
#
class OrderFulfillmentWorkflow < Workflows::Workflow
  workflow :order_fulfillment do
    step :check_warehouse_inventory

    step :pick_items_from_shelves,
         depends_on: [:check_warehouse_inventory]

    step :pack_box,
         depends_on: [:pick_items_from_shelves]

    step :generate_shipping_label,
         depends_on: [:pack_box]

    step :notify_courier,
         depends_on: [:generate_shipping_label]

    step :update_tracking,
         depends_on: [:generate_shipping_label]

    step :send_customer_notification,
         depends_on: [:update_tracking]
  end
end

# == Schema Information
#
# Table name: workflows
# Database name: primary
#
#  id           :integer          not null, primary key
#  completed_at :datetime
#  failed_at    :datetime
#  state        :string           default("pending"), not null
#  type         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
