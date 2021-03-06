module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def subdomain
    @subdomain = request.subdomain
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def course_urls
    %w(/ /courses /courses/your)
  end

  def button_color
    case request.subdomain
    when "www" then "btn-blue"
    when "chipublib" then "btn-mustard"
    end
    # request.subdomain == "www" ? "btn-blue" : ""
    # request.subdomain == "chipublib" ? "btn-mustard" : ""
  end

  def hover_color_class
    request.subdomain == "chipublib" ? "cpl-blue" : ""
  end

  def color_class
    request.subdomain == "chipublib" ? "cpl-blue-block" : ""
  end

  def text_color_class
    request.subdomain == "chipublib" ? "cpl-blue-text" : ""
  end

  def link_color_class
    request.subdomain == "chipublib" ? "cpl-purple-text" : ""
  end

  def icon_color_class
    request.subdomain == "chipublib" ? "cpl-blue" : ""
  end

  def download_color_class
    request.subdomain == "chipublib" ? "cpl-purple" : ""
  end

  def cert_color_class
    request.subdomain == "chipublib" ? "cpl-blue" : ""
  end

  def ck_color_class
    request.subdomain == "chipublib" ? "ck-chipublib" : ""
  end

  def widget_color_class
    request.subdomain == "chipublib" ? "course-widget-cpl" : "course-widget"
  end
end
