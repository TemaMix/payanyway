require 'singleton'
require 'yaml'
require 'forwardable'

module Payanyway
  class Gateway
    include Singleton
    PARAMS = {
      'MNT_ID'             => :moneta_id,
      'MNT_TEST_MODE'      => :test_mode,
      'MNT_CURRENCY_CODE'  => :currency,
      'MNT_SUCCESS_URL'    => :success_url,
      'MNT_FAIL_URL'       => :fail_url,
      'MNT_RETURN_URL'     => :return_url,
      'MNT_INPROGRESS_URL' => :inprogress_url
    }.to_settings

    attr_reader :config, :config_for_moneta

    def initialize
      @env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
      @config = load_config
      @config_for_moneta = PARAMS.configure_by(@config)
    end

    def payment_url(params)
      PaymentUrl.build(params)
    end

    class << self
      extend Forwardable
      def_delegators(:instance, *Payanyway::Gateway.instance_methods(false))
    end

    private

    def load_config
      YAML.load(File.read(File.join(Payanyway::Engine.root, 'config/payanyway.yml')))[@env]
    end
  end

  class PaymentUrl
    PARAMS = {
      'MNT_TRANSACTION_ID' => :order_id,
      'MNT_AMOUNT'         => :amount,
      'MNT_CUSTOM1'        => :custom1,
      'MNT_CUSTOM2'        => :custom2,
      'MNT_CUSTOM3'        => :custom3,
    }.to_settings

    def self.build(params)
      params = PARAMS.configure_by(params)
      new_params = Payanyway::Gateway.config_for_moneta.merge(params)
      payment_url = Payanyway::Gateway.config['payment_url']

      "#{ payment_url }?#{ new_params.to_a.map { |option| option.join('=') }.join('&') }"
    end
  end
end