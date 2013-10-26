module DirFrie
  class Graph
    def initialize(dir)
      @dir = dir
    end

    def render(opt)
      build_graph(opt).to_s
    end

    def build_graph(opt)
      dirs = [@dir] + @dir.select(&:directory?)
      layout = opt[:layout] || 'dot'
      colorscheme = color_table(opt[:color])
      color_id = ->lv{ (i=9-lv) > 0 ? i : 1 }
      dshape = opt[:dshape] || 'box'
      fshape = opt[:fshape] || 'ellipse'

      gv = ::Gviz.new
      gv.graph do
        global layout:layout
        nodes style:'filled', colorscheme:colorscheme
        dirs.each do |d|
          # files
          d.entries.each do |ent|
            c = color_id[ent.level]
            fc = c > 6 ? 'white' : 'black'
            node ent.path.to_id, label:ent.name, shape:fshape,
                 color:c, fontcolor:fc
          end

          # directory
          c = color_id[d.level]
          fc = c > 6 ? 'white' : 'black'
          node d.path.to_id, label:d.name, shape:dshape,
               color:c, fontcolor:fc
               
          route d.path.to_id => d.entries.map{ |ch| ch.path.to_id }
        end
      end
      gv
    end

    private
    def color_table(name)
      { mono: 'greys9',
        blue: 'blues9',
        green: 'greens9',
        purple: 'bupu9',
        red: 'purd9' }.fetch(:"#{name}", 'pastel19')
    end
  end
end

