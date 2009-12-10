#$KCODE = 'u'
Rake.application.options.trace = true

require 'yaml'
require 'haml'

require 'src/sqlserver_win32ado'
require 'src/data_helper'
require 'src/model'

CONFIG = YAML::load(File.open('config.yml'))
TEMPLATES_PATH = CONFIG['templates_path']
OUT_PATH = CONFIG['out_path']

# ----------------------------------------------------------------
@fields = {}
@data

@points = []
@layers = []
@whs = []

# ----------------------------------------------------------------
# Override task's execute method - add descriptive header.
class Rake::Task
    alias execute_old execute
    def execute (args=nil)
        _ = "*" * 80
        puts "\n#{_}\n* task: #{name} (#{comment})\n#{_}"
        #system 'chcp 1251'
        execute_old
    end
end

# ----------------------------------------------------------------
desc 'Dummy task - used for testing purposes'
task :dummy => :analyze do
  p @points[0]
  p '  Dummy Ok'
end

# ----------------------------------------------------------------
# TODO: Make use of ActiveRecord!!! (SQL server adapter doesn't support UTF-8 now).
desc 'Queries data from db'
task :query do
  db = SqlServer_Win32ADO.new(CONFIG['host'])
  db.open(CONFIG['database'])
  db.query(CONFIG['query'])
  fields = db.fields
  db.fields.each_index {|i| @fields[fields[i].downcase] = i }
  @data = db.data
  db.close
  puts "  fields: #{@fields.inspect}"
  puts "  #{@data.size} rows fetched."
end

# ----------------------------------------------------------------
desc 'Analizes data, fills object model.'
task :analyze => :query do

  last_pnt_id = 0
  last_layer_id = 0
  last_wh_id = 0
  point = nil
  layer = nil

  @data.each do |row|

    # Points.
    pnt_id = get(row, 'pnt_id')
    if last_pnt_id != pnt_id
      point = Point.new
      point.id = pnt_id
      point.new_no = get(row, 'new_no')
#        get(row, 'new_no') # ruby bug workaround.
      point.lib_alias = get(row, 'lib_alias'),
      point.number = get(row, 'number'),
      point.bind = get(row, 'bind'),
      point.z_orig = get(row, 'z_orig')
      @points << point
      last_pnt_id = pnt_id
      puts "  pnt_id=#{pnt_id}: #{point.inspect}"
    end

    # Layers.
    layer_id = get(row, 'layer_id')
    if last_layer_id != layer_id
      layer = Layer.new
      layer.nlayer = get(row, 'nlayer')
      layer.lay_index_alias = get(row, 'lay_index_alias')
      layer.lay_description = get(row, 'lay_description')
      layer.laytop = get(row, 'laytop')
      layer.laybottom = get(row, 'laybottom')
      @layers << layer
      point.layers ||= []
      point.layers << layer
      last_layer_id = layer_id
#      puts "    layer_id=#{layer_id}: #{layer.inspect}"
    end

    # WaterHorizons.
    wh_id = get(row, 'wwh_id')
      if last_wh_id != wh_id
        wh = WaterHorizon.new
        wh.whindex = get(row, 'whindex')
        wh.whtop = get(row, 'whtop')
        wh.whbtm = get(row, 'whbtm')
        wh.whpower = get(row, 'whpower')
        wh.isreal = get(row, 'isreal')
        wh.statlevel = get(row, 'statlevel')
        wh.whdecrement = get(row, 'whdecrement')
        wh.whdebit = get(row, 'whdebit')
        wh.dryrest = get(row, 'dryrest')
        wh.commonrigid = get(row, 'commonrigid')
        @whs << wh
        layer ||= Layer.new
        layer.whs ||= []
        layer.whs << wh
        last_wh_id = wh_id
#        puts "    wh_id=#{wh_id}: #{wh.inspect}"
      end

  end #rows

  puts "  #{@points.size} points found."
end

# reads given field from resultset.
def get(row, fieldname)
#  puts "debug: fieldname=#{fieldname}, row=#{row}"
  field_no = @fields[fieldname.downcase]
  raise "field #{fieldname} not found!" unless field_no
  row[field_no]
end

# ----------------------------------------------------------------
desc 'Renders data'
task :render_data => :analyze do

  puts '  Fixing data for output...'
  @points.each do |point|
    point.layers = [Layer.new] unless point.layers
    point.layers.each do |layer|
      layer.whs = [WaterHorizon.new] unless layer.whs
    end
  end

  render 'datatable'
end

# ----------------------------------------------------------------
desc 'Renders design'
task :render_design do
  render 'sheet_design'
end

# ----------------------------------------------------------------
# Renders haml file using given local variables.
def render (template_name, locals = {})
  puts "  Rendering using template <#{template_name}>..."
  template = File.read(TEMPLATES_PATH + '/' + template_name + '.haml')
  haml_engine = Haml::Engine.new(template)
  output = haml_engine.render Data_helper.new(@points, @lasyers, @whs), locals
  File.open(OUT_PATH + '/' + template_name + '.html', 'w') {|f| f.write(output) }
  puts '  rendered ok.'
end