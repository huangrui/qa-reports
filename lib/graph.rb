#
# This file is part of meego-test-reports
#
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# version 2.1 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA
#
module Graph
  def find_trend_sessions(sessions, num=20)
    chosen = []
    days   = []

    if sessions.size == 0
      return chosen, days
    end

    first    = sessions[0].tested_at
    prev_day = nil

    sessions.each do |s|
      day = ((first - s.tested_at)*2).to_i/86400
      if day == prev_day
        next
      end
      prev_day = day
      chosen << s
      days << day
      if chosen.size >= num
        break
      end
    end
    return chosen, days
  end

  def generate_trend_graph_stacked_bars(sessions, days, relative=false)
    passed = []
    failed = []
    na     = []
    total  = []

    sessions.each do |s|
      total_cases = s.total_cases
      if total_cases > 0
        if relative
          rpass = s.total_passed*61/total_cases
          rfail = s.total_failed*61/total_cases
          rna = s.total_na*61/total_cases
          delta = 61 - (rpass+rfail+rna)
          if delta > 0
            m = [rpass,rfail,rna].max
            if m == rpass
              rpass += delta
            elsif m == rfail
              rfail += delta
            else
              rna += delta
            end
          end
          passed << rpass
          failed << rfail
          na << rna
        else
          total << s.total_cases
          passed << s.total_passed
          failed << s.total_failed
          na << s.total_na
        end
      end
    end
    total_days = days[-1]
    if total_days == 0
      total_days = 1
    end

    if relative
      max_total = 100
    else
      max_total = total.max+10
    end

    chart_type = 'cht=bvs'
    colors     = '&chco=73a20c,ec4343,CACACA'
    spacing    = '&chbh=20,12,0'
    size       = '&chs=700x240'
    legend     = '&chdl=pass|fail|na'
    legend_pos = '&chdlp=b'
    axes       = '&chxt=y,r,x'
    axrange    = "&chxr=0,0,#{max_total}|1,0,#{max_total}"

    if sessions.size == 1
      axlabel = "&chxl=2:|#{sessions[-1].format_date}"
    else
      axlabel = "&chxl=2:|#{sessions.reverse.collect {|s| s.format_date}.join('|')}"
      if days.size < 25
        axlabel += '|' * (25-days.size)
      end
    end

    max_total = 61 if relative
    data     = '&chd=s:' + encode_stacked_bars(days, passed, failed, na, max_total, total_days)

    "http://chart.apis.google.com/chart?" + chart_type + size + spacing + colors + legend + legend_pos + axes + axrange + data + axlabel
  end

  def generate_trend_graph_grouped_bars(sessions, days, relative=false)
    passed = []
    failed = []
    na     = []
    total  = []

    sessions.each do |s|
      total_cases = s.total_cases
      if total_cases > 0
        if relative
          rpass = s.total_passed*100/total_cases
          rfail = s.total_failed*100/total_cases
          rna = s.total_na*100/total_cases
          passed << rpass
          failed << rfail
          na << rna
        else
          total << s.total_cases
          passed << s.total_passed
          failed << s.total_failed
          na << s.total_na
        end
      end
    end
    total_days = days[-1]
    if total_days == 0
      total_days = 1
    end

    if relative
      max_total = 100
    else
      max_total = [passed.max, failed.max, na.max].max
    end

    chart_type = 'cht=bvg'
    colors     = '&chco=CACACA,ec4343,73a20c'
    spacing    = '&chbh=6,1,12'
    size       = '&chs=700x240'
    legend     = '&chdl=na|fail|pass'
    legend_pos = '&chdlp=b'
    axes       = '&chxt=y,r,x'
    axrange    = "&chxr=0,0,#{max_total}|1,0,#{max_total}"

    if sessions.size == 1
      axlabel = "&chxl=2:|#{sessions[-1].format_date}"
    else
      axlabel = "&chxl=2:|#{sessions.reverse.collect {|s| s.format_date}.join('|')}"
      if days.size < 25
        axlabel += '|' * (25-days.size)
      end
    end

    linefill = '&chm=b,CACACA,0,1,0|b,ec4343,1,2,0|B,73a20c,2,0,0'
    data     = '&chd=s:' + encode_grouped_bars(days, passed, failed, na, max_total, total_days)

    "http://chart.apis.google.com/chart?" + chart_type + size + spacing + colors + legend + legend_pos + axes + axrange + data + axlabel
  end

  def generate_trend_graph_lines(sessions, days, relative=false)
    passed = []
    failed = []
    na     = []
    total  = []

    sessions.each do |s|
      total_cases = s.total_cases
      if total_cases > 0
        if relative
          rpass = s.total_passed*100/total_cases
          rfail = s.total_failed*100/total_cases
          passed << rpass
          failed << rpass + rfail
          na << 100
        else
          total << s.total_cases
          passed << s.total_passed
          failed << s.total_failed
          na << s.total_na
        end
      end
    end
    total_days = days[-1]
    if total_days == 0
      total_days = 1
    end

    if relative
      max_total = 100
    else
      max_total = total.max
    end

    chart_type = 'cht=lxy'
    colors     = '&chco=CACACA,ec4343,73a20c'
    markers    = '&chm=o,CACACA,0,-1,6|o,ec4343,1,-1,6|o,73a20c,2,-1,6'
    size       = '&chs=700x240'
    legend     = '&chdl=na|fail|pass'
    legend_pos = '&chdlp=b'
    axes       = '&chxt=y,r,x'
    axrange    = "&chxr=0,0,#{max_total}|1,0,#{max_total}"

    if sessions.size == 1
      axlabel = "&chxl=2:|#{sessions[-1].format_date}"
    elsif total_days < 60
      prc      = total_days/60.0
      midn     = [0, (prc*20).to_int-1].max
      endn     = [0, 20-midn-1].max
      mid_fill = "|"*midn
      end_fill = "|"*endn
      axlabel  = "&chxl=2:|#{sessions[-1].format_date}#{mid_fill}|#{sessions[0].format_date}#{end_fill}"
    else
      axlabel = "&chxl=2:|#{sessions[-1].format_date}|#{sessions[0].format_date}"
    end

    linefill = '&chm=b,CACACA,0,1,0|b,ec4343,1,2,0|B,73a20c,2,0,0'
    data     = '&chd=s:' + encode_area_graph(days, passed, failed, na, max_total, total_days)

    "http://chart.apis.google.com/chart?" + chart_type + size + colors + markers + legend + legend_pos + axes + axrange + data + axlabel
  end

  def generate_trend_graph_area(sessions, days, relative=false)
    passed = []
    failed = []
    na     = []
    total  = []

    sessions.each do |s|
      total_cases = s.total_cases
      if total_cases > 0
        if relative
          rpass = s.total_passed*100/total_cases
          rfail = s.total_failed*100/total_cases
          passed << rpass
          failed << rpass + rfail
          na << 100
        else
          total << s.total_cases
          passed << s.total_passed
          failed << s.total_failed + s.total_passed
          na << s.total_na + s.total_failed + s.total_passed
        end
      end
    end
    total_days = days[-1]
    if total_days == 0
      total_days = 1
    end

    if relative
      max_total = 100
    else
      max_total = (total.max*1.1+5).to_i
    end

    chart_type = 'cht=lxy'
    colors     = '&chco=CACACA,ec4343,73a20c'
    size       = '&chs=700x240'
    legend     = '&chdl=na|fail|pass'
    legend_pos = '&chdlp=b'
    axes       = '&chxt=y,r,x'
    axrange    = "&chxr=0,0,#{max_total}|1,0,#{max_total}"

    if sessions.size == 1
      axlabel = "&chxl=2:|#{sessions[-1].format_date}"
    elsif total_days < 60
      prc      = total_days/60.0
      midn     = [0, (prc*20).to_int-1].max
      endn     = [0, 20-midn-1].max
      mid_fill = "|"*midn
      end_fill = "|"*endn
      axlabel  = "&chxl=2:|#{sessions[-1].format_date}#{mid_fill}|#{sessions[0].format_date}#{end_fill}"
    else
      axlabel = "&chxl=2:|#{sessions[-1].format_date}|#{sessions[0].format_date}"
    end

    linefill = '&chm=b,CACACA,0,1,0|b,ec4343,1,2,0|B,73a20c,2,0,0'
    data     = '&chd=s:' + encode_area_graph(days, passed, failed, na, max_total, total_days)

    "http://chart.apis.google.com/chart?" + chart_type + size + colors + legend + legend_pos + axes + axrange + linefill + data + axlabel
  end

  def encode_stacked_bars(days, passed, failed, na, max, max_days)
    result = []
    data   = []
    if days.size < 20
      filler = simple_encode(0,max)*(20-days.size)
    else
      filler = ''
    end

    data = []
    passed.reverse_each do |v|
      data << simple_encode(v, max)
    end
    result << data.join('') + filler

    data = []
    failed.reverse_each do |v|
      data << simple_encode(v, max)
    end
    result << data.join('') + filler

    data = []
    na.reverse_each do |v|
      data << simple_encode(v, max)
    end
    result << data.join('') + filler

    result.join(',')
  end

  def encode_grouped_bars(days, passed, failed, na, max, max_days)
    result = []
    data   = []
    if days.size < 20
      filler = simple_encode(0,max)*(20-days.size)
    else
      filler = ''
    end
    
    na.reverse_each do |v|
      data << simple_encode(v, max)
    end
    result << data.join('') + filler

    data = []
    failed.reverse_each do |v|
      data << simple_encode(v, max)
    end
    result << data.join('') + filler

    data = []
    passed.reverse_each do |v|
      data << simple_encode(v, max)
    end
    result << data.join('') + filler

    result.join(',')
  end
  
  def encode_area_graph(days, passed, failed, na, max, max_days)
    result = []

    data   = []
    days.reverse_each do |v|
      if max_days < 60
        data << simple_encode(max_days-v, 60)
      else
        data << simple_encode(max_days-v, max_days)
      end
    end
    daydata = data.join('')

    data    = []
    na.reverse_each do |v|
      data << simple_encode(v, max)
    end
    result << daydata
    result << data.join('')

    data = []
    failed.reverse_each do |v|
      data << simple_encode(v, max)
    end
    result << daydata
    result << data.join('')

    data = []
    passed.reverse_each do |v|
      data << simple_encode(v, max)
    end
    result << daydata
    result << data.join('')

    result.join(',')
  end

  def simple_encode(value, max)
    if value < 0 || max < 1
      return '_'
    end
    v = value*61/max
    if v <= 25
      ('A'[0] + v).chr
    elsif v <= 51
      ('a'[0] + v-26).chr
    elsif v <= 61
      ('0'[0] + v-52).chr
    else
      '_'
    end
  end
end
