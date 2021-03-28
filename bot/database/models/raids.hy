(import
  [bot.database [db]])


(defclass Raid [db.Model]
  (setv __tablename__ "raids")
  (setv id (.Column db db.BIGINT :primary-key True))
  (setv guild-id (.Column db db.BIGINT (.ForeignKey db "guilds.id")))
  (setv pokemon (.Column db db.Text))
  (setv shiny (.Column db db.Boolean))
  (setv gmax (.Column db db.Boolean))
  (setv host-id (.Column db db.BIGINT)))
