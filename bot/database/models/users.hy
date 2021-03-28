(import
  [bot.database [db]])


(defclass User [db.Model]
  (setv __tablename__ "users")
  (setv id (.Column db db.BIGINT :primary-key True))
  (setv level (.Column db db.Integer :default 0))
  (setv xp (.Column db db.BIGINT :default 0))
  (setv times-hosted (.Column db db.BIGINT :default 0)))
