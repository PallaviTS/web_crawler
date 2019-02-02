class SitesController < ApplicationController
  def new
    @site = Site.new
  end
  
  def create
    @site = Site.create(site_params)
    if @site.save
      data = Site.crawl(site_params)
      if data[:results].length > 0
        flash[:notice] = "Successfully crawled"
      elsif data[:results].length > 0 && data[:errors].length > 0
        Rails.logger.info data[:errors]
        flash[:notice] = "Partially crawled"
      else
        flash[:error] = "Not able to crawl the site, errors: #{data[:errors]}"
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
