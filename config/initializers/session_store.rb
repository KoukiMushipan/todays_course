Rails.application.config.session_store :redis_store,
                                        servers: Settings.redis.servers_url,
                                        key: '_todays_course_session',
                                        expire_after: 7.days
