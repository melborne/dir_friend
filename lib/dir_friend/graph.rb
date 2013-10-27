module DirFriend
  class Graph
    def initialize(dir)
      @dir = dir
    end

    def render(opt={})
      build_graph(opt).to_s
    end

    # Build a graphviz dot data using Gviz
    # opt keys: :layout, :colorscheme, :dir_shape, :file_shape,
    #           :graph(or global), :nodes, :edges
    # ex. layout:'fdp', colorscheme:'blues', graph:{splines:'ortho'}
    def build_graph(opt)
      global_opt, nodes_opt, edges_opt, dir_shape, file_shape = opt_parser(opt)

      dirs = [@dir] + @dir.select(&:directory?)
      
      gv = ::Gviz.new
      gv.global global_opt
      gv.nodes nodes_opt
      gv.edges edges_opt
      dirs.each do |d|
        # files
        d.entries.each do |ent|
          c, fc = color_id(ent.level, nodes_opt[:style])
          gv.node ent.path.to_id, label:ent.name, shape:file_shape,
                                  color:c, fontcolor:fc
        end

        # directory
        c, fc = color_id(d.level, nodes_opt[:style])
        gv.node d.path.to_id, label:d.name, shape:dir_shape,
                              color:c, fontcolor:fc

        # route dir => children
        gv.route d.path.to_id => d.entries.map{ |ch| ch.path.to_id }
      end
      gv
    end

    private
    def opt_parser(opt)
      global = opt[:global] || opt[:graph] || {layout:'dot'}
      global = global.merge(layout:opt[:layout]) if opt[:layout]

      nodes  = opt[:nodes] || {}
      if cs = (nodes[:colorscheme] || opt[:colorscheme])
        cs = opt_color_parser(cs)
        nodes.update(style:'filled', colorscheme:cs)
      end

      edges  = opt[:edges] || {}
      dir_shape = opt[:dir_shape] || nodes[:shape] || 'ellipse'
      file_shape = opt[:file_shape] || nodes[:shape] || 'ellipse'

      [global, nodes, edges, dir_shape, file_shape]
    end

    def opt_color_parser(color)
      unless color.match(/\w\d$/) #end with one digit number
        color = "#{color}#{color_depth}"
      end
      color
    end

    def color_depth
      depth = @dir.depth + 1
      depth > 9 ? 9 : depth
    end

    def color_id(lv, node_style)
      color = @dir.depth + 1 - lv
      fontc =
        if node_style && node_style.match(/filled/)
          lv < ((@dir.depth+1)/2) ? 'white' : 'black'
        else
          'black'
        end
      [color, fontc]
    end
  end
end
