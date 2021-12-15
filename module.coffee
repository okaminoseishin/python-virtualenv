EventEmitter = (require 'events').EventEmitter
exec = (require 'child_process').exec
fs = require 'fs'
path = require 'path'


class VirtualenvManager extends EventEmitter

  constructor: () ->
    @current = null

    @status = document.createElement("div")

    @status.classList.add("inline-block")

    @queue = []

    @on "current", (state) ->
      if state

        if @current
          process.env.PATH = process.env.PATH.replace(@current + ":", "")

        process.env.PATH = state + ":" + process.env.PATH

        @status.textContent = path.basename(path.dirname(path.dirname(state)))

        console.log "virtualenv #{@status.textContent} activated"

        @current = state

      else

        process.env.PATH = process.env.PATH.replace(@current + ":", "")

        @status.textContent = "no virtualenv"

        @current = null

      # if @queue
      #   next = @queue[0]; @queue.splice(0, 1); @activate(next)

  activate: (editor) ->

    if editor == undefined
      return

    command = path.normalize(
      atom.project.relativizePath(editor.getPath())[0] + "/.venv/bin/activate"
    )

    if @current == path.dirname(command)
      return

    if !fs.existsSync command
      return

    exec "source " + command, {
      "cwd": atom.project.getPaths()[0]
    }, (
      error, stdout, stderr
    ) =>

      if error
        console.error stderr
      else
        @emit("current", path.dirname(command))

      # atom.notifications.addInfo('Python Virtualenv found', {detail: [
      #   "Python virtualenv found and successfully activated"
      # ].join('\n'), dismissable: true})

  deactivate: ->
    @emit("current", null)


  # pipeline: ->
  #
  #   if @queue
  #     next = @queue[0]; @queue.splice(0, 1); @activate(next)


module.exports =

  manager: new VirtualenvManager()

  activate: ->

    manager = @manager

    atom.workspace.onDidChangeActiveTextEditor (editor) ->
      manager.activate(editor)

    projects = []

    for editor in atom.workspace.getTextEditors()

      if editor == atom.workspace.getActiveTextEditor()
        continue

      project = atom.project.relativizePath(editor.getPath())[0]

      if project in manager.queue
        continue

      manager.activate(editor)

    #   manager.activate(project)
    #
    #   manager.queue.push(project)
    #
    # manager.queue.push(
    #     atom.project.relativizePath(editor.getPath())[0]
    # ); manager.pipeline()

  consumeStatusBar: (statusBar) ->
    @status = statusBar.addLeftTile(item: @manager.status, priority: 100)

  deactivate: ->
    @status?.destroy(); @status = null
