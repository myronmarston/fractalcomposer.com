class GeneratedPiecesController < ApplicationController
  layout 'admin'
  active_scaffold :generated_pieces do |config|
    config.actions.exclude :delete
    config.actions.exclude :create
    config.actions.exclude :update    
  end
end