define ['angular'], (angular) ->
  mod = angular.module 'jnrain/config', []

  mod.constant 'apiDomain', '//127.0.0.1:9090'
  mod.constant 'rtDomain', '//127.0.0.1:9091/rt'


# vim:set ai et ts=2 sw=2 sts=2 fenc=utf-8:
