class Administrators::CoursesController < Administrators::BaseController
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  def index
    @courses = Course.all
  end

  def show
  end

  def new
    @course = Course.new
  end

  def edit
  end

  def create
    @course = Course.new(course_params)

    if @course.save
      @course.topics_list(params[:course][:topics])
      redirect_to @course, notice: "Course was successfully created."
    else
      render :new
    end
  end

  def update
    if @course.update(course_params)
      @course.topics_list(params[:course][:topics])
      redirect_to @course, notice: "Course was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @course.destroy
    redirect_to courses_url, notice: "Course was successfully destroyed."
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title,
                                   :seo_page_title,
                                   :meta_desc,
                                   :summary,
                                   :description,
                                   :contributor,
                                   :pub_status,
                                   :language_id,
                                   :level,
                                   :topics,
                                   :notes,
                                   :delete_document,
          attachments_attributes: [:course_id,
                                   :document,
                                   :title,
                                   :doc_type,
                                   :_destroy])
  end
end