# == Schema Information
#
# Table name: histories
#
#  id              :bigint           not null, primary key
#  end_time        :datetime
#  moving_distance :integer          not null
#  start_time      :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  destination_id  :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_histories_on_destination_id  (destination_id)
#  index_histories_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (destination_id => destinations.id)
#  fk_rails_...  (user_id => users.id)
#
class History < ApplicationRecord
  belongs_to :user
  belongs_to :destination
  has_one :departure, through: :destination

  validates :start_time, presence: true
  validates :moving_distance, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 42195}

  scope :having_end_time, -> { where.not(end_time: nil) }
  scope :place_info, -> { includes([destination: :location, departure: :location]) }
  scope :recent, -> { order(start_time: :desc)}
  scope :not_yet_goal, -> { where(end_time: nil).recent }
  scope :for_index, -> { having_end_time.place_info.recent }

  def time_validates
    if end_time_presence
      return start_end_check
    end
  end

  def start_end_check
    if start_time < end_time
      true
    else
      errors.add(:end_time, I18n.t('process.start_end_check'))
      false
    end
  end

  def end_time_presence
    if end_time.present?
      true
    else
      errors.add(:end_time, I18n.t('process.end_time_presence'))
      false
    end
  end

  def self.set_or_create_place_and_create_history(session_departure, session_destination, course)
    search_departure = Search::Departure.new(session_departure)
    search_destination = Search::Destination.new(session_destination)

    departure = Departure.set_or_new_departure_by_search(search_departure)
    destination = Destination.set_or_new_destination_by_search(search_destination, departure)
    moving_distance = History.distance_calc_by_course(destination.distance, course)
    start_time = Time.now

    create!(departure: departure, destination: destination, user: destination.user,
        moving_distance: moving_distance, start_time: start_time)
  end

  def self.distance_calc_by_course(distance, course)
    case course
    when 'one_way' then distance
    when 'round_trip' then distance * 2
    end
  end
end
