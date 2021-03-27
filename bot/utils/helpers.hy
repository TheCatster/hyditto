(import
  [typing [Tuple]]
  [bot.database.models [User]]
  [bot.utils.formulas [xp_formula]]
  ujson)

(with [f (open "bot/levels.json" "r")]
  (setv LEVELS (.load ujson f)))


(defn/a get_create_user [user_id]
  (setv user (await (.get User user_id)))
  (if (user is None)
    (setv user (await (.create User :id user_id))))
  (return user))


(defn chunk [_list ^int amount]
  (for [name [(range 0 (len _list) amount)]]
    (yield (get _list name (+ name amount)))))


(defn/a update_xp [^User user ^float modifier]
  (setv modifier (+= modifier 0.1))
  (setv xp (xp_formula user modifier))
  (await (.apply (.update user :xp xp)))
  (setv og_level user.level)
  (setv user_level 1)
  (for [[level xp] [(.items LEVELS)]]
    (if (>= user.xp xp)
      (setv user_level (int level))
      (break)))
  (await (.apply (.update user :level user_level)))
  (return (, user (!= user_level og_level))))
