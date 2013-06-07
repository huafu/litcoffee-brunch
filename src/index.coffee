coffeescript = require 'coffee-script'
docco = require 'docco'

isLiterate = (path) ->
  /\.(litcoffee|coffee\.md)$/.test(path)

normalizeChecker = (item) ->
  switch toString.call(item)
    when '[object RegExp]'
      (string) -> item.test string
    when '[object Function]'
      item
    else
      -> false

sourceFiles = []

module.exports = class LiterateCoffeeScriptCompiler
  brunchPlugin: yes
  type: 'javascript'
  extension: 'litcoffee'
  pattern: /\.(coffee\.md|litcoffee)$/

  constructor: (@config) ->
    @isVendor = normalizeChecker @config?.conventions?.vendor


  onCompile: (generatedFiles) ->
    docco.document
      sources: sourceFiles
      layout: @config?.documentation?.layout or 'parallel'
      output: @config?.documentation?.path or 'docs'
    sourceFiles = []


  compile: (data, path, callback) ->
    bare = not @isVendor path
    options =
      bare: not @isVendor path
      sourceMap: Boolean @config?.sourceMaps
      sourceFiles: [path]
      literate: isLiterate path
    if options.literate or @config?.documentation?.includeNonLitearte
      sourceFiles.push path

    try
      compiled = coffeescript.compile data, options
    catch err
      error = err
    finally
      result = if compiled and options.sourceMap
        code: compiled.js, map: compiled.v3SourceMap
      else
        compiled
      callback error, result
