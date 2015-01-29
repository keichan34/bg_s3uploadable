#= require jquery.fileupload

draganddrop = () ->
  if @draggable == undefined
    div = document.createElement 'div'
    @draggable = ('draggable' of div) or ('ondragstart' of div and 'ondrop' of div)
  else
    @draggable

window.s3uploaderMessages =
  signed_url: {}

window.s3uploaderCallbacks =
  finished: (form, key) ->

window.s3uploaderInstall = () ->
  $('.file-upload').each () ->
    form = $ this

    return if form.data('s3uploader-installed') == true
    form.data 's3uploader-installed', true

    if draganddrop()
      installDragAndDrop this

    bar = form.find '.progress-bar'

    setProgress = (val) ->
      bar.css 'width', "#{val}%"
      bar.attr 'aria-valuenow', val

    $s3key_field  = $ form.data('s3key-field')
    $image_holder = $ form.data('image-holder')

    setImageURI = (uri) ->
      image = $image_holder.find('> img')
      if image.length == 0
        $("<img src='#{uri}'>").appendTo $image_holder
      else
        image.attr 'src', uri

    form.fileupload
      url: form.data 'action'
      type: 'POST'
      autoUpload: true
      dataType: 'xml'
      add: (event, data) ->
        reader = new FileReader
        reader.onload = (e) ->
          setImageURI e.target.result
        reader.readAsDataURL data.files[0]

        $.ajax
          url: '/s3/signed_url'
          type: 'GET'
          dataType: 'json'
          data:
            doc:
              title: data.files[0].name
              size:  data.files[0].size
          success: (signature) ->
            data.formData =
              key: signature.key
              policy: signature.policy
              signature: signature.signature
              AWSAccessKeyId: form.data 'accesskeyid'
              acl: 'private'
              success_action_status: '201'
              'x-amz-server-side-encryption': 'AES256'

            data.submit()

          error: (jqXHR, textStatus, errorThrown) ->
            response = jqXHR.responseJSON
            reader.abort()
            setImageURI()

            alert window.s3uploaderMessages.signed_url[response.error_description]
            document.location.reload()

      send: (e, data) ->
        form.find('.progress').fadeIn()

      progress: (e, data) ->
        percent = parseInt data.loaded / data.total * 100, 10
        setProgress percent

      fail: (e, data) ->
        alert "The upload failed for an unspecified reason. Please check that the image is less than 30 megabytes, then try again."
        document.location.reload()

      success: (data) ->
        key = $(data).find('Key').text()
        $s3key_field.val key

        form.hide()
        window.s3uploaderCallbacks.finished form, key

      done: (e, data) ->
        form.find('.progress').fadeOut 300, () ->
          setProgress 0

installDragAndDrop = (container) ->
  counter = 0
  $container = $ container

  container.addEventListener 'dragover', (e) ->
    e.preventDefault()

  container.addEventListener 'dragenter', (e) ->
    counter += 1

    if counter == 1
      $container.addClass 'filedrag'

  container.addEventListener 'dragleave', (e) ->
    counter -= 1

    if counter == 0
      $container.removeClass 'filedrag'

  container.addEventListener 'drop', (e) ->
    e.preventDefault()

    counter = 0
    $container.removeClass 'filedrag'

$(document).on 'ready page:load', window.s3uploaderInstall
$(document).on 'page:load', ->
  $('.filestyle').each ->
    $this = $ this
    options =
      'input'        : if $this.attr('data-input') == 'false' then false else true,
      'icon'         : if $this.attr('data-icon') == 'false' then false else true,
      'buttonBefore' : if $this.attr('data-buttonBefore') == 'true' then true else false,
      'disabled'     : if $this.attr('data-disabled') == 'true' then true else false,
      'size'         : $this.attr('data-size'),
      'buttonText'   : $this.attr('data-buttonText'),
      'buttonName'   : $this.attr('data-buttonName'),
      'iconName'     : $this.attr('data-iconName'),
      'badge'        : if $this.attr('data-badge') == 'false' then false else true

    $this.filestyle options
