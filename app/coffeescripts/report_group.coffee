$(window).load ->
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


  resultTableName = 'table#infinite_scroll_results'

  $(window).infinitescroll
    url: $('#report_list_url').text().trim(),
    appendTo: resultTableName,
    triggerAt: 800,
    page: 1

  monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
  previousYear = null
  previousMonth = null
  currentMonthTable = null

  $(resultTableName).bind 'infinitescroll.finish', ->
    rows = $(resultTableName + ' tr')

    for row in rows
      row = $(row)
      year = row.children('.year').first().text()
      month = parseInt(row.children('.date').first().text().split('.').pop(), 10)


      if previousYear != year || previousMonth != month
        monthTable = $('table.month_template').clone()
        monthTable.removeClass('month_template').addClass('month')
        monthTable.find('.month').text(monthNames[month - 1] + ' ' + year)
        monthTable.show()
        monthTable.appendTo('.index_month')
        currentMonthTable = monthTable

      row.appendTo(currentMonthTable)
      previousYear = year
      previousMonth = month


  $(window).trigger('infinitescroll.scrollpage', 1)

