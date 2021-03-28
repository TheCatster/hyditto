(import
  [bot.utils [config]]
  [gino [Gino]])

(setv db (Gino))

(import bot.database.models)


(defn/a setup []
  (await (.set_bind db config.database)))

(defn/a shutdown []
  (await (.close (.pop_bind db))))


(defn/a query_guild [^int guild_id]
  (setv guild (await (.get models.Guild guild_id)))
  (if (guild is None)
    (setv guild (await (.create models.Guild :id guild_id))))
  (return guild))
