define [
  'angular'

  'jnrain/api/bridge'
  'jnrain/api/session'
  'jnrain/ui/toasts'
], (angular) ->
  'use strict'

  mod = angular.module 'jnrain/controller/rtchannel', [
    'jnrain/api/session'
    'jnrain/ui/toasts'
  ]

  # 实时信道管理
  mod.controller 'RTChannelManager',
    (
      $scope,
      $rootScope,
      $timeout,
      $log,
      SessionAPI,
      rtSocket,
      _raw_rtSocket,
      Toasts,
    ) ->
      $log = $log.getInstance 'RTChannelManager'

      # 连接状态监视
      $scope.rtStatus = 'disconnected'
      $scope.rtSID = null
      $scope.rtIsConnected = false
      $scope.rtCanReconnect = true
      $scope.rtConnectionRetries = 0

      rtSocket.on 'connecting', () ->
        $scope.rtStatus = 'connecting'

      rtSocket.on 'connect', () ->
        $scope.rtIsConnected = true
        $scope.rtStatus = 'connected'
        $scope.rtConnectionRetries = 0
        Toasts.toast 'success', '成功建立实时连接', '实时信道已成功连接。'

        # 发送 hello 认证自己
        rtSocket.emit 'hello',
          loginToken: SessionAPI.getLoginToken()

      rtSocket.on 'disconnect', () ->
        $scope.rtIsConnected = false
        $scope.rtStatus = 'disconnected'
        $scope.rtSID = null
        Toasts.toast 'warning', '实时连接中断', '实时信道连接已断开。'

        # 如果服务器不想让我们重连的话 (比如永久的认证失败), 那就不重连
        if $scope.rtCanReconnect
          # 随机确定一个重连的时间点, 平均下重连过程的服务器负载
          # 5 到 15 秒后随机时间点重连
          reconnectInterval = Math.floor(10000 * Math.random() + 5000)
          $log.debug(
            'reconnect in ' + reconnectInterval + 'ms',
          )
          $timeout (() ->
            _raw_rtSocket.socket.reconnect()
          ), reconnectInterval

      rtSocket.on 'reconnecting', () ->
        $scope.rtStatus = 'reconnecting'
        $scope.rtConnectionRetries++
        Toasts.toast(
          'info',
          '尝试重建实时连接',
          '正在进行第 ' + $scope.rtConnectionRetries + ' 次重连。',
        )

      # 事件处理
      # hello 回应
      rtSocket.on 'helloAck', (data) ->
        $log.info 'helloAck: ', data

        authResult = data.result
        if authResult == 'ok'
          # 更新 footer 后端版本信息展示
          $rootScope.$broadcast 'api:backendVersionsObtained',
            weiyu: data.versions.weiyu
            luohua: data.versions.luohua

          # 记录下实时会话 ID
          $scope.rtSID = data.rt_sid
        else if authResult == 'failed'
          # 认证失败
          $scope.rtCanReconnect = data.canReconnect

      # 实时事件
      rtSocket.on 'rtEvent', (data) ->
        $log.info 'event: ', data

      $log.debug '$scope = ', $scope


# vim:set ai et ts=2 sw=2 sts=2 fenc=utf-8:
