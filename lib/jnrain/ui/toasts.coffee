define [
  'angular',

  'AngularJS-Toaster'
], (angular) ->
  'use strict'

  mod = angular.module 'jnrain/ui/toasts', [
    'toaster'
  ]

  mod.factory 'Toasts',
    (toaster) ->
      toast: (type, title, text) ->
        toaster.pop type, title, text


# vim:set ai et ts=2 sw=2 sts=2 fenc=utf-8:
