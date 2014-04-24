define [
  'angular'

  'jnrain/api/vobj/vpool'
], (angular, vpool) ->
  mod = angular.module 'jnrain/api/ds', [
    'jnrain/api/bridge'
  ]

  mod.factory 'dsAPI', [
    'APIv1'
    (APIv1) ->
      vpool: vpool APIv1
  ]


# vim:set ai et ts=2 sw=2 sts=2 fenc=utf-8: