class VitaesController < ApplicationController
  before_action :get_vitae, except: [ :index, :create ]
  before_action :set_csrf_token_header, only: [ :index ]
  
  respond_to :json
  
  def index
    @vitaes = current_user.vitaes.includes(:jobs, :schools, :refs)
    @vitaes = @vitaes.where('id in (?)', params[:id].split(",")) if @filtered = params[:id].presence
    @jobs = @vitaes.map {|vitae| vitae.jobs }.flatten.uniq
    @schools = @vitaes.map {|vitae| vitae.schools }.flatten.uniq
    @refs = @vitaes.map {|vitae| vitae.refs }.flatten.uniq
  end
  
  def create
    @vitae = current_user.vitaes.create(vitae_params)
    
    if @vitae.save
      head :created, location: vitae_url(@vitae)
    else
      render 'errors', status: :unprocessable_entity
    end
  end
  
  def update
    if @vitae.update(vitae_params)
      head :no_content
    else
      render 'errors', status: :unprocessable_entity
    end
  end
  
  def destroy
    head( @vitae.destroy ? :no_content : :method_not_allowed )
  end
  
  private
  
  def get_vitae
    head :not_found unless @vitae = current_user.vitaes.find_by_id( params[:id] )
  end
  
  def vitae_params
    params.require(:vitae).permit( :name, :objective )
  end
end