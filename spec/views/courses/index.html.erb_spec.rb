require "rails_helper"

describe "courses/index.html.erb" do

  before(:each) do
    @course = FactoryGirl.create(:course, title: "Searched Title")
  end

  it "shows the appropriate message when no courses are returned" do
    assign(:courses, [])
    render
    expect(rendered).to have_content "No courses match your search."
    expect(rendered).to have_link "View all courses", href: courses_path
  end

  it "shows the appropriate message when at least one course is returned" do
    assign(:courses, [@course])
    render
    expect(rendered).to have_content "Searched Title"
  end

end
