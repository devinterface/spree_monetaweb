SpreeMonetaweb
==============

Introduction goes here.

Installation
------------

Add spree_monetaweb to your Gemfile:

```ruby
gem 'spree_monetaweb', :git => 'git://github.com/devinterface/spree_monetaweb.git', :branch => '2-2-stable'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_monetaweb:install
```

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_monetaweb/factories'
```

Copyright (c) 2014 DevInterface s.c (http://www.devinterface.com), released under the New BSD License


TEST CARDS
-------------

Circuito Numero Carta Data Scadenza CVV Password 3D Secure Esito

VISA 4830540099991310 01/2016 557 valid OK

VISA 4830540099991294 01/2016 952 valid OK

VISA 4943319600239756 02/2015 256 - OK

VISA 4943319600243857 02/2015 134 - OK

MC 5533890199999896 02/2015 678 valid OK

MC 5398320199991093 01/2017 295 valid OK

MC 5533890199999870 02/2015 132 valid OK

MC 5209569603136146 02/2015 127 - OK
