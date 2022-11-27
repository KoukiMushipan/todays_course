# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

user = User.create(name: 'test-user',
                  email: 'test@example.com',
                  password: 'password',
                  password_confirmation: 'password')

tokyo_location = Location.create(name: '東京大神宮(自宅)',
                          latitude: 35.70015134267332,
                          longitude: 139.7468778916592,
                          address: '東京都千代田区富士見２丁目４−１',
                          place_id: 'ChIJq6q63UOMGGAR7zYBKd7iI3I')

lowson_location = Location.create(name: 'ローソン 九段北目白通店',
                          latitude: 35.69710517502577,
                          longitude: 139.75112417190383,
                          address: '東京都千代田区九段北１丁目１１−５',
                          place_id: 'ChIJhWt06mqMGGARiELHju6OuY0')

nigata_location = Location.create(name: '丸亀製麺新潟小針(自宅)',
                          latitude: 37.88608036051855,
                          longitude: 138.99332533861565,
                          address: '新潟県新潟市西区小針５丁目１７−８',
                          place_id: 'ChIJ187OZ3fI9F8R6GICjXeJDFk')

family_mart_location = Location.create(name: 'ファミリーマート 新潟小針南店',
                          latitude: 37.88232089575081,
                          longitude: 138.98712876881467,
                          address: '新潟県新潟市西区小針南６１−１',
                          place_id: 'ChIJla8KgNfH9F8RQr6IdHi-ADw')


saved_departure = user.departures.create(location_id: tokyo_location.id,
                                        is_saved: true)

unsaved_departure = user.departures.create(location_id: nigata_location.id,
                                          is_saved: false)

saved_destination = user.destinations.create(location_id: lowson_location.id,
                                            departure_id: saved_departure.id,
                                            distance: 500,
                                            is_saved: true)

unsaved_destination = user.destinations.create(location_id: family_mart_location.id,
                                              departure_id: unsaved_departure.id,
                                              distance: 700,
                                              is_saved: false)

saved_history = user.histories.create(destination_id: saved_destination.id,
                                      start_time:  Time.zone.now,
                                      end_time:  Time.zone.now.since(1.hour),
                                      moving_distance: 1000)

unsaved_history = user.histories.create(destination_id: unsaved_destination.id,
                                        start_time: Time.zone.now.next_week,
                                        end_time:  Time.zone.now.next_week.since(30.minutes),
                                        moving_distance: 1500)
