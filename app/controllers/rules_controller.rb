class RulesController < ApplicationController
  def index
    @excludes = Excludes1Rule.order(:code_a)
    @dx = CodeSet.dx.order(:code)
    @px = CodeSet.px.order(:code)
  end
end
