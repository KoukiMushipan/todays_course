class History < ApplicationRecord
  belongs_to :user
  belongs_to :destination
  has_one :departure, through: :destination

  validates :comment, length: { maximum: 255 }
  validates :moving_distance, presence: true, numericality: { only_integer: true, in: 1..42_195 }
  validate :end_time_check

  before_create -> { self.uuid = SecureRandom.uuid }
  before_create -> { self.start_time = Time.zone.now if start_time.nil? }
  before_create -> { self.comment = nil if comment.blank? }

  before_update -> { self.comment = nil if comment.blank? }

  scope :with_location, -> { includes(destination: [:location, { departure: :location }]) }
  scope :not_finished, -> { where(end_time: nil) }
  scope :finished, -> { where.not(end_time: nil) }
  scope :recent, -> { order(start_time: :desc) }
  scope :past_week, -> { where(start_time: Time.zone.today.ago(6.days)..Time.zone.today.end_of_day) }

  scope :list, -> { with_location.recent }
  scope :finished_list, -> { finished.with_location.recent }

  def self.one_week_moving_distances(user)
    one_week_histories = user.histories.past_week
    week = (0..6).to_a.map { |i| Time.zone.now - i.days }
    week.reverse.map do |day|
      one_day_histories = one_week_histories.find_all { |hitory| day.all_day.cover?(hitory.start_time) }
      one_day_histories.sum(&:moving_distance)
    end
  end

  private

  def end_time_check
    errors.add(:end_time, 'は開始時刻より遅い時間にしてください') if end_time && (start_time > end_time)
  end
end
