# frozen_string_literal: true

##
# Complex workflow with many, dependent steps
#
# check_stock
# ├── calculate_shipping
# │   └── create_order
# ├── calculate_taxes
# │   └── create_order
# └── (implicit dependency on both shipping and taxes)
#     └── create_order
#         ├── process_payment
#         │   ├── reserve_inventory
#         │   │   └── trigger_fulfillment
#         │   └── send_confirmation_email
#         │       └── trigger_fulfillment
#         └── (implicit dependency on both reserve and email)
#             └── trigger_fulfillment
#
class CheckoutWorkflow < Workflows::Workflow
  workflow :checkout do
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
         type: "SendConfirmationStep",
         depends_on: [:process_payment]

    step :trigger_fulfillment,
         depends_on: [:reserve_inventory, :send_confirmation_email]
  end
end
