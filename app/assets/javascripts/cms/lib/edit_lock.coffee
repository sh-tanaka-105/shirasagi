class @Cms_EditLock
  constructor: (selector, lock_url, unlock_url) ->
    @selector = selector
    @lock_url = lock_url
    @unlock_url = unlock_url
    @unloading = false
    @interval = 2 * 60 * 1000
    $('button[type="reset"]').bind('click', @releaseLockOnCancel)
    $('a.back-to-index').bind('click', @releaseLockOnCancel)
    $('a.back-to-show').bind('click', @releaseLockOnCancel)
    @refreshLock()

  updateView: (lock_until) ->
    $("#{@selector} .lock_until").text('')
    return unless lock_until
    $("#{@selector} .lock_until").text(lock_until)

  refreshLock: =>
    return if @unloading
    $.ajax
      type: "GET"
      url: @lock_url
      dataType: "json"
      cache: false
      statusCode:
        200: (data, status, xhr) =>
          if (data.lock_until_pretty)
            @updateView(data.lock_until_pretty)
          else
            @updateView(null)
    setTimeout(@refreshLock, @interval)

  releaseLock: =>
    @unloading = true
    $.ajax
      type: "POST"
      url: @unlock_url
      dataType: "json"
      data:
        _method: "delete"
      async: false
      timeout: 5000
    # must return void
    return

  releaseLockOnCancel: =>
    @releaseLock()
    true
