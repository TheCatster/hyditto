(import
  [bot.database [db]])


(defclass Level [db.Model]
  (setv __tablename__ "levels")
  (setv set_level (.Column db db.BIGINT :primary_key True))
  (setv set_xp (.Column db db.BIGINT)))
