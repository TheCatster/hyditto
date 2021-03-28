(import
  [bot.database [db]])


(defclass Profile [db.Model]
  (setv __tablename__ "profiles")
  (setv user-id (.Column db db.BIGINT :primary-key True))
  (setv friend-code (.Column db db.Text :default "Not Set"))
  (setv user-name (.Column db db.Text :default "Not Set"))
  (setv timezone (.Column db db.Text)))
