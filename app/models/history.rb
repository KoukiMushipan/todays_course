class History < ApplicationRecord
  belongs_to :user
  belongs_to :destination
  has_one :departure, through: :destination

  validates :comment, length: { maximum: 255 }
  validates :moving_distance, presence: true, numericality: { only_integer: true, in: 1..42_195 }
  validates :start_time, presence: true, on: :update
  validates :end_time, presence: true, on: :update
  validate :start_time_check, on: :create
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

  def self.create_with_location(user, departure_info, destination_info, course)
    if destination_info[:uuid]
      destination = user.destinations.find_by!(uuid: destination_info[:uuid])
    else
      destination = Destination.create_with_location(user, departure_info, destination_info)
    end

    if course == 'round_trip'
      moving_distance = destination_info[:distance] * 2
    else
      moving_distance = destination_info[:distance]
    end

    user.histories.create!(destination:, moving_distance:)
  end

  def self.one_week_moving_distances(user)
    one_week_histories = user.histories.past_week
    week = (0..6).to_a.map { |i| Time.zone.now - i.days }
    week.reverse.map do |day|
      one_day_histories = one_week_histories.find_all { |hitory| day.all_day.cover?(hitory.start_time) }
      one_day_histories.sum(&:moving_distance)
    end
  end

  private

  def start_time_check
    errors.add(:start_time, 'を入力してください') if start_time.nil? && end_time
  end

  def end_time_check
    return unless start_time && end_time

    errors.add(:end_time, 'は開始時刻より遅い時間にしてください') if start_time > end_time
  end
end
