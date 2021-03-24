(import
  discord)

(defn/a create_embed [&optional [title None] [description None] [url None]]
  (setv embed (.Embed discord :title title :description description :url url))
  (setv embed.colour (.Color.purple discord))
  (return embed))

(defn/a wait_for_choice [ctx embed choices]
  (setv d {})
  (for [[index match] [(enumerate choices)]]
    (setv (get d f"{(index)}") (get match 0)))
  (for [[k v] [(.items d)]]
    (.add_field embed :name k :value v :inline True))
  (setv msg (await (.send ctx :embed embed)))
  (for [emoji [(.keys d)]]
    (await (.add_reaction msg emoji)))

  (defn check [_reaction _user]
    (return
      (_reaction.message.id = msg.id
      and _user.id = ctx.author.id
      and _reaction.emoji in (.keys d))))
  (setv [reaction user] (await (.bot.wait_for ctx "reaction_add" :check check :timeout 300.0)))
  (try
    (await (.clear_reactions msg))
    (except [(.Forbidden discord)]
      None))
  (return [(.get d reaction.emoji) msg]))
