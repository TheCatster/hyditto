(import
    [bot.database [db]])


(defclass Guild [db.Model]
  (setv __tablename__ "guilds")
  (setv id (.Column db db.BIGINT :primary_key True))
  (setv prefix (.Column db db.Text)))
