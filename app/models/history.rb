class History < ApplicationRecord
  belongs_to :user
  belongs_to :destination
  has_one :departure, through: :destination

  validates :moving_distance, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 42195}

  before_create -> { self.uuid = SecureRandom.uuid }
  before_create -> { self.start_time = Time.zone.now if start_time.nil? }

  scope :with_location, -> { includes(destination: [:location, departure: :location]) }
  scope :finished, -> { where.not(end_time: nil) }
  scope :recent, -> { order(created_at: :desc) }

  scope :list, -> { with_location.recent }
  scope :finished_list, -> { finished.with_location.recent }

  def self.one_week_moving_distance(user)
    one_week_histories = user.histories.where(start_time: Time.zone.today.end_of_day.all_week)
    week = (0..6).to_a.map {|i| Time.zone.now - i.days}
    week.reverse.map do |day|
      one_day_histories = one_week_histories.where(start_time: day.all_day)
      total_moving_distance = 0
      one_day_histories.each {|history| total_moving_distance += history.moving_distance}
      total_moving_distance
    end
  end
end
