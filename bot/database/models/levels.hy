(import
  [bot.database [db]])


(defclass Level [db.Model]
  (setv __tablename__ "levels")
  (setv set-level (.Column db db.BIGINT :primary-key True))
  (setv set-xp (.Column db db.BIGINT)))
