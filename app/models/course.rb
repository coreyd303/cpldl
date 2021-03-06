# == Schema Information
#
# Table name: courses
#
#  id             :integer          not null, primary key
#  title          :string(90)
#  seo_page_title :string(90)
#  meta_desc      :string(156)
#  summary        :string(156)
#  description    :text
#  contributor    :string
#  pub_status     :string           default("D")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  language_id    :integer
#  level          :string
#  notes          :text
#  slug           :string
#  course_order   :integer
#  pub_date       :datetime
#  format         :string
#  subsite_course :boolean          default(FALSE)
#  parent_id      :integer
#  display_on_dl  :boolean          default(FALSE)
#

class Course < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :history]

  def slug_candidates
    [
      :title,
      [:title, :subdomain_for_slug]
    ]
  end

  def subdomain_for_slug
    subdomain
  end

  # PgSearch gem config
  include PgSearch
  multisearchable against: [:title, :summary, :description, :topics_str, :level]

  pg_search_scope :topic_search, associated_against: { topics: :title },
                                 using: {
                                   tsearch: { any_word: true }
                                 }

  # Attributes not saved to db, but still needed for validation
  attr_accessor :other_topic, :other_topic_text, :org_id, :subdomain

  # has_one :assessment
  has_one :course_progress

  has_many :course_topics
  has_many :topics, through: :course_topics
  has_many :lessons
  has_one :organization_course
  has_one :organization, through: :organization_course
  has_many :attachments, dependent: :destroy
  accepts_nested_attributes_for :attachments,
    reject_if: proc { |a| a[:document].blank? }, allow_destroy: true

  belongs_to :language

  validates :description, :contributor, :language_id, presence: true
  validates :title, length: { maximum: 40 }, presence: true
  validates :seo_page_title, length: { maximum: 90 }
  validates :summary, length: { maximum: 74 }, presence: true
  validates :meta_desc, length: { maximum: 156 }
  validates :format, presence: true,
    inclusion: { in: %w(M D), message: "%{value} is not a valid format" }
  validates :pub_status, presence: true,
    inclusion: { in: %w(P D A), message: "%{value} is not a valid status" }
  validates :level, presence: true,
    inclusion: { in: %w(Beginner Intermediate Advanced),
      message: "%{value} is not a valid level" }
  validates :other_topic_text, presence: true, if: proc { |a| a.other_topic == "1" }

  default_scope { order("course_order ASC") }

  def validate_has_unique_title
    if Course.where(title: title).where_exists(:organization_course, organization_id: org_id).count > 0
      errors.add(:title, "must be unique. There is already a course with that title, please select a different title and try again.")
    end
  end

  def topics_list(topic_list)
    if topic_list.present?
      valid_topics = topic_list.reject(&:blank?)
      new_or_found_topics = valid_topics.map do |title|
        Topic.find_or_create_by(title: title)
      end
      self.topics = new_or_found_topics
    end
  end

  def topics_str
    topics.pluck(:title).join(", ")
  end

  def current_pub_status
    case pub_status
    when "D" then "Draft"
    when "P" then "Published"
    when "T" then "Trashed"
    end
  end

  def next_lesson_id(current_lesson_id = 0)
    fail StandardError, "There are no available lessons for this course." if lessons.count == 0

    begin
      current_lesson = lessons.find(current_lesson_id)
      order = current_lesson.lesson_order
      order += 1
      return lessons.order("lesson_order").last.id if order >= last_lesson_order
      next_lesson = lessons.find_by_lesson_order(order)
      next_lesson.id
    rescue
      lessons.order("lesson_order").first.id
    end
  end

  def last_lesson_order
    fail StandardError, "There are no available lessons for this course." if lessons.count == 0
    lessons.maximum("lesson_order")
  end

  def duration(format = "mins")
    total = 0
    lessons.each { |l| total += l.duration }
    Duration.minutes_str(total, format)
  end

  def set_pub_date
    self.pub_date = Time.zone.now unless pub_status != "P"
  end

  def update_pub_date(new_pub_status)
    if new_pub_status == "P"
      self.pub_date = Time.zone.now
    else
      self.pub_date = nil
    end
  end

  def update_lesson_pub_stats(new_pub_status)
    lessons.each do |l|
      l.pub_status = new_pub_status
      l.save
    end
  end

  def post_course_attachments
    self.attachments.where(doc_type: "post-course")
  end

  def supplemental_attachments
    self.attachments.where(doc_type: "supplemental")
  end
end
