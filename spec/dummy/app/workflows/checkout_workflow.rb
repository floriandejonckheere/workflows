# frozen_string_literal: true

class CheckoutWorkflow < Workflows::Workflow
  workflow do
    step :check_stock

    step :calculate_shipping,
         depends_on: [:check_stock]

    step :calculate_taxes,
         depends_on: [:check_stock]

    step :create_order,
         depends_on: [:check_stock, :calculate_shipping, :calculate_taxes]

    step :process_payment,
         depends_on: [:create_order]

    step :reserve_inventory,
         depends_on: [:process_payment]

    step :send_confirmation_email,
         class_name: "SendConfirmationStep",
         depends_on: [:process_payment]

    step :trigger_fulfillment,
         depends_on: [:reserve_inventory, :send_confirmation_email]
  end
end
