require 'webmock/cucumber'
WebMock.disable_net_connect!(:allow => /static.(dev|theodi.org)/)