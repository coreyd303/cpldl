class Topic < ActiveRecord::Base
  has_many :course_topics
  has_many :courses, through: :course_topics
end