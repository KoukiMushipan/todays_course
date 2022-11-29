class History < ApplicationRecord
  belongs_to :user
  belongs_to :destination
  has_one :departure, through: :destination

  validates :moving_distance, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 42195}
  validate :end_time_check

  before_create -> { self.uuid = SecureRandom.uuid }
  before_create -> { self.start_time = Time.zone.now if start_time.nil? }

  scope :with_location, -> { includes(destination: [:location, departure: :location]) }
  scope :not_finished, -> { where(end_time: nil) }
  scope :finished, -> { where.not(end_time: nil) }
  scope :recent, -> { order(start_time: :desc) }

  scope :list, -> { with_location.recent }
  scope :finished_list, -> { finished.with_location.recent }

  def self.one_week_moving_distance(user)
    one_week_histories = user.histories.where(start_time: Time.zone.today.ago(6.days)..Time.zone.today.end_of_day)
    week = (0..6).to_a.map {|i| Time.zone.now - i.days}
    week.reverse.map do |day|
      one_day_histories = one_week_histories.find_all{ |hitory| day.all_day.cover?(hitory.start_time) }
      one_day_histories.sum { |history| history.moving_distance }
    end
  end

  private

  def end_time_check
    errors.add(:end_time, "は開始時刻より遅い時間にしてください") if end_time && (start_time > end_time)
  end
end
