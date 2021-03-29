(import
  [discord.ext [commands]]
  [bot.database.models [User]]
  [bot.utils [create-embed]])


(defclass Leaderboards [commands.Cog]
  (defn __init__ [self bot]
    (setv self.bot bot))
  #@((.listener commands.Cog)
      (defn/a on-ready [self]
        (print "Leaderboard Cog ready.")))
  #@((.command commands :aliases ["leader" "lead" "board" "top"])
      (defn/a leaderboard [self ctx]
        #[[*Shows the top 10 players in all servers.*
        **Example**: `{prefix}`leaderboard]]
        (setv gino_query (.limit (.order-by User.query (.desc User.xp)) 10))
        (setv leaders (await (.all gino_query.gino)))
        (setv board (lfor player leaders (, f"<@{player.id}>" player.level player.xp)))
        (setv description "")
        (for [user board]
          (setv description (+ description f"**{(+ (board.index user) 1)}.** {(get user 0)} | Level: {(get user 1)} | XP: {(get user 2)}\n")))
        (setv msg (await (create-embed :title f"{(str ctx.guild)}'s Raid Leaderboard" :description description)))
        (await (.send ctx :embed msg)))))


(defn setup [bot]
  (.add-cog bot (Leaderboards bot)))
