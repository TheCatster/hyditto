(import
  discord
  [bot.database :as db]
  [discord.ext [commands]]
  [bot.database.models [Guild]]
  [bot.utils [get-guild-prefix]])


(defclass Settings [commands.Cog]
  (defn __init__ [self bot]
    (setv self.bot bot))
  #@((.listener commands.Cog)
      (defn/a on-ready [self]
        (print "Settings Cog ready.")))
  #@((.listener commands.Cog)
      (defn/a on-guild-join [self guild]
        (setv _ (await (.query-guild db guild.id)))))
  #@((.has-permissions commands :manage-guild True) (.command commands)
      (defn/a prefix [self ctx &optional ^str [new-prefix None]]
        #[[*Change your servers prefix*

        **Example**: `{prefix}prefix !`
        **Requires permission**: `MANAGER SERVER`]]
        (if-not new-prefix
          (do
            (setv prefix (get-guild-prefix self.bot ctx.guild.id))
            (setv embed (.Embed discord :description f"Prefix currently set to `{prefix}`"))
            (await (.send ctx :embed embed))
            (return)))
        (setv embed (.Embed discord :description "Prefix changed"))
        (setv guild (await (.get Guild ctx.guild.id)))
        (if-not guild
          (do
            (setv guild (await (.create Guild :id ctx.guild.id :prefix new-prefix)))
            (setv (get self.bot.guild_data guild.id) guild))
          (do
            (.add-field embed :name "From" :value guild.prefix)
            (await (.apply (.update guild :prefix new-prefix)))
            (setv (get self.bot.guild_data guild.id) guild)))
        (.add-field embed :name "To" :value new-prefix)
        (await (.send ctx.channel :embed embed))))
  #@(prefix.error
      (defn/a prefix-error-handler [self ctx error]
        (if (isinstance error commands.MissingPermissions)
          (await (.send ctx :embed (.Embed discord :description "Sorry, you need `MANAGE SERVER` permission to change the prefix!")))))))


(defn setup [bot]
  (.add-cog bot (Settings bot)))
