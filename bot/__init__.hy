(import
  asyncio
  random
  ujson
  [pathlib [Path]]
  discord
  [discord.ext [commands]]
  bot.database
  [bot.database.models [Guild Raid]]
  [bot.utils [config get-guild-prefix]])

(setv __version__ "0.1.0")

(setv invite-link "https://discordapp.com/api/oauth2/authorize?client_id={}&scope=bot&permissions=8192")

(setv presence-strings ["hosting raids" "@Ditto help" "@Ditto host" "catching shinies"])

(defn/a get-prefix [_bot message]
  (setv prefix config.prefix)
  (if (not (isinstance message.channel discord.DMChannel))
    (setv prefix (get-guild-prefix _bot message.guild.id)))
  (return ((.when-mentioned-or commands prefix) _bot message)))

(setv bot (.AutoShardedBot commands :command-prefix get-prefix))
(setv bot.version __version__)
(setv bot.active-commands 0)
(setv bot.total-commands 0)
(.remove-command bot "help")

(defn/a preload-guild-data []
  (setv guilds (await (.query.gino.all Guild)))
  (setv d {})
  (lfor guild guilds
    (setv (get d guild.id) guild))
  (return d))

(defn/a preload-raid-data []
  (setv raids (await (.query.gino.all Raid)))
  (setv d {})
  (lfor raid raids
    (setv (get d raid.id) raid))
  (return d))

#@(bot.event
    (defn/a on-ready []
      (setv bot.invite (.format invite-link bot.user.id))
      (await (.setup database))
      (print f"Logged in as {bot.user}.\nServing" (len bot.users)
        "users in" (len bot.guilds) "guilds.\nInvite:" (.format invite-link bot.user.id))
      (with [f (open "bot/pokemon/data/pokemon.json" "r")]
        (setv bot.pokemon-images (.load ujson f)))
      (setv bot.guild-data (await (preload-guild-data)))
      (setv bot.raid-data (await (preload-raid-data)))
      (setv bot.queue-data {})
      (lfor raid (bot.raid-data.values)
        (setv (get bot.queue-data (raid.id "+" raid.host))
          {"raid-id" raid.id  "user-id" raid.host-id  "guild-id" raid.guild-id}))
      (.loop.create-task bot (presence-task))
      (.loop.create-task bot (sync-guild-data))))

(defn/a presence-task []
  (while True
    (await (.change-presence bot :activity (.Game discord (.choice random presence-strings))))
    (await (.sleep asyncio 60))))

(defn/a sync-guild-data []
  (while True
    (try
      (setv guild-data (await (preload-guild-data)))
      (if (guild-data) (setv bot.guild-data guild-data))
      (setv raid-data (await (preload-raid-data)))
      (if (raid-data) (setv bot.raid-data raid-data))
      (except [Exception]
        None))
    (await (.sleep asyncio 300))))

#@(bot.before-invoke
  (defn/a before-invoke [ctx]
    (setv ctx.bot.total-commands (+ ctx.bot.total-commands 1))
    (setv ctx.bot.active-commands (+ ctx.bot.active-commands 1))))

#@(bot.after-invoke
  (defn/a after-invoke [ctx]
    (setv ctx.bot.active-commands (- ctx.bot.active-commands 1))))

(defn extensions []
  (setv files (.rglob (Path "bot" "cogs") "*.hy"))
  (lfor file files (.replace (cut (.as-posix file) 0 -3) "/" ".")))

(defn load-extensions [_bot]
  (lfor ext (extensions)
    (try
      (.load-extension _bot ext)
      (except [ex Exception]
        (print "Failed to load extension" ext "- exception:" ex)))))

(defn run []
  (load-extensions bot)
  (.run bot config.token))
