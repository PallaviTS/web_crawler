class SitesController < ApplicationController
  def new
    @site = Site.new
  end
  
  def create
    @site = Site.create(site_params)
    if @site.save
      data = Site.crawl(site_params.merge({site_id: @site.id}))
      if data[:results].length > 0
        flash[:success] = "Successfully crawled"
      else
        flash[:danger] = "Not able to crawl the site, errors: #{data[:errors].first[:error]}"
      end
      redirect_to events_path
    else
      render :new
    end
  end

  private
  
  def site_params
    params.require(:site).permit(:url, :max_url, :interval)
  end
end
