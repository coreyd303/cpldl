module Admin
  class DashboardController < BaseController

    def index
      @courses = Course.all
      render "admin/courses/index", layout: "admin/base_with_sidebar"
      # render layout: "admin/base_with_sidebar"
    end
  end
end
