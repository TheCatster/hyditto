(import
  random
  [bot.database.models [User]])


(defn xp-formula [^User player-db ^float modifier]
  (if (> player-db.level 4)
    (setv xp
      (+ player-db.xp
        (abs (int
              (* (/ (* (.randint random 1 10) (abs (- player-db.level (* player-db.level 0.4)))) 5)
              (+ 1
                (/
                  (pow (+ 10
                          (* 2
                            (abs (- player-db.level (* player-db.level 0.4))))) 2.5)
                  (pow (+ 10 player-db.level
                          (abs (- player-db.level (* player-db.level 0.4)))) 2.5)))
              (modifier))))))
    (setv xp (+ player-db.xp (abs (.randint random 1 5)))))
  (return xp))
