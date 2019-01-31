class SitesController < ApplicationController
  def create
    site = Site.create(site_params)
    if site.save
      result = Site.crawl(site_params)
      if result
        redirect_to events_path
        flash[:notice] = "Successfully crawled"
      else
        flash[:error] = "Not able to crawl the site, errors: #{result}"
      end
    else
      redirect_to events_path
      flash[:error] = "Not able to crawl the site, errors: #{site.errors.messages}"
    end
  end

  private
  
  def site_params
    params.permit(:url, :max_url, :interval)
  end
end
