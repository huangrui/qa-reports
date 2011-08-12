$(window).load () ->

    summary_passed = (parseInt num for num in $('#summary_passed').text().split(','))
    summary_failed = (parseInt num for num in $('#summary_failed').text().split(','))
    summary_na     = (parseInt num for num in $('#summary_na').text().split(','))
    summary_labels = $('#summary_labels').text().split(',')

    g = new Bluff.StackedBar "summary_graph_canvas", "395x210"

    g.hide_title = true
    g.tooltips = true
    g.sort = false
    g.bar_spacing = 0.7
    g.marker_font_size = 18
    g.legend_font_size = 24

    g.set_theme
      colors: ['#acacac']
      marker_color: '#dedede'
      font_color: '#6f6f6f'
      background_colors: ['white', 'white']

    g.data 'pass', summary_passed, '#bcd483'
    g.data 'fail', summary_failed, '#f36c6c'
    g.data 'n/a',  summary_na,     '#ddd'
    g.labels = summary_labels
    g.draw()
