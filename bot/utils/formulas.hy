(import
  random
  [bot.database.models [User]])


(defn xp_formula [^User player_db ^float modifier]
  (if (> player_db.level 4)
    (setv xp
      (+ player_db.xp
        (abs (int
              (* (/ (* (.randint random 1 10) (abs (- player_db.level (* player_db.level 0.4)))) 5)
              (+ 1
                (/
                  (pow (+ 10
                          (* 2
                            (abs (- player_db.level (* player_db.level 0.4))))) 2.5)
                  (pow (+ 10 player_db.level
                          (abs (- player_db.level (* player_db.level 0.4)))) 2.5)))
              (modifier))))))
    (setv xp (+ player_db.xp (abs (.randint random 1 5)))))
  (return xp))
