(import
  sys
  time
  discord
  [bot.database :as db]
  [datetime [datetime]]
  [discord.ext [commands]]
  [bot.utils [create-embed get-guild-prefix]])

(setv PY_VERSION f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}")
(setv HY_VERSION "0.20.0") ; Should eventually figure out a programmatic solution to this


(defclass Utility [commands.Cog]
  (defn __init__ [self bot]
    (setv self.bot bot)
    (setv self.start-time (.replace (.now datetime) :microsecond 0)))
  #@((.listener commands.Cog)
      (defn/a on-ready [self]
        (print "Utility Cog ready.")))
  #@((.command commands)
      (defn/a ping [self ctx]
        #[[*Current ping and latency of the bot*

        **Example**: `{prefix}ping`]]
        (setv embed (await (create_embed)))
        (setv before-time (.time time))
        (setv msg (await (.send ctx :embed embed)))
        (setv latency (round (* self.bot.latency 1000)))
        (setv elapsed-ms (- (round (* (- (.time time) before-time) 1000)) latency))
        (.add-field embed :name "Ping" :value f"{elapsed-ms}ms")
        (.add-field embed :name "Latency" :value f"{latency}ms")
        (await (.edit msg :embed embed))))
  #@((.command commands)
      (defn/a uptime [self ctx]
        #[[*Current uptime of the bot*

        **Example**: `{prefix}uptime`]]
        (setv current-time (.replace (.now datetime) :microsecond 0))
        (setv embed (await (create-embed :description f"Time since I went online: {(- current_time self.start_time)}.")))
        (await (.send ctx :embed embed))))
  #@((.command commands)
      (defn/a starttime [self ctx]
        #[[*When the bot was started*

        **Example**: `{prefix}starttime`]]
        (setv embed (await (create-embed :description f"I'm up since {self.start-time}.")))
        (await (.send ctx :embed embed))))
  #@((.command commands)
      (defn/a info [self ctx]
        #[[*Shows stats and infos about the bot*

        **Example**: `{prefix}info`]]
        (setv embed (await (create-embed :title "Ditto")))
        (setv embed.url "https://github.com/TheCatster/hyditto")
        (.set-thumbnail embed :url self.bot.user.avatar-url)
        (.add-field embed
          :name "Bot Stats"
          :value f"```py\nGuilds: {(len self.bot.guilds)}\nUsers: {(len self.bot.users)}\nShards: {self.bot.shard-count}\nShard ID: {ctx.guild.shard-id}```"
          :inline False)
        (.add-field embed
          :name "Server Configuration"
          :value f"```\nPrefix: {(get-guild-prefix self.bot ctx.guild.id)}\n```"
          :inline False)
        (.add-field embed
          :name "Activity"
          :value f"```py\nProcessing {self.bot.active-commands} commands\n{self.bot.total-commands} commands since startup```"
          :inline False)
        (.add-field embed
          :name "Software Versions"
          :value f"```py\nDitto: {self.bot.version}\ndiscord.py: {discord.__version__}\nHy: {HY_VERSION}\nPython: {PY_VERSION}```"
          :inline False)
        (.add-field embed
          :name "Links"
          :value f"[Invite]({self.bot.invite}) | [Github](https://github.com/TheCatster/hyditto)"
          :inline False)
        (.set-footer embed
          :text "Thank you for using Ditto!"
          :icon-url self.bot.user.avatar-url)
        (await (.send ctx :embed embed)))))


(defn setup [bot]
  (.add-cog bot (Utility bot)))
