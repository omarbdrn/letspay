module Payments
  class RefreshPayOuts

    def run
      ::PayOut.where(mango_status: 'CREATED').find_each do |pay_out|
        Mango::PayOut.new.refresh(pay_out)
      end
    end

  end
end
