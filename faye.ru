require 'faye'
bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
run bayeux