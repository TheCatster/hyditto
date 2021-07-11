(import
  subprocess
  sys
  discord
  [bot.database :as db]
  [bot.utils [config create-embed]]
  [discord.ext [commands]])

(defn fix-cog-path [cog]
  (if-not (.startswith cog "bot.cogs.")
    (if-not (.startswith cog "cogs.")
      (return (+ "bot.cogs." cog))
      (return (+ "bot." cog))))
  (return cog))


(defclass Owner [commands.Cog :command_attrs (dict :hidden True)]
  (defn __init__ [self bot]
    (setv self.bot bot))
  (defn/a cog-check [self ctx]
    (return (await (.is-owner ctx.bot ctx.author))))
  #@((.listener commands.Cog)
      (defn/a on-ready [self]
        (print "Owner Cog ready.")))
  #@((.command commands)
      (defn/a defaultprefix [self ctx ^str new-prefix]
        (setv old-prefix config.prefix)
        (setv config.prefix new-prefix)
        (.store config)
        (setv embed (await (create-embed :title "Changing default prefix")))
        (.add-field embed :name "From" :value old-prefix)
        (.add_field embed :name "To" :value new-prefix)
        (await (.send ctx :embed embed))))
  #@((.command commands)
      (defn/a shutdown [self ctx]
        (await (.shutdown db))
        (setv embed (await (create-embed :title "Shutting down...")))
        (await (.send ctx :embed embed))
        (.exit sys)))
  #@((.command commands)
      (defn/a load [self ctx ^str cog]
        (setv embed (await (create-embed :title f"Load Extension {cog}")))
        (try
          (.load-extension self.bot (fix-cog-path cog))
          (except [ex [commands.ExtensionAlreadyLoaded commands.ExtensionNotFound]]
            (.add-field embed :name "Error" :value f"{ex}"))
          (else
            (setv embed.description "Success")))
        (await (.send ctx :embed embed))))
  #@((.command commands)
      (defn/a unload [self ctx ^str cog]
        (setv embed (await (create-embed :title f"Unload Extension {cog}")))
        (try
          (.unload-extension self.bot (fix-cog-path cog))
          (except [ex [commands.ExtensionNotLoaded]]
            (.add-field embed :name "Error" :value f"{ex}"))
          (else
            (setv embed.description "Success")))
        (await (.send ctx :embed embed))))
  #@((.command commands)
      (defn/a reload [self ctx ^str cog]
        (setv embed (await (create-embed :title f"Reload Extension {cog}")))
        (try
          (.reload-extension self.bot (fix-cog-path cog))
          (except [ex [commands.ExtensionNotLoaded commands.ExtensionNotFound]]
            (.add-field embed :name "Error" :value f"{ex}"))
          (else
            (setv embed.description "Success")))
        (await (.send ctx :embed embed))))
  #@((.command commands)
      (defn/a cogs [self ctx]
        (setv msg "")
        (for [cog self.bot.cogs]
          (setv msg (+ msg f"- {cog}\n")))
        (setv embed (await (create-embed :title "Loaded Extensions" :description msg)))
        (await (.send ctx :embed embed)))))


(defn setup [bot]
  (.add-cog bot (Owner bot)))
