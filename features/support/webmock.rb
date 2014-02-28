require 'webmock/cucumber'
WebMock.disable_net_connect!(
          :allow => [/static.(dev|theodi.org)/, /datapackage\.json/, /package_search/],
          :allow_localhost => true
          )