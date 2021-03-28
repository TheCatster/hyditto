(import
  [bot.database [db]])


(defclass Profile [db.Model]
  (setv __tablename__ "profiles")
  (setv user_id (.Column db db.BIGINT :primary_key True))
  (setv friend_code (.Column db db.Text :default "Not Set"))
  (setv user_name (.Column db db.Text :default "Not Set"))
  (setv timezone (.Column db db.Text)))
