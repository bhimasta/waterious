require 'pusher-push-notifications'

# Extend this module into notification library class
class Notification
  def initialize(config)
    @config = config
  end

  def broadcast(title, message, id)
    Pusher::PushNotifications.configure do |conf|
      conf.instance_id = @config.PUSHER_INSTANCE_ID
      conf.secret_key = @config.PUSHER_SECRET_KEY
    end

    data = {
      apns: {
        aps: {
          alert: {
            title: title,
            body: message
          }
        }
      },
      fcm: {
        notification: {
          title: title,
          body: message
        }
      }
    }
    Pusher::PushNotifications.publish(interests: [id],
                                      payload: data)
  end
end
