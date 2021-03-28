(import
  [typing [Tuple]]
  [bot.database.models [User]]
  [bot.utils.formulas [xp-formula]]
  ujson)

(with [f (open "bot/levels.json" "r")]
  (setv LEVELS (.load ujson f)))


(defn/a get-create-user [user-id]
  (setv user (await (.get User user-id)))
  (if-not user
    (setv user (await (.create User :id user-id))))
  (return user))


(defn chunk [_list ^int amount]
  (for [name [(range 0 (len _list) amount)]]
    (yield (get _list name (+ name amount)))))


(defn/a update-xp [^User user ^float modifier]
  (setv modifier (+= modifier 0.1))
  (setv xp (xp-formula user modifier))
  (await (.apply (.update user :xp xp)))
  (setv og-level user.level)
  (setv user-level 1)
  (for [[level xp] [(.items LEVELS)]]
    (if (>= user.xp xp)
      (setv user-level (int level))
      (break)))
  (await (.apply (.update user :level user-level)))
  (return (, user (!= user-level og-level))))
