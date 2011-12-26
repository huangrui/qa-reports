$ () ->
  if $('#trend_labels').text().trim().length > 0
    trend_labels     = $('#trend_labels').text().split(',')
    trend_abs_passed = (parseInt(num) for num in $('#trend_abs_passed').text().split(','))
    trend_abs_failed = (parseInt(num) for num in $('#trend_abs_failed').text().split(','))
    trend_abs_na     = (parseInt(num) for num in $('#trend_abs_na').text().split(','))
    trend_rel_passed = (parseInt(num) for num in $('#trend_rel_passed').text().split(','))
    trend_rel_failed = (parseInt(num) for num in $('#trend_rel_failed').text().split(','))
    trend_rel_na     = (parseInt(num) for num in $('#trend_rel_na').text().split(','))

    g = null
    init_graph = () ->
      g = new Bluff.StackedBar('trend_graph_abs', '700x250')
      g.hide_title = true
      g.tooltips = true
      g.sort = false
      g.bar_spacing = 0.6
      g.marker_font_size = 11
      g.legend_font_size = 14
      g.set_theme
        colors: ['#acacac'],
        marker_color: '#dedede',
        font_color: '#6f6f6f',
        background_colors: ['white', 'white']

    draw_graph = (passed_values, failed_values, na_values) ->
      init_graph()
      g.data('pass', passed_values, '#bcd483')
      g.data('fail', failed_values, '#f36c6c')
      g.data('n/a',  na_values,     '#ddd')
      g.labels = trend_labels
      g.draw()
      size_str = []
      for i in trend_labels
        size_str.push i if i != ""
      $($(".bluff-text")[i]).addClass("axis") for i in [($(".bluff-text").size() - size_str.length) .. $(".bluff-text").size() - 1]

    draw_abs_graph = () ->
      draw_graph(trend_abs_passed, trend_abs_failed, trend_abs_na)

    draw_rel_graph = () ->
      draw_graph(trend_rel_passed, trend_rel_failed, trend_rel_na)

    $("#abs_button").click ->
      $("#abs_button").addClass("inactive")
      $("#rel_button").removeClass("inactive")
      draw_abs_graph()

    $("#rel_button").click ->
      $("#abs_button").removeClass("inactive")
      $("#rel_button").addClass("inactive")
      draw_rel_graph()

    draw_abs_graph()


  $resultTable = $('table#infinite_scroll_results')

  $(window).infinitescroll
    url: $('#report_list_url').text().trim(),
    appendTo: $resultTable,
    triggerAt: 800,
    page: 1

  report_path = ->
    [null,@release,@target,@testset,@product,@id].join '/'

  title_of = (table) ->
    table.find('.index_month_title .name').text() unless table.length == 0

  directives =
    reports:
      'name@href': report_path
      htmlgraph:
        'passed@style': -> "width:#{this.passes/max_cases*100}%"
        'failed@style': -> "width:#{this.fails/max_cases*100}%"
        'na@style':     -> "width:#{this.nas/max_cases*100}%"
        'passed@title': -> "passed #{this.passes}"
        'failed@title': -> "failed #{this.fails}"
        'na@title':     -> "na #{this.nas}"

  $resultTable.bind 'infinitescroll.finish', ->
    data = JSON.parse $resultTable.text()
    $resultTable.empty()
    $contents = $('.month_template').clone()
      .render(data, directives).children()

    $contents.find('.reports tr:even').addClass('odd') #jQuery uses 0-based indexing (1st, 3rd.. are even)
    $contents.find('.reports tr:odd').addClass('even')
    $contents.appendTo('#reports_by_month').show()
    $first_child = $contents.first()
    $previous_month = $first_child.prev()
    if title_of($previous_month) == title_of($first_child)
        $first_child.remove().find('.reports tr').appendTo($previous_month.find('.reports'))

  $(window).trigger('infinitescroll.scrollpage', 1)
