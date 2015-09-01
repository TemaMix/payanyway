module Payanyway
  class Engine < Rails::Engine
    config.autoload_paths += %W(#{ config.root }/lib)
    isolate_namespace Payanyway
  end
end