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

  class Data
    attr_accessor :passed, :failed, :na, :measured, :total
    attr_accessor :labels
  end

  def html_graph(passed, failed, na, max_cases)
      return '<div class="htmlgraph">&nbsp;</div>'.html_safe if max_cases == 0
      pw = passed*100/max_cases
      fw = failed*100/max_cases
      nw = na*100/max_cases

      # Do not set zero to any value width if the value is not zero. This
      # would happen e.g. when there's one report that has about 100
      # cases and another one with only 6 of which only 1 is failed. The
      # bar would be all green and a little shorter than a graph of
      # 6 passed cases
      if pw == 0 and passed != 0
          pw = 1
      end
      if fw == 0 and failed != 0
          fw = 1
      end
      if nw == 0 and na != 0
          nw = 1
      end

      ('<div class="htmlgraph">' + graph_div("passed", pw, passed) + graph_div("failed", fw, failed) + graph_div("na", nw, na) + '</div>').html_safe
  end

  def graph_div(cls, width, title)
    "<div class=\"#{cls}\" style=\"width:#{width}%\" title=\"#{cls} #{title}\">&nbsp;</div>"
  end

  def find_trend_sessions(sessions, num=20)
    chosen = []
    days   = []

    if sessions.size == 0
      return chosen, days
    end

    first    = sessions[0].tested_at

    sessions.each do |s|
      day = ((first - s.tested_at)*2).to_i/86400
      chosen << s
      days << day
      if chosen.size >= num
        break
      end
    end
    return chosen, days
  end

  def generate_trend_graph_data(sessions, days, relative=false, num=20)
    data = Data.new
    data.passed = passed = []
    data.failed = failed = []
    data.na     = na     = []
    data.labels = labels = []

    sessions.sort! {|a,b| a.build_id <=> b.build_id}
    sessions.reverse!
    sessions.reverse_each do |s|
      labels << s.id
      total_cases = s.total_cases
      if total_cases > 0
        if relative
          rpass = s.total_passed*100/total_cases
          rfail = s.total_failed*100/total_cases
          rna = s.total_na*100/total_cases
          delta = 100 - (rpass+rfail+rna)
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
          passed << s.total_passed
          failed << s.total_failed
          na << s.total_na
        end
      end
    end
    filler = 20 - sessions.size
    if filler > 0
      labels.concat [""] * filler
      passed.concat [0] * filler
      failed.concat [0] * filler
      na.concat [0] * filler
    end

    data
  end
end
