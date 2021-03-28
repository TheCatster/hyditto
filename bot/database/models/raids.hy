(import
  [bot.database [db]])


(defclass Raid [db.Model]
  (setv __tablename__ "raids")
  (setv id (.Column db db.BIGINT :primary_key True))
  (setv guild_id (.Column db db.BIGINT (.ForeignKey db "guilds.id")))
  (setv pokemon (.Column db db.Text))
  (setv shiny (.Column db db.Boolean))
  (setv gmax (.Column db db.Boolean))
  (setv host_id (.Column db db.BIGINT)))
