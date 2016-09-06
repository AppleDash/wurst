class Api::UrlsController < Api::ApiController
  def index
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 25).to_i

    render json: {urls: Url.all.order(time: :desc).paginate(page: page, per_page: per_page), total: Url.all.count}
  end

  def create
    @url = Url.create(create_params)

    if @url.errors.blank?
      FetchUrlJob.perform_later(@url.id)
      render json: @url, status: :created
    else
      render json: {errors: @url.errors.to_a}, status: :unprocessable_entity
    end
  end

  private
  def create_params
    params.require(:url).permit(:url, :server, :buffer, :nick, :time)
  end
end
