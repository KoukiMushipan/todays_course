user = User.create!(name: 'test_name', email: 'test@example.com', password: 'password', password_confirmation: 'password')
location1 = Location.create!(name: '実家', latitude: 35.87958811349484, longitude: 139.64677422655328, address: '埼玉県さいたま市浦和区北浦和２丁目２０−８')
location2 = Location.create!(name: '北本', latitude: 36.03082342647312, longitude: 139.5205872627565, address: '埼玉県北本市西高尾７丁目１３３')
departure1 = Departure.create!(user: user, location: location1, is_saved: true)
departure2 = Departure.create!(user: user, location: location2, is_saved: true)
