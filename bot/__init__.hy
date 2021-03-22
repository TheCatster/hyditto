(import
  asyncio
  random
  ujson
  [pathlib [Path]]
  discord
  [discord.ext [commands]]
  bot.database
  [bot.database.models [Guild Raid]]
  [bot.utils [config get_guild_prefix]]
  )

(setv __version__ "0.1.0")

(setv invite_link "https://discordapp.com/api/oauth2/authorize?client_id={}&scope=bot&permissions=8192")

(setv presence_strings ["hosting raids" "@Ditto help" "@Ditto host" "catching shinies"])

(defn/a get_prefix [_bot message]
  (setv prefix (.prefix config))
  (if (not (isinstance (.channel message) (.DMChannel discord)))
    (setv prefix (get_guild_prefix _bot (.guild.id message))))
    (return (.when_mentioned_or(prefix) commands _bot message)))

(setv bot (.AutoShardedBot commands :command_prefix get_prefix))
(setv bot.version __version__)
(setv bot.active_commands 0)
(setv bot.total_commands 0)
(.remove_command bot "help")

(defn/a preload_guild_data []
  (setv guilds (await (.query.gino.all Guild)))
  (setv d {})
  (for [guild [guilds]]
    (setv (get d (.id guild)) guild))
  (return d))

(defn/a preload_raid_data []
  (setv raids (await (.query.gino.all Raid)))
  (setv d {})
  (for [raid [raids]]
    (setv (get d (.id raid)) raid))
  (return d))

#@(bot.event
    (defn/a on_ready []
      (setv bot.invite (.format invite_link (.user.id bot)))
      (await (.setup database))
      (print "Logged in as" (.user bot) ".\nServing" (len (.users bot))
        "users in" (len (.guilds bot)) "guilds.\nInvite:" (.format invite_link (.user.id bot)))
      (with [f (open "bot/pokemon/data/pokemon.json" "r")]
        (setv bot.pokemon_images (.load ujson f)))
      (setv bot.guild_data (await (preload_guild_data)))
      (setv bot.raid_data (await (preload_raid_data)))
      (setv bot.queue_data {})
      (for [raid [(.raid_data.values bot)]]
        (setv (get bot.queue_data ((.id raid)"+"(.host_id raid)))
          {"raid_id" (.id raid)  "user_id" (.host_id raid)  "guild_id" (.guild_id raid)}))
      (.loop.create_task bot (presence_task))
      (.loop.create_task bot (sync_guild_data))))

(defn/a presence_task []
  (while (True)
    (await (.change_presence bot :activity (.Game discord (.choice random presence_strings))))
    (await (.sleep asyncio 60))))

(defn/a sync_guild_data []
  (while (True)
    (try
      (setv guild_data (await (preload_guild_data)))
      (if (guild_data) (setv bot.guild_data guild_data))
      (setv raid_data (await (preload_raid_data)))
      (if (raid_data) (setv bot.raid_data raid_data))
      (except [Exception]
        (None)))
    (await (.sleep asyncio 300))))

#@(bot.before_invoke
  (defn/a before_invoke [ctx]
    (setv ctx.bot.total_commands (+= ctx.bot.total_commands 1))
    (setv ctx.bot.active_commands (+= ctx.bot.active_commands 1))))

#@(bot.after_invoke
  (defn/a after_invoke [ctx]
    (setv ctx.bot.active_commands (-= ctx.bot.active_commands 1))))

(defn extensions []
  (setv files (.rglob (Path "bot" "cogs") "*.py"))
  (for [file [files]]
    (yield (.replace (cut (.as_posix file) -3) "/" "."))))

(defn load_extensions [_bot]
  (for [ext [(extensions)]]
    (try
      (.load_extensions _bot ext)
      (except [ex Exception]
        (print "Failed to load extension" ext "- exception:" ex)))))

(defn run []
  (load_extensions bot)
  (.run bot config.token))
