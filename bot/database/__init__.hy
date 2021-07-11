(import
  [bot.utils [config]]
  [gino [Gino]])

(setv db (Gino))

(import bot.database.models)


(defn/a setup []
  (await (.set-bind db config.database)))

(defn/a shutdown []
  (await (.close (.pop-bind db))))


(defn/a query-guild [^int guild-id]
  (setv guild (await (.get models.Guild guild-id)))
  (if (guild is None)
    (setv guild (await (.create models.Guild :id guild-id))))
  (return guild))
